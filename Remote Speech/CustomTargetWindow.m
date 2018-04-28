//
//  CustomTargetWindow.m
//  Remote Speech
//
//  Created by Collin Mistr on 12/28/16.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import "CustomTargetWindow.h"

@interface CustomTargetWindow ()

@end

@implementation CustomTargetWindow

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
    
    [self.appLabelField setStringValue:[self.appLabel stringValue]];
    [self.appLabelField setDelegate:self];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    applicationSupportDirectory = [[paths firstObject] stringByAppendingPathComponent:@"Remote Speech"];
    targetSettingsPlistPath=[applicationSupportDirectory stringByAppendingPathComponent:@"Remote Speech Target.app/Contents/Resources/settings.plist"];
    targetInfoPlistPath=[applicationSupportDirectory stringByAppendingPathComponent:@"Remote Speech Target.app/Contents/Info.plist"];
}
- (void)controlTextDidChange:(NSNotification *)notification {
    if ([notification object] == self.appLabelField)
    {
        [self.appLabel setStringValue:[self.appLabelField stringValue]];
    }
}
- (IBAction)browseForIcon:(id)sender
{
    NSOpenPanel *iconBrowser = [NSOpenPanel openPanel];
    [iconBrowser setCanChooseFiles:YES];
    [iconBrowser setCanChooseDirectories:NO];
    [iconBrowser setAllowsMultipleSelection:NO];
    [iconBrowser setAllowedFileTypes:[NSArray arrayWithObject:@"icns"]];
    
    NSInteger clicked = [iconBrowser runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        for (NSURL *url in [iconBrowser URLs]) {
            [self setAppIcon:[[url path]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [self.customIconField setStringValue:[[url path] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
    }
}
-(void)setAppIcon:(NSString *)imagePath
{
    [self.appIconImage setImage:[[NSImage alloc] initWithContentsOfFile:imagePath]];
}
- (IBAction)resetOptions:(id)sender
{
    [self.targetNameField setStringValue:@""];
    [self.appLabelField setStringValue:@"Remote Speech Target"];
    [self.appLabel setStringValue:@"Remote Speech Target"];
    [self.customIconField setStringValue:@""];
    [self.appIconImage setImage:[NSImage imageNamed:@"app-icon"]];
    [self.launchAtLogin setState:NSOffState];
    [self.relaunchIfQuit setState:NSOffState];
    [self.hideApplication setState:NSOffState];
}

- (IBAction)closeWindow:(id)sender
{
    [self.window close];
}

- (IBAction)createAndAddToAccount:(id)sender
{
    if ([[self.targetNameField stringValue] isEqualToString:@""])
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Target Name not Specified"];
        [alert setInformativeText:@"You must specify a target name to continue."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else if ([[self.appLabelField stringValue]isEqualToString:@""])
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Application Name not Specified"];
        [alert setInformativeText:@"You must set an application name to continue."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else
    {
        [[NSFileManager defaultManager]copyItemAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Remote Speech Target.app"] toPath:[applicationSupportDirectory stringByAppendingPathComponent:@"Remote Speech Target.app"] error:nil];
        NSMutableDictionary *settings=[[NSMutableDictionary alloc]initWithObjects:[NSArray arrayWithObjects:@"", [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"ID", @"shouldRelaunch", @"shouldLaunchAtStartup", @"hasRun", nil]];
        NSMutableDictionary *info=[[NSMutableDictionary alloc]initWithContentsOfFile:targetInfoPlistPath];
        int targetID=arc4random() % 900000 + 100000;
        [settings setObject:[NSString stringWithFormat:@"%d", targetID] forKey:@"ID"];
        [info setObject:[self.appLabelField stringValue] forKey:@"CFBundleName"];
        [info setObject:@"" forKey:@"NSHumanReadableCopyright"];
        
        if ([self.launchAtLogin state]==NSOnState)
        {
            [settings setObject:[NSNumber numberWithBool:YES] forKey:@"shouldLaunchAtStartup"];
        }
        if ([self.relaunchIfQuit state]==NSOnState)
        {
            [settings setObject:[NSNumber numberWithBool:YES] forKey:@"shouldRelaunch"];
        }
        if ([self.hideApplication state]==NSOnState)
        {
            [info setObject:[NSNumber numberWithBool:YES] forKey:@"LSUIElement"];
        }
        if (![[self.customIconField stringValue] isEqualToString:@""])
        {
            [[NSFileManager defaultManager]copyItemAtPath:[self.customIconField stringValue] toPath:[applicationSupportDirectory stringByAppendingPathComponent:@"Remote Speech Target.app/Contents/Resources/CustomIcon.icns"] error:nil];
            [info setObject:@"CustomIcon" forKey:@"CFBundleIconFile"];
        }
        [settings setObject:[NSNumber numberWithBool:YES] forKey:@"hasRun"];
        [settings writeToFile:targetSettingsPlistPath atomically:YES];
        [info writeToFile:targetInfoPlistPath atomically:YES];
        
        NSOpenPanel *saveTarget = [NSOpenPanel openPanel];
        [saveTarget setCanChooseFiles:NO];
        [saveTarget setCanChooseDirectories:YES];
        [saveTarget setAllowsMultipleSelection:NO];
        [saveTarget setPrompt:@"Save"];
        [saveTarget setTitle:@"Save Target"];
        [saveTarget setCanCreateDirectories:YES];
        
        NSInteger clicked = [saveTarget runModal];
        
        if (clicked == NSFileHandlingPanelOKButton) {
            NSString *pathToSave = [[[saveTarget URL] path] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[NSFileManager defaultManager] copyItemAtPath:[applicationSupportDirectory stringByAppendingPathComponent:@"Remote Speech Target.app"] toPath:[pathToSave stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.app", [self.appLabelField stringValue]]] error:nil];
            [self.delegate addTargetToAccount:[NSString stringWithFormat:@"%d", targetID] withName:[self.targetNameField stringValue]];
            [self.window close];
        }
        [[NSFileManager defaultManager]removeItemAtPath:[applicationSupportDirectory stringByAppendingPathComponent:@"Remote Speech Target.app"] error:nil];
    }
}

- (IBAction)customIconFieldReturnAction:(id)sender
{
    if ([[self.customIconField stringValue]rangeOfString:@".icns"].location == NSNotFound)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Invalid File Type"];
        [alert setInformativeText:@"The desired image must be in \"icns\" format."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else
    {
        [self setAppIcon:[self.customIconField stringValue]];
    }
}
@end
