//
//  TargetViewController.m
//  Remote Speech
//
//  Created by Collin Mistr on 1/3/17.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import "TargetViewController.h"

@interface TargetViewController ()

@end

@implementation TargetViewController

-(id)initWithMainController:(RemoteSpeechController *)inMain
{
    self=[self init];
    main=inMain;
    main.targetSettingsDelegate=self;
    isTransitioning=NO;
    IOS_VERSION = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (toInterfaceOrientation==UIInterfaceOrientationPortrait || toInterfaceOrientation==UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation==UIInterfaceOrientationLandscapeRight)
    {
        return YES;
    }
    return NO;
}
-(void)getData:(NSString *)ID targetName:(NSString *)inName status:(NSString *)onlineStatus selectedVoice:(NSString *)voice
{
    targetStatus=onlineStatus;
    [self.selectedVoiceField setText:voice];
    [self.statusLabel setText:[NSString stringWithFormat:@"Status: %@", onlineStatus]];
    if ([onlineStatus isEqualToString:@"Offline"])
    {
        [self.targetVolumeSlider setEnabled:NO];
        [self.selectedVoiceField setEnabled:NO];
        [self.playAudioButton setEnabled:NO];
        [self.playAudioButton setAlpha:0.5];
        
    }
    else
    {
        [self.targetVolumeSlider setEnabled:YES];
        [self.selectedVoiceField setEnabled:YES];
        [self.playAudioButton setEnabled:YES];
        [self.playAudioButton setAlpha:1.0];
    }
    targetID=ID;
    [self.targetIDLabel setText:[NSString stringWithFormat:@"Target ID: %@", targetID]];
    self.navigationItem.title=inName;
    [main getVoicesListForTargetID:[NSString stringWithFormat:@"%@", targetID]];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, 270)];
    [self.messageField setDelegate:self];
    self.messageField.text = @"Type Message to Send...";
    self.messageField.textColor = [UIColor lightGrayColor];
    [self.targetVolumeSlider setMinimumValue:0.0];
    [self.targetVolumeSlider setMaximumValue:100.0];
    [self.targetVolumeSlider setValue:50.0];
    [self.targetVolumeSlider addTarget:self action:@selector(setVolume) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton setEnabled:NO];
    [self.sendButton setAlpha:0.5];
    
    targetVoices=[[NSArray alloc]init];
    picker = [[UIPickerView alloc] init];
    picker.dataSource = self;
    picker.delegate = self;
    [picker setShowsSelectionIndicator:YES];
    self.selectedVoiceField.inputView = picker;
    [self.selectedVoiceField setDelegate:self];
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(setVoice)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    self.selectedVoiceField.inputAccessoryView = keyboardToolbar;
    UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.view addGestureRecognizer:gestureRecognizer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    success = [[[NSBundle mainBundle] loadNibNamed:@"ConfirmationHUD" owner:self options:nil] objectAtIndex:0];
    [success.layer setCornerRadius:20];
    offline = [[[NSBundle mainBundle] loadNibNamed:@"ConfirmationHUD" owner:self options:nil] objectAtIndex:1];
    [offline.layer setCornerRadius:20];
    progressViews = [[ProgressViewController alloc] initWithNibName:@"ProgressViewController" bundle:nil];
    defaultBackgroundColor=[self.view backgroundColor];
}
- (void)keyboardWillShow:(NSNotification *)note
{
    if ([self.messageField isFirstResponder])
    {
        [self.view bringSubviewToFront:self.messageView];
        NSDictionary *userInfo = note.userInfo;
        NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
        
        CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGRect keyboardFrameForTextField = [self.messageView.superview convertRect:keyboardFrame fromView:nil];
        
        CGRect newTextFieldFrame = self.messageView.frame;
        newTextFieldFrame.origin.y = keyboardFrameForTextField.origin.y - newTextFieldFrame.size.height-53;
        newTextFieldFrame.size.height+=53;
        CGRect textViewFrame=self.messageField.frame;
        textViewFrame.size.height+=53;
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
            self.messageView.frame = newTextFieldFrame;
            self.messageField.frame=textViewFrame;
        } completion:nil];
    }
    else if ([self.selectedVoiceField isFirstResponder])
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)keyboardWillHide:(NSNotification *)note
{
    if ([self.messageField isFirstResponder])
    {
        [self.view bringSubviewToFront:self.messageView];
        NSDictionary *userInfo = note.userInfo;
        NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
        
        CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGRect keyboardFrameForTextField = [self.messageView.superview convertRect:keyboardFrame fromView:nil];
        
        CGRect newTextFieldFrame = self.messageView.frame;
        newTextFieldFrame.origin.y = keyboardFrameForTextField.origin.y - newTextFieldFrame.size.height+53;
        newTextFieldFrame.size.height-=53;
        CGRect textViewFrame=self.messageField.frame;
        textViewFrame.size.height-=53;
        
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
            self.messageView.frame = newTextFieldFrame;
            self.messageField.frame=textViewFrame;
        } completion:nil];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendMessage:(id)sender
{
    [self hideKeyboard];
    
    if ([[self.messageField text] length] < 1 || [[self.messageField text] isEqualToString:@"Type Message to Send..."])
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Entry" message:@"Please enter a message before sending." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if ([targetStatus isEqualToString:@"Online"])
    {
        [main sendMessageToTargetIDs:[NSArray arrayWithObject:targetID] withMessage:[self.messageField text]];
        CGRect viewRect=CGRectMake((self.view.frame.size.width/2)-(success.frame.size.width/2), (self.view.frame.size.height/2)-(success.frame.size.height/2), success.frame.size.width, success.frame.size.height);
        [success setFrame:viewRect];
        [success setAlpha:0.0];
        [self.navigationController.view addSubview:success];
        [UIView beginAnimations:nil context:nil];
        [success setAlpha:1.0];
        [UIView commitAnimations];
        [self performSelector:@selector(dismissView:) withObject:success afterDelay:.75];
    }
    else
    {
        CGRect viewRect=CGRectMake((self.view.frame.size.width/2)-(offline.frame.size.width/2), (self.view.frame.size.height/2)-(offline.frame.size.height/2), offline.frame.size.width, offline.frame.size.height);
        [offline setFrame:viewRect];
        [offline setAlpha:0.0];
        [self.navigationController.view addSubview:offline];
        [UIView beginAnimations:nil context:nil];
        [offline setAlpha:1.0];
        [UIView commitAnimations];
        [self performSelector:@selector(dismissView:) withObject:offline afterDelay:.75];
    }
}
-(void)dismissView:(UIView *)toDismiss
{
    [UIView beginAnimations:nil context:nil];
    [toDismiss setAlpha:0.0];
    [UIView commitAnimations];
    [UIView setAnimationDelegate:toDismiss];
    [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
}
-(void)hideKeyboard
{
    [self.messageField resignFirstResponder];
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

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView
             attributedTitleForRow:(NSInteger)row
                      forComponent:(NSInteger)component
{
    UIColor *color;
    if (IOS_VERSION >= 7.0)
    {
        if (darkModeEnabled)
        {
            color = [UIColor whiteColor];
        }
        else
        {
            color = [UIColor blackColor];
        }
    }
    else
    {
        color = [UIColor blackColor];
    }
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObject:color] forKeys:[NSArray arrayWithObject:NSForegroundColorAttributeName]];
    return [[NSAttributedString alloc] initWithString:[targetVoices objectAtIndex:row]
                                           attributes:attributes];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedVoiceField.text = [targetVoices objectAtIndex:row];
}
-(void)setVoice
{
    [self.selectedVoiceField resignFirstResponder];
    [main setVoiceOfTargetID:targetID withVoice:[self.selectedVoiceField text]];
}
-(void)didReceiveVoicesList:(NSArray *)voices
{
    targetVoices=voices;
    [picker reloadAllComponents];
    [main getVolumeForTargetID:targetID];
}
-(void)didReceiveCurrentVolume:(NSInteger)vol
{
    [self.targetVolumeSlider setValue:vol animated:NO];
}
-(void)setVolume
{
    [main setVolumeOfTargetID:targetID withVolume:[self.targetVolumeSlider value]];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length < 1)
    {
        [self.sendButton setEnabled:NO];
        [self.sendButton setAlpha:0.5];
    }
    else
    {
        [self.sendButton setEnabled:YES];
        [self.sendButton setAlpha:1.0];
    }
}
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if ([[self.messageField text]isEqualToString:@"Type Message to Send..."])
    {
        self.messageField.text = @"";
        if (darkModeEnabled)
        {
            self.messageField.textColor = [UIColor whiteColor];
        }
        else
        {
            self.messageField.textColor = [UIColor blackColor];
        }
    }
    if (isTransitioning)
    {
        return NO;
    }
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([[self.messageField text] isEqualToString:@""])
    {
        self.messageField.textColor = [UIColor lightGrayColor];
        self.messageField.text = @"Type Message to Send...";
    }
    return YES;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.messageField resignFirstResponder];
    return YES;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self.messageField resignFirstResponder];
    isTransitioning=YES;
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES animated:YES];
    isTransitioning=YES;
}
-(void)viewDidAppear:(BOOL)animated
{
    if ([[self.messageField text] isEqualToString:@""])
    {
        self.messageField.textColor = [UIColor lightGrayColor];
        self.messageField.text = @"Type Message to Send...";
    }
    isTransitioning=NO;
}
-(void)viewDidDisappear:(BOOL)animated
{
    isTransitioning=NO;
}
-(void)setDarkModeEnabled:(BOOL)enabled
{
    darkModeEnabled=enabled;
    if (enabled)
    {
        [self.view setBackgroundColor:[UIColor blackColor]];
        [self.volumeView setBackgroundColor:[UIColor blackColor]];
        [self.voiceView setBackgroundColor:[UIColor blackColor]];
        [self.volumeLabel setTextColor:[UIColor whiteColor]];
        [self.zeroLabel setTextColor:[UIColor whiteColor]];
        [self.hundredLabel setTextColor:[UIColor whiteColor]];
        [self.voiceLabel setTextColor:[UIColor whiteColor]];
        [self.selectedVoiceField setBackgroundColor:[UIColor colorWithRed:91.0/255 green:91.0/255 blue:91.0/255 alpha:1.0]];
        [self.selectedVoiceField setTextColor:[UIColor whiteColor]];
        [self.messageView setBackgroundColor:[UIColor colorWithRed:45.0/255.0 green:45.0/255.0 blue:45.0/255.0 alpha:1.0]];
        [self.messageField setBackgroundColor:[UIColor colorWithRed:91.0/255 green:91.0/255 blue:91.0/255 alpha:1.0]];
        [self.messageField setKeyboardAppearance:UIKeyboardAppearanceDark];
        [picker setBackgroundColor:[UIColor colorWithRed:91.0/255 green:91.0/255 blue:91.0/255 alpha:1.0]];
        UIToolbar *t = (UIToolbar *)self.selectedVoiceField.inputAccessoryView;
        [t setBarStyle:UIBarStyleBlack];
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        if (![self.messageField.text isEqualToString:@"Type Message to Send..."])
        {
            self.messageField.textColor = [UIColor whiteColor];
        }
        if (IOS_VERSION >= 7.0)
        {
            [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        }
    }
    else
    {
        [self.view setBackgroundColor:defaultBackgroundColor];
        [self.volumeView setBackgroundColor:defaultBackgroundColor];
        [self.voiceView setBackgroundColor:defaultBackgroundColor];
        [self.volumeLabel setTextColor:[UIColor blackColor]];
        [self.zeroLabel setTextColor:[UIColor blackColor]];
        [self.hundredLabel setTextColor:[UIColor blackColor]];
        [self.voiceLabel setTextColor:[UIColor blackColor]];
        [self.selectedVoiceField setBackgroundColor:[UIColor whiteColor]];
        [self.selectedVoiceField setTextColor:[UIColor blackColor]];
        [self.messageView setBackgroundColor:[UIColor colorWithRed:203.0/255.0 green:202.0/255.0 blue:205.0/255.0 alpha:1.0]];
        [self.messageField setBackgroundColor:[UIColor whiteColor]];
        [self.messageField setKeyboardAppearance:UIKeyboardAppearanceDefault];
        [self.selectedVoiceField setKeyboardAppearance:UIKeyboardAppearanceDefault];
        [picker setBackgroundColor:[UIColor colorWithRed:209.0/255 green:213.0/255 blue:219.0/255 alpha:1.0]];
        UIToolbar *t = (UIToolbar *)self.selectedVoiceField.inputAccessoryView;
        [t setBarStyle:UIBarStyleDefault];
        [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
        if (![self.messageField.text isEqualToString:@"Type Message to Send..."])
        {
            self.messageField.textColor = [UIColor blackColor];
        }
        if (IOS_VERSION >= 7.0)
        {
            [self.navigationController.navigationBar setTintColor:nil];
        }
    }
    [audioSelectionView setDarkModeEnabled:enabled];
}
- (IBAction)beginSendingAudio:(id)sender
{
    if (!audioSelectionView)
    {
        audioSelectionView = [[AudioSelectionView alloc] init];
        audioSelectionView.delegate = self;
        audioSelectionViewNavController = [[UINavigationController alloc] init];
        [audioSelectionViewNavController setViewControllers:[NSArray arrayWithObject:audioSelectionView]];
        [audioSelectionView setDarkModeEnabled:darkModeEnabled];
    }
    [self presentModalViewController:audioSelectionViewNavController animated:YES];
}
-(void)didSelectAudioFileToSend:(NSString *)path
{
    [main sendAudioFile:path toTarget:targetID];
}
-(void)audioSendingWillStart
{
    UIView *audioProgressView = progressViews.view;
    CGRect viewRect=CGRectMake((self.view.frame.size.width/2)-(success.frame.size.width/2), (self.view.frame.size.height/2)-(success.frame.size.height/2), success.frame.size.width, success.frame.size.height);
    [audioProgressView setFrame:viewRect];
    [audioProgressView setAlpha:0.0];
    [self.navigationController.view addSubview:audioProgressView];
    [UIView beginAnimations:nil context:nil];
    [audioProgressView setAlpha:1.0];
    [UIView commitAnimations];
}
-(void)audioSendingProgressDidChange:(float)value animated:(BOOL)anim
{
    [progressViews setAudioSendingProgressValue:value animated:anim];
}
-(void)audioDidFinishSending
{
    [self performSelector:@selector(dismissView:) withObject:progressViews.view afterDelay:0.5];
    [self performSelector:@selector(showSuccessView) withObject:nil afterDelay:0.75];
}
-(void)showSuccessView
{
    CGRect viewRect=CGRectMake((self.view.frame.size.width/2)-(success.frame.size.width/2), (self.view.frame.size.height/2)-(success.frame.size.height/2), success.frame.size.width, success.frame.size.height);
    [success setFrame:viewRect];
    [success setAlpha:0.0];
    [self.navigationController.view addSubview:success];
    [UIView beginAnimations:nil context:nil];
    [success setAlpha:1.0];
    [UIView commitAnimations];
    [self performSelector:@selector(dismissView:) withObject:success afterDelay:.75];
}
@end
