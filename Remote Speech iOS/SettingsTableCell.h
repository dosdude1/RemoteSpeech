//
//  SettingsTableCell.h
//  Remote Speech
//
//  Created by Collin Mistr on 6/25/17.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableCell : UITableViewCell
{
    
}
@property (strong) UIColor *lightModeTextColor;
@property (strong) UIColor *darkModeTextColor;
@property (strong) UIColor *lightModeBackgroundColor;
@property (strong) UIColor *darkModeBackgroundColor;

-(void)setDarkModeEnabled:(BOOL)enabled;

@end
