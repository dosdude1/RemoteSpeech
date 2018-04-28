//
//  iPadTableViewController.h
//  Remote Speech
//
//  Created by Collin Mistr on 12/31/16.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iPadTargetSettingsViewController.h"
#import "RemoteSpeechController.h"
#import "iPadAddTargetViewController.h"
#import "TargetCell.h"

@protocol iPadTableViewControllerDelegate <NSObject>
@optional
-(void)didBeginEditingTarget:(NSString *)targetID;
@end

@interface iPadTableViewController : UITableViewController <RemoteSpeechControllerTargetTableDelegate>
{
    RemoteSpeechController *main;
    NSMutableArray *targets;
    iPadTargetSettingsViewController *targetSettings;
    UIPopoverController *targetSettingsView;
    NSMutableArray *selectedIndices;
    UINavigationBar *navBar;
    iPadAddTargetViewController *addTargetView;
    NSInteger noDataLabelHeight;
    UIBarButtonItem *editButton;
    UIBarButtonItem *doneButton;
    UIBarButtonItem *addTargetButton;
}
@property (nonatomic, strong) id <iPadTableViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
-(id)initWithMainController:(RemoteSpeechController *)inMain withNavigationBar:(UINavigationBar *)inNavBar;
-(NSArray *)getSelectedTargetIDs;
@end
