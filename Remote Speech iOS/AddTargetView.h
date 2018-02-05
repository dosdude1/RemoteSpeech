//
//  AddTargetView.h
//  Remote Speech
//
//  Created by Collin Mistr on 1/4/17.
//  Copyright (c) 2017 Got 'Em Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteSpeechController.h"

@interface AddTargetView : UIViewController <UITextFieldDelegate>
{
    RemoteSpeechController *main;
    NSArray *targets;
    BOOL darkModeEnabled;
    float IOS_VERSION;
    UIColor *defaultBackgroundColor;
}
-(id)initWithMainController:(RemoteSpeechController *)inMain;
@property (strong, nonatomic) IBOutlet UITextField *targetIDField;
@property (strong, nonatomic) IBOutlet UITextField *targetNameField;
-(void)clearForm;
-(void)dismissModal;
-(void)addTarget;
-(void)sendTargets:(NSArray *)inTargs;
-(void)setDarkModeEnabled:(BOOL)enabled;
@property (strong, nonatomic) IBOutlet UILabel *targetIDLabel;
@property (strong, nonatomic) IBOutlet UILabel *IDDescriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *targetNameLabel;

@end
