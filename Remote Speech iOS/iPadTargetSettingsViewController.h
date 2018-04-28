//
//  TargetSettingsViewController.h
//  Remote Speech
//
//  Created by Collin Mistr on 1/1/17.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteSpeechController.h"

@interface iPadTargetSettingsViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, RemoteSpeechControllerTargetSettingsDelegate>
{
    NSArray *targetVoices;
    RemoteSpeechController *main;
    UIPickerView *picker;
    NSString *targetID;
}
@property (strong, nonatomic) IBOutlet UITextField *selectedVoiceField;
@property (strong, nonatomic) IBOutlet UISlider *volumeSlider;
@property (strong, nonatomic) IBOutlet UILabel *targetIDLabel;

-(id)initWithMainController:(RemoteSpeechController *)inMain;
-(void)setCurrentVoice:(NSString *)currentVoice;
-(void)editTargetID:(NSString *)inTargetID targetIsOnline:(BOOL)isOnline;
@end
