//
//  iPadTargetViewController.h
//  Remote Speech
//
//  Created by Collin Mistr on 12/31/16.
//  Copyright (c) 2016 Got 'Em Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteSpeechController.h"
#import "iPadTableViewController.h"

@interface iPadTargetViewController : UIViewController <UITextViewDelegate, iPadTableViewControllerDelegate>
{
    RemoteSpeechController *main;
    iPadTableViewController *tableController;
    UIView *success;
}
@property (strong, nonatomic) IBOutlet UITextView *messageField;
-(id)initWithMainController:(RemoteSpeechController *)inMain withTargetTable:(iPadTableViewController *)inTableController;

@end
