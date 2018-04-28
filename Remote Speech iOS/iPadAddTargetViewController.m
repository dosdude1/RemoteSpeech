//
//  iPadAddTargetViewController.m
//  Remote Speech
//
//  Created by Collin Mistr on 1/2/17.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import "iPadAddTargetViewController.h"

@interface iPadAddTargetViewController ()

@end

@implementation iPadAddTargetViewController

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
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}
-(void)clearForm
{
    [self.targetIDField setText:@""];
    [self.targetNameField setText:@""];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeForm:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)addTarget:(id)sender
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
        [self closeForm:self];
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
@end
