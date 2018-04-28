//
//  NoMenuTextField.m
//  Remote Speech
//
//  Created by Collin Mistr on 5/19/17.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import "NoMenuTextField.h"

@implementation NoMenuTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return NO;
}

@end
