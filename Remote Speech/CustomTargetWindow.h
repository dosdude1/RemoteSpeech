//
//  CustomTargetWindow.h
//  Remote Speech
//
//  Created by Collin Mistr on 12/28/16.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol CustomTargetDelegate <NSObject>
@optional
- (void)addTargetToAccount:(NSString *)targetID withName:(NSString *)targetName;

@end

@interface CustomTargetWindow : NSWindowController <NSTextFieldDelegate>
{
    NSString *targetSettingsPlistPath;
    NSString *targetInfoPlistPath;
    NSString *applicationSupportDirectory;
}

@property (nonatomic, strong) id <CustomTargetDelegate> delegate;
@property (strong) IBOutlet NSImageView *backgroundImageView;
@property (strong) IBOutlet NSTextField *appLabel;
@property (strong) IBOutlet NSImageView *appIconImage;
@property (strong) IBOutlet NSTextField *appLabelField;
@property (strong) IBOutlet NSTextField *customIconField;
- (IBAction)browseForIcon:(id)sender;
@property (strong) IBOutlet NSTextField *targetNameField;
@property (strong) IBOutlet NSButton *launchAtLogin;
@property (strong) IBOutlet NSButton *relaunchIfQuit;
@property (strong) IBOutlet NSButton *hideApplication;
- (IBAction)resetOptions:(id)sender;
- (IBAction)closeWindow:(id)sender;
- (IBAction)createAndAddToAccount:(id)sender;
- (IBAction)customIconFieldReturnAction:(id)sender;


@end
