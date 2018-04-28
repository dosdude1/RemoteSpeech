//
//  PreferencesWindow.m
//  Remote Speech
//
//  Created by Collin Mistr on 1/21/17.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import "PreferencesWindow.h"

@interface PreferencesWindow ()

@end

@implementation PreferencesWindow

-(id)init
{
    self=[super init];
    self.window=[[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 645, 175)
                                            styleMask:(NSTitledWindowMask | NSClosableWindowMask)
                                              backing:NSBackingStoreBuffered defer:YES];
    [self.window setTitle:@"Preferences"];
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"PreferencesToolbar"];
    
    [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
    [toolbar setAllowsUserCustomization:NO];
    [toolbar setDelegate:self];
    [toolbar setAutosavesConfiguration:NO];
    
    [self.window setToolbar:toolbar];
    
    [self initPrefsModules];
    [self setUpToolbar];
    
    [self changeToModule:@"Updates"];
    
    return self;
}
-(void)setUpToolbar
{
    NSToolbar *toolbar=self.window.toolbar;
    
    if (toolbar) {
        NSInteger index = toolbar.items.count - 1;
        
        while (index > 0)
            [toolbar removeItemAtIndex:index--];
        
        // Add the new items.
        for (int i=0; i<prefsModules.count; i++)
        {
            [toolbar insertItemWithItemIdentifier:[[prefsModules objectAtIndex:i] getIdentifier] atIndex:toolbar.items.count];
        }
    }
}
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    
}
-(void)initPrefsModules
{
    prefsModules=[[NSArray alloc] initWithObjects:[[UpdatePreferences alloc]init], nil];
}
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    NSMutableArray *identifiers = [NSMutableArray array];
    
    for (int i=0; i<prefsModules.count; i++)
    {
        [identifiers addObject:[[prefsModules objectAtIndex:i]getIdentifier]];
    }
    
    return identifiers;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return nil;
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
    return [self toolbarAllowedItemIdentifiers:toolbar];
}
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    
    [item setLabel:@"Updates"];
    [item setImage:[NSImage imageNamed:NSImageNamePreferencesGeneral]];
    [item setTarget:self];
    [item setAction:@selector(selectModule:)];
    
    return item;
}
- (void)selectModule:(NSToolbarItem *)sender
{
    [self changeToModule:[sender itemIdentifier]];
}
-(void)changeToModule:(NSString *)identifier
{
    int prefIndex=-1;
    for (int i=0; i<prefsModules.count; i++)
    {
        if ([identifier isEqualToString:[[prefsModules objectAtIndex:i]getIdentifier]])
        {
            prefIndex=i;
        }
    }
    if (prefIndex>-1)
    {
        [self.window.toolbar setSelectedItemIdentifier:[[prefsModules objectAtIndex:prefIndex]getIdentifier]];
        CGRect newView=[[[prefsModules objectAtIndex:prefIndex] getView] frame];
        NSRect newWindowFrame = [self.window frameRectForContentRect:newView];
        newWindowFrame.origin = self.window.frame.origin;
        newWindowFrame.origin.y -= newWindowFrame.size.height - self.window.frame.size.height;
        [self.window setFrame:newWindowFrame display:YES animate:YES];
        [self.window.contentView setSubviews:[NSArray arrayWithObject:[[prefsModules objectAtIndex:prefIndex] getView]]];
    }
}
@end
