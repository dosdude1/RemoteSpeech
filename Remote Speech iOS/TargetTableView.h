//
//  TargetTableView.h
//  Remote Speech
//
//  Created by Collin Mistr on 1/3/17.
//  Copyright (c) 2017 Got 'Em Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteSpeechController.h"
#import "TargetViewController.h"
#import "AddTargetView.h"
#import "TargetCell.h"
#import "SettingsView.h"
#import "PreferencesHandler.h"

@interface TargetTableView : UITableViewController <RemoteSpeechControllerTargetTableDelegate>
{
    RemoteSpeechController *main;
    UINavigationBar *navBar;
    NSMutableArray *targets;
    TargetViewController *targetView;
    AddTargetView *addTargetView;
    NSInteger selectedIndex;
    UIBarButtonItem *editButton;
    UIBarButtonItem *doneButton;
    UIBarButtonItem *addTargetButton;
    UINavigationController *addTargetViewNavController;
    BOOL darkModeEnabled;
    UIColor *defaultBackgroundColor;
    float IOS_VERSION;
    UIBarButtonItem *settingsButton;
    SettingsView *settingsView;
    UINavigationController *settingsViewNavController;
}
-(id)initWithMainController:(RemoteSpeechController *)inMain withNavigationBar:(UINavigationBar *)inNavBar;
-(void)setDarkModeEnabled:(BOOL)enabled;
@end
