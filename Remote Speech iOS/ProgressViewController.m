//
//  ProgressViewController.m
//  Remote Speech
//
//  Created by Collin Mistr on 1/11/18.
//  Copyright (c) 2018 Got 'Em Apps. All rights reserved.
//

#import "ProgressViewController.h"

@interface ProgressViewController ()

@end

@implementation ProgressViewController

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
    
    [self.view.layer setCornerRadius:20];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setAudioSendingProgressValue:(float)val animated:(BOOL)anim
{
    [self.sendingAudioProgress setProgress:val animated:anim];
}

@end
