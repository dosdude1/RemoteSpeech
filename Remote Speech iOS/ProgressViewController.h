//
//  ProgressViewController.h
//  Remote Speech
//
//  Created by Collin Mistr on 1/11/18.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIProgressView *sendingAudioProgress;


-(void)setAudioSendingProgressValue:(float)val animated:(BOOL)anim;


@end
