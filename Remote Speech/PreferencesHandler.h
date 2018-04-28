//
//  PreferencesHandler.h
//  Remote Speech
//
//  Created by Collin Mistr on 1/28/17.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    updateStateNotifyOnly=0,
    updateStateAutomatically=1,
    updateStateDisable=2
}updateState;

@interface PreferencesHandler : NSObject
{
    NSString *applicationSupportDirectory;
    NSString *preferencesPlistPath;
    NSMutableDictionary *preferences;
}


+(PreferencesHandler *)sharedInstance;
-(BOOL)shouldRememberUser;
-(NSString *)getRememberedUsername;
-(NSString *)getRememberedPassword;
-(BOOL)didFinishTutorial;
-(void)setRememberedUser:(NSString *)username withPassword:(NSString *)password;
-(void)setFinishedTutorial:(BOOL)didFinish;
-(void)setUpdateStatus:(int)state;
-(int)getUpdateStatus;



@end
