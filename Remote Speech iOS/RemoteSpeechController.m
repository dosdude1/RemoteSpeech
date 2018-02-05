//
//  RemoteSpeechController.m
//  Remote Speech
//
//  Created by Collin Mistr on 1/1/17.
//  Copyright (c) 2017 Got 'Em Apps. All rights reserved.
//

#import "RemoteSpeechController.h"

@implementation RemoteSpeechController

-(id)init
{
    self=[super init];
    [self initSocket];
    isConnected=NO;
    isSignedIn=NO;
    sendingRawData=NO;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = paths.firstObject;
    return self;
}
-(void)initSocket
{
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
            isConnected=YES;
            break;
            
		case NSStreamEventHasBytesAvailable:
            if (theStream == inputStream) {
                
                if (!sendingRawData)
                {
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                }
                
                uint8_t buffer[102400];
                NSInteger len;
                
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
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
                if (!sendingRawData)
                {
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                }
            }
            break;
            
		case NSStreamEventErrorOccurred:
            isConnected=NO;
            break;
            
		case NSStreamEventEndEncountered:
            isConnected=NO;
            break;

		default:
            NSLog(@"Unknown event");
	}
}
-(void)closeSocket
{
    [inputStream close];
    [outputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    inputStream=nil;
    outputStream=nil;
    isConnected=NO;
    isSignedIn=NO;
}
-(void)temporarilyCloseSocket
{
    [inputStream close];
    [outputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    inputStream=nil;
    outputStream=nil;
    isConnected=NO;
}
-(void)resumeSocket
{
    [self initSocket];
    if (isSignedIn)
    {
        NSString *response = [NSString stringWithFormat:@"loginas:%@,%@\n", username, password];
        NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSUTF8StringEncoding]];
        [outputStream write:[data bytes] maxLength:[data length]];
    }
}
-(void)sendToServer:(NSString *)stringToSend
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        int err=0;
        if (!isConnected)
        {
            [self performSelectorOnMainThread:@selector(initSocket) withObject:nil waitUntilDone:YES];
            if (isSignedIn)
            {
                NSString *response = [NSString stringWithFormat:@"loginas:%@,%@\n", username, password];
                NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSUTF8StringEncoding]];
                err=[outputStream write:[data bytes] maxLength:[data length]];
            }
        }
        NSString *response = stringToSend;
        NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSUTF8StringEncoding]];
        err=[outputStream write:[data bytes] maxLength:[data length]];
        if (err == -1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loginDelegate streamErrorOccurred:err];
            });
        }
    });
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
-(void)loginToServer:(NSString *)inUsername withPassword:(NSString *)inPassword isRememberedAccount:(BOOL)isRemembered
{
    username=inUsername;
    password=inPassword;
    if (isRemembered)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[documentsDirectory stringByAppendingPathComponent:@"targets.plist"]])
        {
            NSArray *targets = [[NSArray alloc] initWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:@"targets.plist"]];
            [self.tableDelegate didReceiveTargetsList:targets];
        }
        isSignedIn=YES;
        isConnected=YES;
    }
    [self sendToServer:[NSString stringWithFormat:@"loginas:%@,%@\n", username, password]];
}
-(void)handleEvent:(NSString *)event
{
    if ([event rangeOfString:@"targets:"].location != NSNotFound)
    {
        NSMutableArray *targets = [[NSMutableArray alloc]init];
        NSArray *targetStrings=[event componentsSeparatedByString:@"\n"];
        for (int i=1; i<targetStrings.count; i++)
        {
            NSString *targ1=[targetStrings objectAtIndex:i];
            if (targ1.length > 6)
            {
                NSString *targetID=[targ1 substringToIndex:[targ1 rangeOfString:@","].location];
                targ1=[targ1 substringFromIndex:[targ1 rangeOfString:@","].location+1];
                NSString *targetName=[targ1 substringToIndex:[targ1 rangeOfString:@","].location];
                targ1=[targ1 substringFromIndex:[targ1 rangeOfString:@","].location+1];
                NSString *targetVoice=[targ1 substringToIndex:[targ1 rangeOfString:@","].location];
                targ1=[targ1 substringFromIndex:[targ1 rangeOfString:@","].location+1];
                NSString *targetStatus=[targ1 substringToIndex:[targ1 rangeOfString:@","].location];
                targ1=[targ1 substringFromIndex:[targ1 rangeOfString:@","].location+1];
                NSString *targetUpdateStatus=targ1;
                if ([targetUpdateStatus isEqualToString:@"No"])
                {
                    targetUpdateStatus=@"-";
                }
                if ([targetVoice isEqualToString:@""])
                {
                    targetVoice=@"-";
                }
                NSDictionary *t=[[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:targetID, targetName, targetVoice, targetStatus, targetUpdateStatus, nil] forKeys:[NSArray arrayWithObjects:@"targetID", @"targetName", @"selectedVoice", @"status", @"otherInfo", nil]];
                [targets addObject:t];
            }
        }
        [targets writeToFile:[documentsDirectory stringByAppendingPathComponent:@"targets.plist"] atomically:YES];
        [self.tableDelegate didReceiveTargetsList:targets];
    }
    else if ([event rangeOfString:@"err-credentials-not-valid"].location != NSNotFound)
    {
        if ([self.loginDelegate respondsToSelector:@selector(didLoginSuccessfully:)]) {
            [self.loginDelegate didLoginSuccessfully:NO];
        }
    }
    else if ([event rangeOfString:@"login-valid"].location != NSNotFound)
    {
        if (!isSignedIn)
        {
            if ([self.loginDelegate respondsToSelector:@selector(didLoginSuccessfully:)])
            {
                [self.loginDelegate didLoginSuccessfully:YES];
            }
        }
        else
        {
            [self sendToServer:[NSString stringWithFormat:@"send-targets\n"]];
        }
        isSignedIn=YES;
    }
    else if ([event rangeOfString:@"voices:"].location != NSNotFound)
    {
        event = [event stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSArray *voices=[[event substringFromIndex:[event rangeOfString:@":"].location+1] componentsSeparatedByString:@","];
        [self.targetSettingsDelegate didReceiveVoicesList:voices];
    }
    else if ([event rangeOfString:@"target-status-changed"].location != NSNotFound)
    {
        [self sendToServer:@"send-targets\n"];
    }
    else if ([event rangeOfString:@"volume:"].location != NSNotFound)
    {
        NSInteger volume=[[event substringFromIndex:[event rangeOfString:@":"].location+1] integerValue];
        if ([self.targetSettingsDelegate respondsToSelector:@selector(didReceiveCurrentVolume:)])
        {
            [self.targetSettingsDelegate didReceiveCurrentVolume:volume];
        }
    }
    else if([event rangeOfString:@"send-audio-data"].location != NSNotFound)
    {
        [self.targetSettingsDelegate audioSendingWillStart];
        [self sendAudioDataToServer:audioDataToSend];
    }
}
-(void)getVolumeForTargetID:(NSString *)targetID
{
    [self sendToServer:[NSString stringWithFormat:@"send-current-volume:%@\n", targetID]];
}
-(void)getVoicesListForTargetID:(NSString *)targetID
{
    [self sendToServer:[NSString stringWithFormat:@"send-voices-list:%@\n", targetID]];
}
-(void)setVoiceOfTargetID:(NSString *)targetID withVoice:(NSString *)voice
{
    [self sendToServer:[NSString stringWithFormat:@"setvoice:%@;%@\n", targetID, voice]];
}
-(void)setVolumeOfTargetID:(NSString *)targetID withVolume:(NSInteger)vol
{
    [self sendToServer:[NSString stringWithFormat:@"setvolume:%@;%d\n", targetID, vol]];
}
-(void)sendMessageToTargetIDs:(NSArray *)targetIDs withMessage:(NSString *)messageToSend
{
    messageToSend = [messageToSend stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    NSString *toSend=@"sendmessage:";
    for (int i=0; i<targetIDs.count; i++)
    {
        toSend=[toSend stringByAppendingString:[targetIDs objectAtIndex:i]];
        if (i<targetIDs.count -1)
        {
            toSend=[toSend stringByAppendingString:@","];
        }
    }
    toSend=[toSend stringByAppendingString:[NSString stringWithFormat:@";say:%@\n", messageToSend]];
    [self sendToServer:toSend];
}
-(void)deleteTargetID:(NSString *)targetID
{
    [self sendToServer:[NSString stringWithFormat:@"delete-target:%@\n", targetID]];
}
-(void)addTargetWithID:(NSString *)targetID withName:(NSString *)targetName
{
    [self sendToServer:[NSString stringWithFormat:@"add-target:%@,%@\n", targetID, targetName]];
}
-(void)sendAudioFile:(NSString *)audioFilePath toTarget:(NSString *)targetID
{
    NSData* audioFileData = [NSData dataWithContentsOfFile:audioFilePath];
    audioDataToSend = audioFileData;
    sentAudioFileName = [audioFilePath lastPathComponent];
    [self sendToServer:[NSString stringWithFormat:@"send-audio-to-target:%@;%lu;%@\n", targetID, audioFileData.length, [audioFilePath lastPathComponent]]];
}
-(void)sendAudioDataToServer:(NSData *)audioFileData
{
    sendingRawData = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.targetSettingsDelegate audioSendingProgressDidChange:0.1 animated:NO];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        NSInteger writeResult = 0;
        NSInteger bytesWritten = 0;
        NSInteger fileSize = audioFileData.length;
        while ( audioFileData.length > bytesWritten )
        {
            while (![outputStream hasSpaceAvailable])
            {
                sleep(0.05);
            }
            writeResult = [outputStream write:[audioFileData bytes]+bytesWritten maxLength:[audioFileData length]-bytesWritten];
            
            //sending NSData over to server
            
            //NSLog(@"WRITE RESULT : %ld",(long)writeResult);
            if ( writeResult == -1 )
                NSLog(@"error code here");
            
            else
                bytesWritten += writeResult;
            
            float percent = (bytesWritten*1.0/fileSize*1.0);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.targetSettingsDelegate audioSendingProgressDidChange:percent animated:YES];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            sendingRawData = NO;
            [self.targetSettingsDelegate audioDidFinishSending];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    });
}
@end
