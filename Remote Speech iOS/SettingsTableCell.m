//
//  SettingsTableCell.m
//  Remote Speech
//
//  Created by Collin Mistr on 6/25/17.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import "SettingsTableCell.h"

@implementation SettingsTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.darkModeBackgroundColor = [UIColor blackColor];
        self.lightModeBackgroundColor = [UIColor whiteColor];
        self.darkModeTextColor = [UIColor whiteColor];
        self.lightModeTextColor = [UIColor blackColor];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setDarkModeEnabled:(BOOL)enabled
{
    if (enabled)
    {
        [self setBackgroundColor:self.darkModeBackgroundColor];
        [self.textLabel setTextColor:self.darkModeTextColor];
    }
    else
    {
        [self setBackgroundColor:self.lightModeBackgroundColor];
        [self.textLabel setTextColor:self.lightModeTextColor];
    }
}
@end
