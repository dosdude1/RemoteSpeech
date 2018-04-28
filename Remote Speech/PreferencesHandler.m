//
//  PreferencesHandler.m
//  Remote Speech
//
//  Created by Collin Mistr on 1/28/17.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import "PreferencesHandler.h"

@implementation PreferencesHandler

-(id)init
{
    self=[super init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    applicationSupportDirectory = [[paths firstObject] stringByAppendingPathComponent:@"Remote Speech"];
    preferencesPlistPath=[applicationSupportDirectory stringByAppendingPathComponent:@"preferences.plist"];
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
    if ([[NSFileManager defaultManager]fileExistsAtPath:preferencesPlistPath])
    {
        preferences = [[NSMutableDictionary alloc]initWithContentsOfFile:preferencesPlistPath];
    }
    else
    {
        preferences = [[NSMutableDictionary alloc]initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], @"", @"", [NSNumber numberWithBool:NO], [NSNumber numberWithInt:0], nil] forKeys:[NSArray arrayWithObjects:@"rememberUser", @"username", @"password", @"didFinishTutorial", @"updateStatus", nil]];
    }
}

-(void)writePrefs
{
    [preferences writeToFile:preferencesPlistPath atomically:YES];
}

#pragma mark Getter Methods

-(BOOL)shouldRememberUser
{
    return [[preferences objectForKey:@"rememberUser"] boolValue];
}
-(NSString *)getRememberedUsername
{
    return [preferences objectForKey:@"username"];
}
-(NSString *)getRememberedPassword
{
    return [preferences objectForKey:@"password"];
}
-(BOOL)didFinishTutorial
{
    return [[preferences objectForKey:@"didFinishTutorial"] boolValue];
}
-(int)getUpdateStatus
{
    return [[preferences objectForKey:@"updateStatus"]intValue];
}
#pragma mark Setter Methods

-(void)setRememberedUser:(NSString *)username withPassword:(NSString *)password
{
    if ([username isEqualToString:@""])
    {
        [preferences setObject:[NSNumber numberWithBool:NO] forKey:@"rememberUser"];
    }
    else
    {
        [preferences setObject:[NSNumber numberWithBool:YES] forKey:@"rememberUser"];
    }
    [preferences setObject:username forKey:@"username"];
    [preferences setObject:password forKey:@"password"];
    [self writePrefs];
}
-(void)setFinishedTutorial:(BOOL)didFinish
{
    [preferences setObject:[NSNumber numberWithBool:didFinish] forKey:@"didFinishTutorial"];
    [self writePrefs];
}
-(void)setUpdateStatus:(int)state
{
    [preferences setObject:[NSNumber numberWithInt:state] forKey:@"updateStatus"];
    [self writePrefs];
}
@end
