//
//  UpdatePreferences.h
//  Remote Speech
//
//  Created by Collin Mistr on 1/28/17.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesHandler.h"

@interface UpdatePreferences : NSViewController
{
    NSString *identifier;
    PreferencesHandler *prefs;
}

-(id)init;
-(NSString *)getIdentifier;
-(NSView *)getView;
@property (strong) IBOutlet NSMatrix *updateSelection;

@end
