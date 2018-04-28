//
//  AppDelegate.h
//  Remote Speech
//
//  Created by Collin Mistr on 12/21/16.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CustomTargetWindow.h"
#import "FirstRunView.h"
#import "PreferencesWindow.h"
#import "UpdateController.h"
#import "PreferencesHandler.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSStreamDelegate, NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate, CustomTargetDelegate, FirstRunViewDelegate, NSSplitViewDelegate>
{
    CustomTargetWindow *customTargetWindow;
    FirstRunView *firstRunView;
    PreferencesWindow *prefsWindow;
    UpdateController *updateController;
    PreferencesHandler *prefs;
    NSWindow *loginCreateAccountWindow;
    NSInputStream *inputStream;
	NSOutputStream *outputStream;
    BOOL isSignedIn;
    NSString *username;
    NSString *password;
    NSMenu *contextMenu;
    NSMutableArray *targets;
    NSInteger clickedRow;
    BOOL isConnected;
    NSString *applicationSupportDirectory;
    NSData *audioDataToSend;
    NSString *sentAudioFileName;
}



@property (assign) IBOutlet NSWindow *window;
- (IBAction)signInOut:(id)sender;
- (IBAction)login:(id)sender;
@property (strong) IBOutlet NSView *signInView;
@property (strong) IBOutlet NSView *createAccountView;
@property (strong) IBOutlet NSView *mainWindowView;
@property (strong) IBOutlet NSMatrix *loginModeSelection;
- (IBAction)quitApplication:(id)sender;
@property (strong) IBOutlet NSProgressIndicator *logInStatusIndicator;
@property (strong) IBOutlet NSTextField *logInStatusLabel;
@property (strong) IBOutlet NSButton *loginButton;
@property (strong) IBOutlet NSButton *createAccountButton;
@property (strong) IBOutlet NSTextField *createAccountStatusLabel;
@property (strong) IBOutlet NSProgressIndicator *createAccountStatusIndicator;

@property (strong) IBOutlet NSTextField *usernameField;
@property (strong) IBOutlet NSSecureTextField *passwordField;
@property (strong) IBOutlet NSButton *rememberAccount;
@property (strong) IBOutlet NSMenuItem *signInMenuItem;
@property (strong) IBOutlet NSMenuItem *accountInfoMenuItem;
- (IBAction)createNewAccount:(id)sender;
@property (strong) IBOutlet NSTextField *desiredUsernameField;
@property (strong) IBOutlet NSSecureTextField *desiredPasswordField;
@property (strong) IBOutlet NSSecureTextField *confirmPasswordField;
@property (strong) IBOutlet NSTextField *desiredEmailField;
@property (strong) IBOutlet NSTableView *targetTable;
@property (strong) IBOutlet NSPanel *targetInfoView;
- (IBAction)closeTargetSettingsView:(id)sender;
@property (strong) IBOutlet NSTextField *messageField;
- (IBAction)sendMessage:(id)sender;
@property (strong) IBOutlet NSPopUpButton *targetVoicesList;
@property (strong) IBOutlet NSSlider *targetVolumeSlider;
- (IBAction)setVolume:(id)sender;
- (IBAction)setVoice:(id)sender;
- (IBAction)showManualTargetView:(id)sender;
- (IBAction)showCustomTargetWindow:(id)sender;
- (IBAction)updateSelectedTarget:(id)sender;
@property (strong) IBOutlet NSPanel *manualTargetView;
@property (strong) IBOutlet NSTextField *manualTargetIDField;
@property (strong) IBOutlet NSTextField *manualTargetNameField;
- (IBAction)addTargetManually:(id)sender;
- (IBAction)closeManualTargetSheet:(id)sender;
@property (strong) IBOutlet NSScrollView *targetTableView;
@property (strong) IBOutlet NSTextField *targetIDLabel;
- (IBAction)removeTarget:(id)sender;
- (IBAction)showTargetInfoView:(id)sender;
- (IBAction)showPrefsWindow:(id)sender;
- (IBAction)beginRenameTarget:(id)sender;
@property (strong) IBOutlet NSSplitView *splitView;
- (IBAction)checkForUpdate:(id)sender;
@property (strong) IBOutlet NSProgressIndicator *mainStatusIndicator;
@property (strong) IBOutlet NSTextField *mainStatusLabel;
@property (strong) IBOutlet NSTextField *targetAmountLabel;

@property (strong) IBOutlet NSPanel *sendingAudioPanel;
@property (strong) IBOutlet NSProgressIndicator *audioSendingProgress;

@end
