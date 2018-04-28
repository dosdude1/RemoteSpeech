//
//  iPadLoginView.h
//  Remote Speech
//
//  Created by Collin Mistr on 1/1/17.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteSpeechController.h"

@protocol iPadLoginViewDelegate <NSObject>
@optional
-(void)didLoginSuccessfully;
-(void)setPrefs:(BOOL)shouldRememberLogin withUsername:(NSString *)username withPassword:(NSString *)password;

@end
@interface iPadLoginView : UIViewController <RemoteSpeechControllerLoginDelegate, UIAlertViewDelegate>
{
    RemoteSpeechController *main;
    BOOL rememberedAccount;
}
@property (nonatomic, strong) id <iPadLoginViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
- (IBAction)login:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
-(id)initWithMainController:(RemoteSpeechController *)inMain;
@end
