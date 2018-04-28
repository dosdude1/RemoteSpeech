//
//  AppDelegate.h
//  Remote Speech iOS
//
//  Created by Collin Mistr on 12/31/16.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PreferencesHandler.h"

#import "iPadTableViewController.h"
#import "iPadTargetViewController.h"
#import "RemoteSpeechController.h"
#import "iPadLoginView.h"
//iPhone
#import "LoginViewController.h"
#import "TargetTableView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UISplitViewControllerDelegate, iPadLoginViewDelegate, LoginViewDelegate, PreferencesHandlerDarkModeDelegate>
{
    RemoteSpeechController *main;
    NSString *documentsDirectory;
    BOOL shouldRotate;
    iPadLoginView *ipadLoginView;
    LoginViewController *iphoneLoginView;
    TargetTableView *mainiPhoneView;
}
@property (strong, nonatomic) UIWindow *window;

@end
