//
//  SettingsView.h
//  Remote Speech
//
//  Created by Collin Mistr on 6/7/17.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PreferencesHandler.h"
#import "SettingsTableCell.h"

typedef enum
{
    sectionGeneral = 0,
    sectionAccount = 1
}section;

typedef enum
{
    alertAccountActions = 0
}alert;


@interface SettingsView : UITableViewController <UIAlertViewDelegate>
{
    UIBarButtonItem *doneButton;
    UISwitch *darkModeSwitch;
    BOOL darkModeEnabled;
    float IOS_VERSION;
    UIColor *defaultBackgroundColor;
    NSInteger numberOfSections;
}

-(id)init;
-(id)initWithStyle:(UITableViewStyle)style;
-(void)setDarkModeEnabled:(BOOL)enabled;

@end
