//
//  LoginViewController.h
//  Remote Speech
//
//  Created by Collin Mistr on 1/3/17.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteSpeechController.h"

@protocol LoginViewDelegate <NSObject>
@optional
-(void)didLoginSuccessfully;
-(void)setPrefs:(BOOL)shouldRememberLogin withUsername:(NSString *)username withPassword:(NSString *)password;

@end

@interface LoginViewController : UIViewController <RemoteSpeechControllerLoginDelegate>
{
    RemoteSpeechController *main;
    BOOL rememberedAccount;
}
@property (nonatomic, strong) id <LoginViewDelegate> delegate;

-(id)initWithMainController:(RemoteSpeechController *)inMain;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
- (IBAction)logIn:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;

@end
