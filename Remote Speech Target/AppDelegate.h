//
//  AppDelegate.h
//  Remote Speech Target
//
//  Created by Collin Mistr on 12/25/16.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GSStartup.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSStreamDelegate, NSURLConnectionDelegate>
{
    NSInputStream *inputStream;
	NSOutputStream *outputStream;
    NSMutableDictionary *settings;
    NSString *appPath;
    NSString *settingsPlistPath;
    NSMutableDictionary *infoPlist;
    NSSpeechSynthesizer *speech;
    BOOL isHidden;
    NSTimer *connectionTimer;
    NSMutableData *fileData;
    NSString *applicationSupportDirectory;
    int connectionNum;
    BOOL updateIsAvailable;
    BOOL relaunchTriggered;
    BOOL gotHeartbeat;
    NSTimer *heartbeatTimer;
    BOOL receivingRawData;
    NSMutableData *audioData;
    NSInteger audioFileSize;
    NSString *audioFileName;
    AVAudioPlayer *audioPlayer;
    NSTimer *dataReceiveTimeout;
}
@property (strong) id activity;
@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSTextField *usernameField;
@property (strong) IBOutlet NSSecureTextField *passwordField;
@property (strong) IBOutlet NSTextField *targetNameField;
@property (strong) IBOutlet NSButton *launchAtLogin;
@property (strong) IBOutlet NSButton *launchIfQuit;
@property (strong) IBOutlet NSButton *hideDockIcon;
@property (strong) IBOutlet NSButton *signInButton;
@property (strong) IBOutlet NSButton *addToAccountButton;
- (IBAction)signIn:(id)sender;
- (IBAction)quitProgram:(id)sender;
- (IBAction)setAndAddToAccount:(id)sender;

@end
