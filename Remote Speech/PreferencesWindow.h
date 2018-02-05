//
//  PreferencesWindow.h
//  Remote Speech
//
//  Created by Collin Mistr on 1/21/17.
//  Copyright (c) 2017 Got 'Em Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UpdatePreferences.h"

@interface PreferencesWindow : NSWindowController <NSToolbarDelegate>
{
    NSArray *prefsModules;
}

-(id)init;

@end
