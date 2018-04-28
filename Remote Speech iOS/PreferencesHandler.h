//
//  PreferencesHandler.h
//  Remote Speech
//
//  Created by Collin Mistr on 6/7/17.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol PreferencesHandlerDarkModeDelegate <NSObject>
@optional
-(void)darkModeChangedToState:(BOOL)state;
@end

@interface PreferencesHandler : NSObject
{
    NSString *documentsDirectory;
    NSMutableDictionary *preferences;
}

@property (nonatomic, strong) id <PreferencesHandlerDarkModeDelegate> darkModeDelegate;

-(id)init;
+(PreferencesHandler *)sharedInstance;
-(BOOL)shouldAutoLogin;
-(NSString *)getRememberedUsername;
-(NSString *)getRememberedPassword;
-(BOOL)shouldUseDarkMode;
-(void)setRememberedUser:(NSString *)username withPassword:(NSString *)password;
-(void)setShouldUseDarkMode:(BOOL)shouldUse;

@end
