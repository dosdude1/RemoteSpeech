//
//  PreferencesHandler.m
//  Remote Speech
//
//  Created by Collin Mistr on 6/7/17.
//  Copyright (c) 2017 Got 'Em Apps. All rights reserved.
//

#import "PreferencesHandler.h"

@implementation PreferencesHandler

-(id)init
{
    self=[super init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = paths.firstObject;
    [self initPrefs];
    return self;
}

+(PreferencesHandler *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static PreferencesHandler *sharedObject = nil;
    dispatch_once(&pred, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}
-(void)initPrefs
{
    if (![[NSFileManager defaultManager]fileExistsAtPath:[documentsDirectory stringByAppendingPathComponent:@"preferences.plist"]])
    {
        preferences=[[NSMutableDictionary alloc]initWithObjects:[NSArray arrayWithObjects:@"", @"", [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"username", @"password", @"rememberLogin", @"useDarkMode", nil]];
        [preferences writeToFile:[documentsDirectory stringByAppendingPathComponent:@"preferences.plist"] atomically:YES];
    }
    else
    {
        preferences=[[NSMutableDictionary alloc]initWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:@"preferences.plist"]];
    }
}
-(void)writePrefs
{
    [preferences writeToFile:[documentsDirectory stringByAppendingPathComponent:@"preferences.plist"] atomically:YES];
}
#pragma mark Getter Methods

-(BOOL)shouldAutoLogin
{
    return [[preferences objectForKey:@"rememberLogin"] boolValue];
}
-(NSString *)getRememberedUsername
{
    return [preferences objectForKey:@"username"];
}
-(NSString *)getRememberedPassword
{
    return [preferences objectForKey:@"password"];
}
-(BOOL)shouldUseDarkMode
{
    return [[preferences objectForKey:@"useDarkMode"] boolValue];
}
#pragma mark Setter Methods

-(void)setRememberedUser:(NSString *)username withPassword:(NSString *)password
{
    if ([username isEqualToString:@""])
    {
        [preferences setObject:[NSNumber numberWithBool:NO] forKey:@"rememberLogin"];
    }
    else
    {
        [preferences setObject:[NSNumber numberWithBool:YES] forKey:@"rememberLogin"];
    }
    [preferences setObject:username forKey:@"username"];
    [preferences setObject:password forKey:@"password"];
    [self writePrefs];
}
-(void)setShouldUseDarkMode:(BOOL)shouldUse
{
    [preferences setObject:[NSNumber numberWithBool:shouldUse] forKey:@"useDarkMode"];
    [self.darkModeDelegate darkModeChangedToState:shouldUse];
    [self writePrefs];
}
@end
