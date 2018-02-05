//
//  iPadTargetViewController.m
//  Remote Speech
//
//  Created by Collin Mistr on 12/31/16.
//  Copyright (c) 2016 Got 'Em Apps. All rights reserved.
//

#import "iPadTargetViewController.h"

@interface iPadTargetViewController ()

@end

@implementation iPadTargetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithMainController:(RemoteSpeechController *)inMain withTargetTable:(iPadTableViewController *)inTableController
{
    self=[self init];
    main=inMain;
    tableController=inTableController;
    tableController.delegate=self;
    return self;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.messageField setDelegate:self];
    self.messageField.textColor = [UIColor lightGrayColor];
    self.messageField.text = @"Type Message to Send...";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    success = [[[NSBundle mainBundle] loadNibNamed:@"ConfirmationHUD" owner:self options:nil] objectAtIndex:0];
    [success.layer setCornerRadius:20];
}
-(void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrameForView = [self.view.superview convertRect:keyboardFrame fromView:nil];
    
    CGRect newViewFrame = self.view.frame;
    newViewFrame.size.height=newViewFrame.size.height-keyboardFrameForView.size.height;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        self.view.frame = newViewFrame;
    } completion:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrameForView = [self.view.superview convertRect:keyboardFrame fromView:nil];
    
    CGRect newViewFrame = self.view.frame;
    newViewFrame.size.height=newViewFrame.size.height+keyboardFrameForView.size.height;
    
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
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [self sendMessage];
        return NO;
    }
    
    return YES;
}
-(void)sendMessage
{
    if ([tableController getSelectedTargetIDs].count<1)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Targets Selected" message:@"Please select at least one target before sending a message." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if ([[self.messageField text] length] < 1)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Entry" message:@"Please enter a message before sending." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [self.messageField resignFirstResponder];
        [main sendMessageToTargetIDs:[tableController getSelectedTargetIDs] withMessage:[self.messageField text]];
        CGRect viewRect;
        if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        {
            viewRect=CGRectMake((self.splitViewController.view.frame.size.height/2)-(success.frame.size.width/2), (self.splitViewController.view.frame.size.width/2)-(success.frame.size.height/2), success.frame.size.width, success.frame.size.height);
        }
        else
        {
            viewRect=CGRectMake((self.splitViewController.view.frame.size.width/2)-(success.frame.size.width/2), (self.splitViewController.view.frame.size.height/2)-(success.frame.size.height/2), success.frame.size.width, success.frame.size.height);
        }
        [success setFrame:viewRect];
        [success setAlpha:0.0];
        [self.splitViewController.view addSubview:success];
        [UIView beginAnimations:nil context:nil];
        [success setAlpha:1.0];
        [UIView commitAnimations];
        [self performSelector:@selector(dismissView:) withObject:success afterDelay:.75];
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
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if ([[self.messageField text]isEqualToString:@"Type Message to Send..."])
    {
        self.messageField.text = @"";
        self.messageField.textColor = [UIColor blackColor];
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
-(void)didBeginEditingTarget:(NSString *)targetID
{
    [self.messageField resignFirstResponder];
}
@end
