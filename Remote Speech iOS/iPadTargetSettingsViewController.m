//
//  TargetSettingsViewController.m
//  Remote Speech
//
//  Created by Collin Mistr on 1/1/17.
//  Copyright (c) 2017 Got 'Em Apps. All rights reserved.
//

#import "iPadTargetSettingsViewController.h"

@interface iPadTargetSettingsViewController ()

@end

@implementation iPadTargetSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithMainController:(RemoteSpeechController *)inMain
{
    self=[self init];
    main=inMain;
    main.targetSettingsDelegate=self;
    return self;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    targetVoices=[[NSArray alloc]init];
    picker = [[UIPickerView alloc] init];
    picker.dataSource = self;
    picker.delegate = self;
    [picker setShowsSelectionIndicator:YES];
    self.selectedVoiceField.inputView = picker;
    
    [self.volumeSlider setMinimumValue:0.0];
    [self.volumeSlider setMaximumValue:100.0];
    [self.volumeSlider setValue:50.0];
    [self.volumeSlider addTarget:self action:@selector(setVolume) forControlEvents:UIControlEventTouchUpInside];
    
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(setVoice)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    self.selectedVoiceField.inputAccessoryView = keyboardToolbar;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pickerWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}
-(void)pickerWillShow
{
    int index=0;
    for (int i=0; i<targetVoices.count; i++)
    {
        if ([[targetVoices objectAtIndex:i]isEqualToString:[self.selectedVoiceField text]])
        {
            index=i;
        }
    }
    [picker selectRow:index inComponent:0 animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return targetVoices.count;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return  1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [targetVoices objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedVoiceField.text = [targetVoices objectAtIndex:row];
}
-(void)setVoice
{
    [self.selectedVoiceField resignFirstResponder];
    [main setVoiceOfTargetID:targetID withVoice:[self.selectedVoiceField text]];
}
-(void)setVolume
{
    [main setVolumeOfTargetID:targetID withVolume:[self.volumeSlider value]];
}
-(void)editTargetID:(NSString *)inTargetID targetIsOnline:(BOOL)isOnline
{
    targetID=inTargetID;
    [self.targetIDLabel setText:[NSString stringWithFormat:@"Target ID: %@", targetID]];
    if (isOnline)
    {
        [self.volumeSlider setEnabled:YES];
        [self.selectedVoiceField setEnabled:YES];
    }
    else
    {
        [self.volumeSlider setEnabled:NO];
        [self.selectedVoiceField setEnabled:NO];
    }
}
-(void)didReceiveVoicesList:(NSArray *)voices
{
    targetVoices=voices;
    [picker reloadAllComponents];
    [main getVolumeForTargetID:targetID];
}
-(void)didReceiveCurrentVolume:(NSInteger)vol
{
    [self.volumeSlider setValue:vol animated:NO];
}
-(void)setCurrentVoice:(NSString *)currentVoice
{
    [self.selectedVoiceField setText:currentVoice];
}
@end
