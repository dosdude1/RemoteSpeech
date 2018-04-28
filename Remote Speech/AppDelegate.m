//
//  AppDelegate.m
//  Remote Speech
//
//  Created by Collin Mistr on 12/21/16.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import "AppDelegate.h"
#include <sys/socket.h>

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    isSignedIn=NO;
    isConnected=NO;
    [self initInterface];
    [self initSocket];
    [self initApplication];
    [self initPreferences];
}
-(void)initApplication
{
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(receiveSleepNotification:) name:NSWorkspaceScreensDidSleepNotification object:nil];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    applicationSupportDirectory = [[paths firstObject] stringByAppendingPathComponent:@"Remote Speech"];
    if (![[NSFileManager defaultManager]fileExistsAtPath:applicationSupportDirectory])
    {
        [[NSFileManager defaultManager]createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSDictionary *infoPlist=[[NSDictionary alloc]initWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Info.plist"]];
    NSString *currentVersion=[infoPlist objectForKey:@"CFBundleShortVersionString"];
    updateController=[[UpdateController alloc]initWithUpdateURL:@"http://dosdude1.com/remotespeech/clientupdate.zip" withUpdateMetaURL:@"http://dosdude1.com/remotespeech/clientupdatemeta.txt" withWhatsNewURL:@"http://dosdude1.com/remotespeech/clientwhatsnew.txt" withFileSavePath:applicationSupportDirectory withCurrentAppVersion:currentVersion];
}
-(void)initInterface
{
    [self.splitView setDelegate:self];
    [self.targetTable setDelegate:self];
    [self.targetTable setDataSource:self];
    [self.targetTable setDoubleAction:@selector(showTargetInfoView:)];
    [self.targetVolumeSlider setMaxValue:100.0];
    [self.targetVolumeSlider setMinValue:0.0];
    targets=[[NSMutableArray alloc]init];
    contextMenu=[[NSMenu alloc]init];
    [contextMenu setDelegate:self];
    [contextMenu setAutoenablesItems:NO];
    NSMenuItem *deleteTargetItem=[[NSMenuItem alloc]initWithTitle:@"Delete..." action:@selector(removeTarget:) keyEquivalent:@""];
    [deleteTargetItem setEnabled:NO];
    NSMenuItem *showTargetSettingsItem=[[NSMenuItem alloc]initWithTitle:@"Settings..." action:@selector(showTargetInfoView:) keyEquivalent:@""];
    [showTargetSettingsItem setEnabled:NO];
    NSMenuItem *playSound=[[NSMenuItem alloc]initWithTitle:@"Play Audio..." action:@selector(beginPlayingAudio) keyEquivalent:@""];
    [playSound setEnabled:NO];
    NSMenuItem *renameTarget=[[NSMenuItem alloc]initWithTitle:@"Rename..." action:@selector(beginRenameTarget:) keyEquivalent:@""];
    [renameTarget setEnabled:NO];
    [contextMenu addItem:showTargetSettingsItem];
    [contextMenu addItem:renameTarget];
    [contextMenu addItem:[NSMenuItem separatorItem]];
    [contextMenu addItem:playSound];
    [contextMenu addItem:[NSMenuItem separatorItem]];
    [contextMenu addItem:deleteTargetItem];
    [self.targetTable setMenu:contextMenu];
}
-(void)initPreferences
{
    prefs=[PreferencesHandler sharedInstance];
    if ([prefs shouldRememberUser])
    {
        username = [prefs getRememberedUsername];
        password = [prefs getRememberedPassword];
        [self.window makeKeyAndOrderFront:self];
        [self loadCachedData];
        [self sendToServer:[NSString stringWithFormat:@"loginas:%@,%@\n", username, password]];
    }
    else
    {
        [self showLoginWindow];
    }
    if (![prefs didFinishTutorial])
    {
        firstRunView=[[FirstRunView alloc]initWithWindowNibName:@"FirstRunView"];
        firstRunView.delegate=self;
        [firstRunView showWindow:self];
    }
    if ([prefs getUpdateStatus]==updateStateAutomatically)
    {
        [updateController checkForAndInstallUpdate];
    }
    else if ([prefs getUpdateStatus]==updateStateNotifyOnly)
    {
        [updateController checkForUpdateByUser:NO];
    }
}
-(void)loadCachedData
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[applicationSupportDirectory stringByAppendingPathComponent:@"cachedTargets.plist"]])
    {
        targets = [[NSMutableArray alloc] initWithContentsOfFile:[applicationSupportDirectory stringByAppendingPathComponent:@"cachedTargets.plist"]];
        [self.targetTable reloadData];
    }
    [self setTargetCount:targets.count];
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [targets count];
}
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTextFieldCell *text=[[NSTextFieldCell alloc]init];
    [text setStringValue:[[targets objectAtIndex:row]objectForKey:[tableColumn identifier]]];
    [text setEditable:YES];
    return text;
}
-(void)showLoginWindow
{
    if (!loginCreateAccountWindow)
    {
        CGRect windowRect=CGRectMake(0, 0, self.mainWindowView.frame.size.width, self.mainWindowView.frame.size.height+self.signInView.frame.size.height);
        loginCreateAccountWindow=[[NSWindow alloc]initWithContentRect:windowRect styleMask:(NSTitledWindowMask|NSWindowCloseButton) backing:NSBackingStoreBuffered defer:YES];
        [loginCreateAccountWindow setReleasedWhenClosed:NO];
        [loginCreateAccountWindow setTitle:@"Remote Speech"];
        CGRect mainViewFrame=CGRectMake(self.mainWindowView.frame.origin.x, ([loginCreateAccountWindow.contentView frame].size.height-self.mainWindowView.frame.size.height), self.mainWindowView.frame.size.width, self.mainWindowView.frame.size.height);
        [self.mainWindowView setFrame:mainViewFrame];
        [loginCreateAccountWindow.contentView addSubview:self.mainWindowView];
        [loginCreateAccountWindow.contentView addSubview:self.signInView];
        [self.loginModeSelection setTarget:self];
        [self.loginModeSelection setAction:@selector(selectLoginView:)];
    }
    else
    {
        [self setViewInLoginWindow:self.signInView];
    }
    [self.usernameField setStringValue:@""];
    [self.passwordField setStringValue:@""];
    [self.desiredUsernameField setStringValue:@""];
    [self.desiredPasswordField setStringValue:@""];
    [self.desiredEmailField setStringValue:@""];
    [self.confirmPasswordField setStringValue:@""];
    [loginCreateAccountWindow center];
    [loginCreateAccountWindow makeKeyAndOrderFront:self];
}
-(void)selectLoginView:(id)sender
{
    NSInteger optionTag=[[self.loginModeSelection selectedCell] tag];
    switch (optionTag)
    {
        case 0:
            [self.usernameField setStringValue:[self.desiredUsernameField stringValue]];
            [self.passwordField setStringValue:[self.desiredPasswordField stringValue]];
            [self setViewInLoginWindow:self.signInView];
            break;
        case 1:
            [self.desiredUsernameField setStringValue:[self.usernameField stringValue]];
            [self.desiredPasswordField setStringValue:[self.passwordField stringValue]];
            [self setViewInLoginWindow:self.createAccountView];
            break;
    }
}
-(void)setViewInLoginWindow:(NSView *)view
{
    [view setFrameOrigin:CGPointMake(0, 0)];
    CGRect newRect=CGRectMake(loginCreateAccountWindow.frame.origin.x, loginCreateAccountWindow.frame.origin.y, view.frame.size.width, self.mainWindowView.frame.size.height+view.frame.size.height);
    NSRect frameRect=[loginCreateAccountWindow frameRectForContentRect:newRect];
    frameRect.origin = loginCreateAccountWindow.frame.origin;
    frameRect.origin.y -= frameRect.size.height - loginCreateAccountWindow.frame.size.height;
    frameRect.origin.x -= (frameRect.size.width - loginCreateAccountWindow.frame.size.width)/2;
    
    NSMutableArray *tempSubviews=[[NSMutableArray alloc]initWithArray:[loginCreateAccountWindow.contentView subviews]];
    [tempSubviews removeObjectAtIndex:1];
    [loginCreateAccountWindow.contentView setSubviews:tempSubviews];
    [loginCreateAccountWindow setFrame:frameRect display:YES animate:YES];
    [tempSubviews addObject:view];
    [loginCreateAccountWindow.contentView setSubviews:tempSubviews];
}
-(void) receiveSleepNotification:(NSNotification *)didSleep
{
    [self closeSocket];
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
- (void)menuNeedsUpdate:(NSMenu *)menu
{
    clickedRow=[self.targetTable clickedRow];
    if (clickedRow == -1)
    {
        clickedRow=[self.targetTable selectedRow];
    }
    if (clickedRow > -1)
    {
        [[contextMenu itemAtIndex:0] setEnabled:YES];
        [[contextMenu itemAtIndex:1] setEnabled:YES];
        [[contextMenu itemAtIndex:3] setEnabled:YES];
        [[contextMenu itemAtIndex:5] setEnabled:YES];
    }
    else
    {
        [[contextMenu itemAtIndex:0] setEnabled:NO];
        [[contextMenu itemAtIndex:1] setEnabled:NO];
        [[contextMenu itemAtIndex:3] setEnabled:NO];
        [[contextMenu itemAtIndex:5] setEnabled:NO];
    }
}
- (IBAction)signInOut:(id)sender
{
    if (!isSignedIn)
    {
        [self.usernameField setStringValue:@""];
        [self.passwordField setStringValue:@""];
    }
    else
    {
        [self signOut];
    }
}
-(void)closeSignInWindow
{
    [self.window makeKeyAndOrderFront:self];
    [loginCreateAccountWindow close];
}
-(void)signOut
{
    isSignedIn=NO;
    [self showLoginWindow];
    [self.accountInfoMenuItem setTitle:@"Not Signed In"];
    [self.signInMenuItem setTitle:@"Sign In..."];
    [targets removeAllObjects];
    [self.targetTable reloadData];
    [prefs setRememberedUser:@"" withPassword:@""];
    [self.window close];
    if (customTargetWindow)
    {
        [customTargetWindow close];
    }
    [self closeSocket];
    [self initSocket];
}

- (IBAction)login:(id)sender
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
        username=[self.usernameField stringValue];
        password=[self.passwordField stringValue];
        if ([self.rememberAccount state] == NSOnState)
        {
            [prefs setRememberedUser:username withPassword:password];
        }
        [self setLoginUI];
        [self sendToServer:[NSString stringWithFormat:@"loginas:%@,%@\n", username, password]];
    }
}
-(void)sendToServer:(NSString *)stringToSend
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        NSInteger err=0;
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
            [self handleError:-1];
        }
    });
}
-(void)initSocket
{
    isConnected=YES;
    [self.mainStatusLabel setStringValue:@"Connecting..."];
    [self.mainStatusIndicator setHidden:NO];
    [self.mainStatusIndicator startAnimation:self];
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
            [self.mainStatusLabel setStringValue:@"Connected"];
            [self.mainStatusIndicator setHidden:YES];
            [self.mainStatusIndicator stopAnimation:self];
            CFDataRef socketData = CFReadStreamCopyProperty((__bridge CFReadStreamRef)(inputStream), kCFStreamPropertySocketNativeHandle);
            CFSocketNativeHandle socket;
            CFDataGetBytes(socketData, CFRangeMake(0, sizeof(CFSocketNativeHandle)), (UInt8 *)&socket);
            CFRelease(socketData);
            
            int on = 1;
            if (setsockopt(socket, SOL_SOCKET, SO_KEEPALIVE, &on, sizeof(on)) == -1) {
                NSLog(@"setsockopt failed: %s", strerror(errno));
            }
            break;
        
		case NSStreamEventHasBytesAvailable:
        if (theStream == inputStream) {
            
            uint8_t buffer[8192];
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
        }
        break;
        
		case NSStreamEventErrorOccurred:
            isConnected=NO;
            NSLog(@"Stream Error");
            [self.mainStatusLabel setStringValue:@"Not Connected"];
            [self.mainStatusIndicator stopAnimation:self];
            [self.mainStatusIndicator setHidden:YES];
        break;
        
		case NSStreamEventEndEncountered:
            NSLog(@"Stream End");
            isConnected=NO;
            [self.mainStatusLabel setStringValue:@"Not Connected"];
            [self.mainStatusIndicator stopAnimation:self];
            [self.mainStatusIndicator setHidden:YES];
        break;
        
		default:
        NSLog(@"Unknown event");
	}
    
}
-(void)handleEvent:(NSString *)event
{
    if ([event rangeOfString:@"err-credentials-not-valid"].location != NSNotFound)
    {
        [self resetLoginUI];
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Username or Password Invalid"];
        [alert setInformativeText:@"The username or password you have entered is invalid."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else if ([event rangeOfString:@"login-valid"].location != NSNotFound)
    {
        isSignedIn=YES;
        [self closeSignInWindow];
        [self resetLoginUI];
        [self sendToServer:[NSString stringWithFormat:@"send-targets\n"]];
        [self.accountInfoMenuItem setTitle:[NSString stringWithFormat:@"Signed in as: %@", username]];
        [self.signInMenuItem setTitle:@"Sign Out"];
    }
    else if ([event rangeOfString:@"err-un-in-use"].location != NSNotFound)
    {
        [self resetLoginUI];
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Username Already In Use"];
        [alert setInformativeText:@"The username you have entered is already in use. Please choose a different one."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else if ([event rangeOfString:@"user-created"].location != NSNotFound)
    {
        [self closeSignInWindow];
        [self resetLoginUI];
        username=[self.desiredUsernameField stringValue];
        password=[self.desiredPasswordField stringValue];
        isSignedIn=YES;
        [self.accountInfoMenuItem setTitle:[NSString stringWithFormat:@"Signed in as: %@", username]];
        [self.signInMenuItem setTitle:@"Sign Out"];
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Account Created Successfully"];
        [alert setInformativeText:@"Your account has been created successfully and has been logged in."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else if ([event rangeOfString:@"targets:"].location != NSNotFound)
    {
        [targets removeAllObjects];
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
        [targets writeToFile:[applicationSupportDirectory stringByAppendingPathComponent:@"cachedTargets.plist"] atomically:YES];
        [self setTargetCount:targets.count];
        [self.targetTable reloadData];
    }
    else if ([event rangeOfString:@"voices:"].location != NSNotFound)
    {
        event = [event stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSArray *voices=[[event substringFromIndex:[event rangeOfString:@":"].location+1] componentsSeparatedByString:@","];
        [self.targetVoicesList removeAllItems];
        [self.targetVoicesList addItemsWithTitles:voices];
        [self.targetVoicesList selectItemWithTitle:[[targets objectAtIndex:clickedRow] objectForKey:@"selectedVoice"]];
        [self sendToServer:[NSString stringWithFormat:@"send-current-volume:%@\n", [[targets objectAtIndex:clickedRow] objectForKey:@"targetID"]]];
    }
    else if ([event rangeOfString:@"target-status-changed"].location != NSNotFound)
    {
        [self sendToServer:@"send-targets\n"];
    }
    else if ([event rangeOfString:@"volume:"].location != NSNotFound)
    {
        NSInteger volume=[[event substringFromIndex:[event rangeOfString:@":"].location+1] integerValue];
        [self.targetVolumeSlider setDoubleValue:volume];
    }
    else if ([event rangeOfString:@"update-result:"].location != NSNotFound)
    {
        NSString *targetID=[event substringWithRange:NSMakeRange([event rangeOfString:@":"].location+1, ([event rangeOfString:@";"].location) - ([event rangeOfString:@":"].location+1))];
        NSString *result=[event substringFromIndex:[event rangeOfString:@";"].location+1];
        result=[result stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
        if ([result rangeOfString:@"success"].location != NSNotFound)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Update Successful"];
            [alert setInformativeText:[NSString stringWithFormat:@"Target \"%@\" was updated successfully.", [self getTargetNameFromID:targetID]]];
            [alert addButtonWithTitle:@"OK"];
            [alert runModal];
        }
        else
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Update Is Latest"];
            [alert setInformativeText:[NSString stringWithFormat:@"Target \"%@\" is already running the latest version.", [self getTargetNameFromID:targetID]]];
            [alert addButtonWithTitle:@"OK"];
            [alert runModal];
        }
    }
    else if([event rangeOfString:@"send-audio-data"].location != NSNotFound)
    {
        NSLog(@"Sending audio data...");
        [self sendAudioDataToServer:audioDataToSend];
    }
}
-(void)setLoginUI
{
    //Login View
    [self.logInStatusIndicator setHidden:NO];
    [self.logInStatusIndicator startAnimation:self];
    [self.logInStatusLabel setHidden:NO];
    [self.loginModeSelection setEnabled:NO];
    [self.usernameField setEnabled:NO];
    [self.passwordField setEnabled:NO];
    [self.loginButton setEnabled:NO];
    [self.rememberAccount setEnabled:NO];
    
    //Create Account View
    [self.createAccountStatusIndicator setHidden:NO];
    [self.createAccountStatusIndicator startAnimation:self];
    [self.createAccountStatusLabel setHidden:NO];
    [self.createAccountButton setEnabled:NO];
    [self.desiredUsernameField setEnabled:NO];
    [self.desiredPasswordField setEnabled:NO];
    [self.confirmPasswordField setEnabled:NO];
    [self.desiredEmailField setEnabled:NO];
}
-(void)resetLoginUI
{
    //Login View
    [self.logInStatusIndicator setHidden:YES];
    [self.logInStatusIndicator stopAnimation:self];
    [self.logInStatusLabel setHidden:YES];
    [self.loginModeSelection setEnabled:YES];
    [self.usernameField setEnabled:YES];
    [self.passwordField setEnabled:YES];
    [self.loginButton setEnabled:YES];
    [self.rememberAccount setEnabled:YES];
    
    //Create Account View
    [self.createAccountStatusIndicator setHidden:YES];
    [self.createAccountStatusIndicator stopAnimation:self];
    [self.createAccountStatusLabel setHidden:YES];
    [self.createAccountButton setEnabled:YES];
    [self.desiredUsernameField setEnabled:YES];
    [self.desiredPasswordField setEnabled:YES];
    [self.confirmPasswordField setEnabled:YES];
    [self.desiredEmailField setEnabled:YES];
}
-(NSString *)getTargetNameFromID:(NSString *)targetID
{
    for (int i=0; i<targets.count; i++)
    {
        if ([[[targets objectAtIndex:i]objectForKey:@"targetID"] isEqualToString:targetID])
        {
            return [[targets objectAtIndex:i] objectForKey:@"targetName"];
        }
    }
    return @"";
}
-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}
- (IBAction)createNewAccount:(id)sender
{
    if ([[self.desiredUsernameField stringValue]isEqualToString:@""] || [[self.desiredPasswordField stringValue]isEqualToString:@""] || [[self.confirmPasswordField stringValue]isEqualToString:@""] || [[self.desiredEmailField stringValue]isEqualToString:@""])
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Invalid Entry"];
        [alert setInformativeText:@"Please enter all the requested information to make an account."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else if (![[self.desiredPasswordField stringValue]isEqualToString:[self.confirmPasswordField stringValue]])
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Passwords Don't Match"];
        [alert setInformativeText:@"Please ensure your password and confirmation are the same to continue."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else if ([[self.desiredEmailField stringValue]rangeOfString:@"@"].location == NSNotFound || [[self.desiredEmailField stringValue]rangeOfString:@"."].location == NSNotFound)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Invalid Email Address"];
        [alert setInformativeText:@"Please enter a valid email address to continue."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else
    {
        [self sendToServer:[NSString stringWithFormat:@"newuser:%@,%@\n", [self.desiredUsernameField stringValue], [self.desiredPasswordField stringValue]]];
        [self setLoginUI];
    }
}
-(void)handleError:(int)errorNum
{
    if (errorNum == -1)
    {
        [self.mainStatusLabel setStringValue:@"Not Connected"];
        [self.mainStatusIndicator stopAnimation:self];
        [self.mainStatusIndicator setHidden:YES];
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Cannot Connect to Server"];
        [alert setInformativeText:@"The Remote Speech Server is unreachable. Check your Internet connection and try again."];
        [alert addButtonWithTitle:@"OK"];
        [alert performSelectorOnMainThread:@selector(runModal) withObject:nil waitUntilDone:NO];
        [self resetLoginUI];
        isConnected=NO;
    }
}
- (IBAction)closeTargetSettingsView:(id)sender
{
    [NSApp endSheet:self.targetInfoView];
    [self.targetInfoView orderOut:sender];
}
-(IBAction)showTargetInfoView:(id)sender
{
    clickedRow=[self.targetTable clickedRow];
    if (clickedRow == -1)
    {
        clickedRow=[self.targetTable selectedRow];
    }
    NSIndexSet *clickedRows=[self.targetTable selectedRowIndexes];
    if (clickedRow>-1 && clickedRows.count<=1)
    {
        [self sendToServer:[NSString stringWithFormat:@"send-voices-list:%@\n", [[targets objectAtIndex:clickedRow]objectForKey:@"targetID"]]];
        [self.targetIDLabel setStringValue:[NSString stringWithFormat:@"Target ID: %@", [[targets objectAtIndex:clickedRow]objectForKey:@"targetID"]]];
        
        if ([[[targets objectAtIndex:clickedRow]objectForKey:@"status"] isEqualToString:@"Offline"])
        {
            [self.targetVoicesList setEnabled:NO];
            [self.targetVolumeSlider setEnabled:NO];
        }
        else
        {
            [self.targetVoicesList setEnabled:YES];
            [self.targetVolumeSlider setEnabled:YES];
        }
        
        [NSApp beginSheet:self.targetInfoView
           modalForWindow:(NSWindow *)_window
            modalDelegate:self
           didEndSelector:nil
              contextInfo:nil];
    }
}
- (IBAction)sendMessage:(id)sender
{
    NSString *message=[self.messageField stringValue];
    message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    NSIndexSet *targetIndices=[self.targetTable selectedRowIndexes];
    if ([message isEqualToString:@""])
    {
        [self.mainStatusLabel setStringValue:@"No Text Entered"];
        [self resetMainStatusLabelWithDelay:2];
    }
    else if (targetIndices.count < 1)
    {
        [self.mainStatusLabel setStringValue:@"No Targets Selected"];
        [self resetMainStatusLabelWithDelay:2];
    }
    else
    {
        NSUInteger lastIndex=[targetIndices firstIndex];
        NSString *msgToSend=@"sendmessage:";
        for (int i=0; i<targetIndices.count; i++)
        {
            msgToSend=[msgToSend stringByAppendingString:[[targets objectAtIndex:lastIndex]objectForKey:@"targetID"]];
            if (i!=targetIndices.count-1)
            {
                msgToSend=[msgToSend stringByAppendingString:@","];
            }
            lastIndex=[targetIndices indexGreaterThanIndex:lastIndex];
        }
        msgToSend=[msgToSend stringByAppendingString:[NSString stringWithFormat:@";say:%@\n", message]];
        [self sendToServer:msgToSend];
        if (isConnected)
        {
            [self.mainStatusLabel setStringValue:@"Sent"];
            [self resetMainStatusLabelWithDelay:1];
        }
    }
}
-(IBAction)removeTarget:(id)sender
{
    NSIndexSet *clickedRows=[self.targetTable selectedRowIndexes];
    clickedRow=[self.targetTable clickedRow];
    if (clickedRow == -1)
    {
        clickedRow=[self.targetTable selectedRow];
    }
    if (clickedRow>-1 && clickedRows.count<=1)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Delete Target"];
        [alert setInformativeText:[NSString stringWithFormat:@"Are you sure you want to delete the target \"%@\"?", [[targets objectAtIndex:clickedRow] objectForKey:@"targetName"]]];
        [alert addButtonWithTitle:@"Yes"];
        [alert addButtonWithTitle:@"Cancel"];
        if ([alert runModal] == NSAlertFirstButtonReturn)
        {
            [self sendToServer:[NSString stringWithFormat:@"delete-target:%@\n", [[targets objectAtIndex:clickedRow] objectForKey:@"targetID"]]];
        }
    }
}
- (IBAction)setVolume:(id)sender
{
    [self sendToServer:[NSString stringWithFormat:@"setvolume:%@;%ld\n", [[targets objectAtIndex:clickedRow]objectForKey:@"targetID"], (NSInteger)[self.targetVolumeSlider doubleValue]]];
}

- (IBAction)setVoice:(id)sender
{
    [self sendToServer:[NSString stringWithFormat:@"setvoice:%@;%@\n", [[targets objectAtIndex:clickedRow]objectForKey:@"targetID"], [self.targetVoicesList titleOfSelectedItem]]];
}
- (IBAction)showManualTargetView:(id)sender
{
    if (isSignedIn)
    {
        [self.manualTargetIDField setStringValue:@""];
        [self.manualTargetNameField setStringValue:@""];
        [NSApp beginSheet:self.manualTargetView
           modalForWindow:(NSWindow *)_window
            modalDelegate:self
           didEndSelector:nil
              contextInfo:nil];
    }
    else
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Not Signed In"];
        [alert setInformativeText:@"You must be signed in to perform this action."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
}
- (IBAction)showCustomTargetWindow:(id)sender
{
    if (isSignedIn)
    {
        if (!customTargetWindow)
        {
            customTargetWindow = [[CustomTargetWindow alloc] initWithWindowNibName:@"CustomTargetWindow"];
            customTargetWindow.delegate=self;
        }
        [customTargetWindow resetOptions:self];
        [customTargetWindow showWindow:self];
    }
    else
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Not Signed In"];
        [alert setInformativeText:@"You must be signed in to perform this action."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
}
- (IBAction)updateSelectedTarget:(id)sender
{
    NSIndexSet *targetIndices=[self.targetTable selectedRowIndexes];
    if (targetIndices.count < 1)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"No Target Selected"];
        [alert setInformativeText:@"Please select at least one target to update."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else
    {
        NSUInteger lastIndex=[targetIndices firstIndex];
        NSString *msgToSend=@"sendmessage:";
        for (int i=0; i<targetIndices.count; i++)
        {
            msgToSend=[msgToSend stringByAppendingString:[[targets objectAtIndex:lastIndex]objectForKey:@"targetID"]];
            if (i!=targetIndices.count-1)
            {
                msgToSend=[msgToSend stringByAppendingString:@","];
            }
            lastIndex=[targetIndices indexGreaterThanIndex:lastIndex];
        }
        msgToSend=[msgToSend stringByAppendingString:[NSString stringWithFormat:@";begin-update\n"]];
        [self sendToServer:msgToSend];
    }
}
- (IBAction)addTargetManually:(id)sender
{
    if ([self.manualTargetIDField stringValue].length != 6)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Invalid Target ID"];
        [alert setInformativeText:@"A valid Target ID consists of 6 digits."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else if ([[self.manualTargetNameField stringValue] isEqualToString:@""])
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"No Target Name"];
        [alert setInformativeText:@"You must enter a Target Name to continue."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else if ([self doesTargetIDExist:[self.manualTargetIDField stringValue]])
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Target Already Exists"];
        [alert setInformativeText:@"The specified target is already present in your list."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else
    {
        [self sendToServer:[NSString stringWithFormat:@"add-target:%@,%@\n", [self.manualTargetIDField stringValue], [self.manualTargetNameField stringValue]]];
        [self closeManualTargetSheet:self];
    }
}
-(BOOL)doesTargetIDExist:(NSString *)targetID
{
    for (int i=0; i<targets.count; i++)
    {
        if ([[[targets objectAtIndex:i]objectForKey:@"targetID"] isEqualToString:targetID])
        {
            return YES;
        }
    }
    return NO;
}
- (IBAction)closeManualTargetSheet:(id)sender
{
    [NSApp endSheet:self.manualTargetView];
    [self.manualTargetView orderOut:sender];
}
- (void)addTargetToAccount:(NSString *)targetID withName:(NSString *)targetName //Delegated Method
{
    [self sendToServer:[NSString stringWithFormat:@"add-target:%@,%@\n", targetID, targetName]];
}
- (void)didFinishTutorial
{
    [prefs setFinishedTutorial:YES];
}
-(IBAction)showPrefsWindow:(id)sender
{
    if (!prefsWindow) {
        prefsWindow = [[PreferencesWindow alloc] init];
    }
    [prefsWindow.window center];
    [prefsWindow.window makeKeyAndOrderFront:self];
    [prefsWindow.window setOrderedIndex:0];
}
-(IBAction)beginRenameTarget:(id)sender
{
    NSIndexSet *clickedRows=[self.targetTable selectedRowIndexes];
    clickedRow=[self.targetTable clickedRow];
    if (clickedRow == -1)
    {
        clickedRow=[self.targetTable selectedRow];
    }
    if (clickedRow>-1 && clickedRows.count<=1)
    {
        [self.targetTable editColumn:0 row:clickedRow withEvent:nil select:YES];
    }
}
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if ([(NSString *)anObject isEqualToString:@""])
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"No Target Name Entered"];
        [alert setInformativeText:@"You must enter a new name for the target to continue."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else
    {
        [self sendToServer:[NSString stringWithFormat:@"rename-target:%@;%@\n", [[targets objectAtIndex:rowIndex] objectForKey:@"targetID"], anObject]];
    }
}
- (IBAction)checkForUpdate:(id)sender
{
    [updateController checkForUpdateByUser:YES];
}
- (IBAction)quitApplication:(id)sender
{
    [[NSApplication sharedApplication] terminate:nil];
}
- (CGFloat)     splitView:(NSSplitView *)splitView
   constrainMinCoordinate:(CGFloat)proposedMin
              ofSubviewAt:(NSInteger)dividerIndex
{
    return 70.0;
}

- (CGFloat)     splitView:(NSSplitView *)splitView
   constrainMaxCoordinate:(CGFloat)proposedMin
              ofSubviewAt:(NSInteger)dividerIndex
{
    return splitView.frame.size.height - 70.0;
}
-(void)resetMainStatusLabelWithDelay:(NSInteger)time
{
    NSString *textToSet=@"";
    if (isConnected)
    {
        textToSet=@"Connected";
    }
    else
    {
        textToSet=@"Not Connected";
    }
    [self.mainStatusLabel performSelector:@selector(setStringValue:) withObject:textToSet afterDelay:time];
}
-(void)setTargetCount:(NSInteger)count
{
    NSString *s=@"Targets";
    if (count == 1)
    {
        s=@"Target";
    }
    [self.targetAmountLabel setStringValue:[NSString stringWithFormat:@"%ld %@", count, s]];
}
-(void)beginPlayingAudio
{
    
    NSIndexSet *clickedRows=[self.targetTable selectedRowIndexes];
    clickedRow=[self.targetTable clickedRow];
    if (clickedRow == -1)
    {
        clickedRow=[self.targetTable selectedRow];
    }
    if (clickedRow>-1 && clickedRows.count<=1)
    {
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setCanChooseFiles:YES];
        [panel setCanChooseDirectories:NO];
        [panel setAllowsMultipleSelection:NO];
        //[panel setAllowedFileTypes:[NSArray arrayWithObject:@"app"]];
        
        [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
            if (result == NSFileHandlingPanelOKButton)
            {
                NSArray* files = [panel URLs];
                NSString *filePath = [[files objectAtIndex:0]path];
                NSData* audioFileData = [NSData dataWithContentsOfFile:filePath];
                audioDataToSend = audioFileData;
                sentAudioFileName = [filePath lastPathComponent];
                [self sendToServer:[NSString stringWithFormat:@"send-audio-to-target:%@;%lu;%@\n", [[targets objectAtIndex:clickedRow] objectForKey:@"targetID"], audioFileData.length, [filePath lastPathComponent]]];
            }
        }];
    }
}
-(void)sendAudioDataToServer:(NSData *)audioFileData
{
    [self.audioSendingProgress setMaxValue:100.0];
    [self.audioSendingProgress setMinValue:0];
    [self.audioSendingProgress setDoubleValue:0];
    [NSApp beginSheet:self.sendingAudioPanel
       modalForWindow:(NSWindow *)_window
        modalDelegate:self
       didEndSelector:nil
          contextInfo:nil];
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
            
            double percent = (bytesWritten*1.0/fileSize*1.0)*100;
            [self.audioSendingProgress setDoubleValue:percent];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSApp endSheet:self.sendingAudioPanel];
            [self.sendingAudioPanel orderOut:self];
            [self.mainStatusLabel setStringValue:[NSString stringWithFormat:@"Playing file \"%@\"", sentAudioFileName]];
            [self resetMainStatusLabelWithDelay:3];
        });
    });
}
@end
