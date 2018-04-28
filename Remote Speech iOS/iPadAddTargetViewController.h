//
//  iPadAddTargetViewController.h
//  Remote Speech
//
//  Created by Collin Mistr on 1/2/17.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteSpeechController.h"

@interface iPadAddTargetViewController : UIViewController
{
    RemoteSpeechController *main;
    NSArray *targets;
}

-(id)initWithMainController:(RemoteSpeechController *)inMain;
- (IBAction)closeForm:(id)sender;
- (IBAction)addTarget:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *targetIDField;
@property (strong, nonatomic) IBOutlet UITextField *targetNameField;
-(void)clearForm;
-(void)sendTargets:(NSArray *)inTargs;

@end
