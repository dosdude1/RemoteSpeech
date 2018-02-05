//
//  TargetViewController.h
//  Remote Speech
//
//  Created by Collin Mistr on 1/3/17.
//  Copyright (c) 2017 Got 'Em Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteSpeechController.h"
#import "ProgressViewController.h"
#import "AudioSelectionView.h"

@interface TargetViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, RemoteSpeechControllerTargetSettingsDelegate, UITextViewDelegate, UITextFieldDelegate, AudioSelectionDelegate>
{
    RemoteSpeechController *main;
    UIPickerView *picker;
    NSArray *targetVoices;
    NSString *targetStatus;
    NSString *targetID;
    CGSize keyboardSize;
    UIView *success;
    UIView *offline;
    BOOL isTransitioning;
    float IOS_VERSION;
    BOOL darkModeEnabled;
    UIColor *defaultBackgroundColor;
    ProgressViewController *progressViews;
    AudioSelectionView *audioSelectionView;
    UINavigationController *audioSelectionViewNavController;
}

-(id)initWithMainController:(RemoteSpeechController *)inMain;
@property (strong, nonatomic) IBOutlet UITextView *messageField;
- (IBAction)sendMessage:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *messageView;
@property (strong, nonatomic) IBOutlet UITextField *selectedVoiceField;
@property (strong, nonatomic) IBOutlet UISlider *targetVolumeSlider;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
-(void)getData:(NSString *)ID targetName:(NSString *)inName status:(NSString *)onlineStatus selectedVoice:(NSString *)voice;
@property (strong, nonatomic) IBOutlet UILabel *targetIDLabel;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
-(void)setDarkModeEnabled:(BOOL)enabled;
@property (strong, nonatomic) IBOutlet UIView *volumeView;
@property (strong, nonatomic) IBOutlet UIView *voiceView;

//Volume View
@property (strong, nonatomic) IBOutlet UILabel *volumeLabel;
@property (strong, nonatomic) IBOutlet UILabel *zeroLabel;
@property (strong, nonatomic) IBOutlet UILabel *hundredLabel;

//Voice View
@property (strong, nonatomic) IBOutlet UILabel *voiceLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)beginSendingAudio:(id)sender;


@property (strong, nonatomic) IBOutlet UIButton *playAudioButton;

@end
