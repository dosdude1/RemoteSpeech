//
//  UpdatePreferences.m
//  Remote Speech
//
//  Created by Collin Mistr on 1/28/17.
//  Copyright (c) 2017 Got 'Em Apps. All rights reserved.
//

#import "UpdatePreferences.h"

@interface UpdatePreferences ()

@end

@implementation UpdatePreferences

-(id)init
{
    self=[super initWithNibName:@"UpdatePreferences" bundle:nil];
    [self loadView];
    identifier=@"Updates";
    prefs=[PreferencesHandler sharedInstance];
    [self.updateSelection selectCell:[self.updateSelection cellWithTag:[prefs getUpdateStatus]]];
    [self.updateSelection setTarget:self];
    [self.updateSelection setAction:@selector(setUpdatePreference)];
    return self;
}
-(void)setUpdatePreference
{
    [prefs setUpdateStatus:(int)[[self.updateSelection selectedCell] tag]];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}
-(NSString *)getIdentifier
{
    return identifier;
}
-(NSView *)getView
{
    return self.view;
}
@end
