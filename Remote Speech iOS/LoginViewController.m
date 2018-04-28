//
//  LoginViewController.m
//  Remote Speech
//
//  Created by Collin Mistr on 1/3/17.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

-(id)initWithMainController:(RemoteSpeechController *)inMain
{
    self=[self init];
    main=inMain;
    main.loginDelegate=self;
    rememberedAccount=YES;
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
                                      initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    self.usernameField.inputAccessoryView = keyboardToolbar;
    self.passwordField.inputAccessoryView = keyboardToolbar;
    [self.usernameField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    [self.passwordField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    [self.loginButton setEnabled:NO];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.usernameField setText:@""];
    [self.passwordField setText:@""];
    [self.loginButton setEnabled:NO];
}
-(void)keyboardWillShow:(NSNotification *)note
{
    
    NSDictionary *userInfo = note.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrameForView = [self.view.superview convertRect:keyboardFrame fromView:nil];
    
    CGRect newViewFrame = self.view.frame;
    newViewFrame.origin.y = keyboardFrameForView.origin.y - (self.loginButton.frame.origin.y+self.loginButton.frame.size.height+10);
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        self.view.frame = newViewFrame;
    } completion:nil];
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
    newViewFrame.origin.y = keyboardFrameForView.origin.y - newViewFrame.size.height;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        self.view.frame = newViewFrame;
    } completion:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dismissKeyboard
{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}
-(void)didLoginSuccessfully:(BOOL)loginStatus
{
    if (!loginStatus)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Username or Password Invalid" message:@"The username or password you have entered is invalid" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [self.passwordField resignFirstResponder];
        [self.usernameField resignFirstResponder];
        if (!rememberedAccount)
        {
            [self.delegate setPrefs:YES withUsername:[self.usernameField text] withPassword:[self.passwordField text]];
        }
        [self.delegate didLoginSuccessfully];
    }
}
-(void)streamErrorOccurred:(int)errNum
{
    if (errNum==-1)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Could not connect to the Remote Speech Server. Please check your Internet connection and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}
- (IBAction)logIn:(id)sender
{
    [main loginToServer:[self.usernameField text] withPassword:[self.passwordField text] isRememberedAccount:NO];
    rememberedAccount=NO;
}
-(void)textFieldDidChange:(id)sender
{
    if ([[self.usernameField text] length] > 0 && [[self.passwordField text] length] > 0)
    {
        [self.loginButton setEnabled:YES];
    }
    else
    {
        [self.loginButton setEnabled:NO];
    }
}
@end
