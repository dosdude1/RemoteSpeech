//
//  AddTargetView.m
//  Remote Speech
//
//  Created by Collin Mistr on 1/4/17.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import "AddTargetView.h"

@interface AddTargetView ()

@end

@implementation AddTargetView

-(id)initWithMainController:(RemoteSpeechController *)inMain
{
    self=[super init];
    main=inMain;
    IOS_VERSION = [[[UIDevice currentDevice] systemVersion] floatValue];
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
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(hideKeyboard)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    self.targetIDField.inputAccessoryView = keyboardToolbar;
    
    [self.targetIDField setDelegate:self];
    [self.targetNameField setDelegate:self];
    UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.view addGestureRecognizer:gestureRecognizer];
    defaultBackgroundColor=[self.view backgroundColor];
}
-(void)keyboardWillShow:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrameForView = [self.view.superview convertRect:keyboardFrame fromView:nil];
    
    CGRect newViewFrame = self.view.frame;
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        if ([self.targetNameField isFirstResponder])
        {
            newViewFrame.origin.y = keyboardFrameForView.origin.y - (self.targetNameField.frame.origin.y+self.targetNameField.frame.size.height+10);
            
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
                self.view.frame = newViewFrame;
            } completion:nil];
        }
        else if ([self.targetIDField isFirstResponder])
        {
            newViewFrame.origin.y = keyboardFrameForView.origin.y - (self.targetIDField.frame.origin.y+self.targetIDField.frame.size.height+10);
            
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
                self.view.frame = newViewFrame;
            } completion:nil];
        }
    }
    else if ([[UIScreen mainScreen]bounds].size.height == 480)
    {
        newViewFrame.origin.y -=20;
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
            self.view.frame = newViewFrame;
        } completion:nil];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)keyboardWillHide:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrameForView = [self.view.superview convertRect:keyboardFrame fromView:nil];
    
    CGRect newViewFrame = self.view.frame;
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        newViewFrame.origin.y = keyboardFrameForView.origin.y-newViewFrame.size.height;
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
            self.view.frame = newViewFrame;
        } completion:nil];
    }
    else if ([[UIScreen mainScreen]bounds].size.height == 480)
    {
        newViewFrame.origin.y += 20;
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
            self.view.frame = newViewFrame;
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
-(void)hideKeyboard
{
    [self.targetIDField resignFirstResponder];
    [self.targetNameField resignFirstResponder];
}
-(void)clearForm
{
    [self.targetIDField setText:@""];
    [self.targetNameField setText:@""];
}
-(void)dismissModal
{
    [self dismissModalViewControllerAnimated:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return NO;
}
-(void)addTarget
{
    if ([self.targetIDField text].length != 6)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Invalid Target ID" message:@"A valid Target ID must consist of exactly 6 digits." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if ([[self.targetNameField text]isEqualToString:@""])
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Invalid Entry" message:@"Please enter a Target Name before adding this target." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if ([self doesTargetExist:[self.targetIDField text]])
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Target Exists" message:@"A target with the specified ID is already in your list." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [main addTargetWithID:[self.targetIDField text] withName:[self.targetNameField text]];
        [self dismissModal];
    }
}
-(BOOL)doesTargetExist:(NSString *)targetID
{
    for (NSDictionary *d in targets)
    {
        if ([[d objectForKey:@"targetID"] isEqualToString:targetID])
        {
            return YES;
        }
    }
    return NO;
}
-(void)sendTargets:(NSArray *)inTargs
{
    targets=inTargs;
}
-(void)setDarkModeEnabled:(BOOL)enabled
{
    darkModeEnabled=enabled;
    if (enabled)
    {
        [self.view setBackgroundColor:[UIColor blackColor]];
        UIToolbar *t = (UIToolbar *)self.targetIDField.inputAccessoryView;
        [t setBarStyle:UIBarStyleBlack];
        [self.targetIDLabel setTextColor:[UIColor whiteColor]];
        [self.IDDescriptionLabel setTextColor:[UIColor whiteColor]];
        [self.targetNameLabel setTextColor:[UIColor whiteColor]];
        [self.targetIDField setTextColor:[UIColor whiteColor]];
        [self.targetNameField setTextColor:[UIColor whiteColor]];
        [self.targetIDField setBackgroundColor:[UIColor colorWithRed:91.0/255 green:91.0/255 blue:91.0/255 alpha:1.0]];
        [self.targetNameField setBackgroundColor:[UIColor colorWithRed:91.0/255 green:91.0/255 blue:91.0/255 alpha:1.0]];
        [self.targetNameField setKeyboardAppearance:UIKeyboardAppearanceDark];
        [self.targetIDField setKeyboardAppearance:UIKeyboardAppearanceDark];
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        if (IOS_VERSION >= 7.0)
        {
            [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        }
    }
    else
    {
        [self.view setBackgroundColor:defaultBackgroundColor];
        UIToolbar *t = (UIToolbar *)self.targetIDField.inputAccessoryView;
        [t setBarStyle:UIBarStyleDefault];
        [self.targetIDLabel setTextColor:[UIColor blackColor]];
        [self.IDDescriptionLabel setTextColor:[UIColor blackColor]];
        [self.targetNameLabel setTextColor:[UIColor blackColor]];
        [self.targetIDField setTextColor:[UIColor blackColor]];
        [self.targetNameField setTextColor:[UIColor blackColor]];
        [self.targetIDField setBackgroundColor:[UIColor whiteColor]];
        [self.targetNameField setBackgroundColor:[UIColor whiteColor]];
        [self.targetNameField setKeyboardAppearance:UIKeyboardAppearanceDefault];
        [self.targetIDField setKeyboardAppearance:UIKeyboardAppearanceDefault];
        [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
        if (IOS_VERSION >= 7.0)
        {
            [self.navigationController.navigationBar setTintColor:nil];
        }
    }
}
@end
