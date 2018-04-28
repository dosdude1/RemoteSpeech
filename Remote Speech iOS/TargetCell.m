//
//  TargetCell.m
//  Remote Speech
//
//  Created by Collin Mistr on 5/21/17.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import "TargetCell.h"

@implementation TargetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        IOS_VERSION = [[[UIDevice currentDevice] systemVersion] floatValue];
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
- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(10,12,19,19);
    self.textLabel.frame = CGRectMake(40, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
    if (IOS_VERSION >= 7.0)
    {
        [super setSeparatorInset:UIEdgeInsetsMake(self.separatorInset.top, 20, self.separatorInset.bottom, self.separatorInset.right)];
    }
}
@end
