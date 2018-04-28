//
//  iPadTableViewController.m
//  Remote Speech
//
//  Created by Collin Mistr on 12/31/16.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import "iPadTableViewController.h"

@interface iPadTableViewController ()

@end

@implementation iPadTableViewController

-(id)initWithMainController:(RemoteSpeechController *)inMain withNavigationBar:(UINavigationBar *)inNavBar
{
    self=[self init];
    main=inMain;
    navBar=inNavBar;
    main.tableDelegate=self;
    noDataLabelHeight=25;
    return self;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSArray *bgViewSubviews=[[self.mainTableView backgroundView] subviews];
    UIView *bgView=self.mainTableView.backgroundView;
    [[bgViewSubviews lastObject] setFrame:CGRectMake(0, ((bgView.bounds.size.height/2)-noDataLabelHeight)+noDataLabelHeight+5, bgView.bounds.size.width, noDataLabelHeight)];
    [[bgViewSubviews objectAtIndex:[bgViewSubviews count]-2] setFrame:CGRectMake(0, (bgView.bounds.size.height/2)-noDataLabelHeight, bgView.bounds.size.width, noDataLabelHeight)];
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView=[[UIView alloc]init];
    selectedIndices=[[NSMutableArray alloc]init];
    targetSettings = [[iPadTargetSettingsViewController alloc] initWithMainController:main];
    targets=[[NSMutableArray alloc]init];
    targetSettingsView = [[UIPopoverController alloc] initWithContentViewController:targetSettings];
    targetSettingsView.popoverContentSize=CGSizeMake(targetSettings.view.frame.size.width, targetSettings.view.frame.size.height);
    editButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEditing)];
    doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleEditing)];
    addTargetButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddTargetView)];
    navBar.topItem.leftBarButtonItem = editButton;
    addTargetView=[[iPadAddTargetViewController alloc]initWithMainController:main];
    [addTargetView sendTargets:targets];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (targets.count>0)
    {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.backgroundView = nil;
    }
    else
    {
        UIView *bgView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height)];
        UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (bgView.bounds.size.height/2)-noDataLabelHeight, bgView.bounds.size.width, noDataLabelHeight)];
        noDataLabel.text = @"No Targets Added";
        noDataLabel.font=[UIFont systemFontOfSize:22];
        noDataLabel.textColor = [UIColor grayColor];
        noDataLabel.backgroundColor = [UIColor clearColor];
        noDataLabel.textAlignment = NSTextAlignmentCenter;
        UILabel *addTargetLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ((tableView.bounds.size.height/2)-noDataLabelHeight)+noDataLabelHeight+5, tableView.bounds.size.width, noDataLabelHeight)];
        addTargetLabel.text = @"Add a target by tapping \"Edit\", \"+\".";
        addTargetLabel.textColor = [UIColor grayColor];
        addTargetLabel.backgroundColor = [UIColor clearColor];
        addTargetLabel.textAlignment = NSTextAlignmentCenter;
        [bgView addSubview:noDataLabel];
        [bgView addSubview:addTargetLabel];
        tableView.backgroundView = bgView;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return targets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TargetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
    button.frame = CGRectMake(3,6,30, 30);
    [button addTarget:self action:@selector(showTargetSettingsPopover:) forControlEvents:UIControlEventTouchUpInside];
    [button setTag:indexPath.row];
    [button setShowsTouchWhenHighlighted:YES];
    cell.accessoryView=button;
    if (selectedIndices.count > 0)
    {
        if ([[selectedIndices objectAtIndex:indexPath.row] boolValue])
        {
            cell.textLabel.text=[NSString stringWithFormat:@"\u2713 %@", [[targets objectAtIndex:indexPath.row] objectForKey:@"targetName"]];
        }
        else
        {
            cell.textLabel.text=[NSString stringWithFormat:@"\u2001 %@", [[targets objectAtIndex:indexPath.row] objectForKey:@"targetName"]];
        }
    }
    else
    {
        cell.textLabel.text=[NSString stringWithFormat:@"\u2001 %@", [[targets objectAtIndex:indexPath.row] objectForKey:@"targetName"]];
    }
    if ([[[targets objectAtIndex:indexPath.row] objectForKey:@"status"] isEqualToString:@"Online"])
    {
        cell.imageView.image = [UIImage imageNamed:@"Green_sphere.png"];
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"Red_sphere.png"];
    }
    
    return cell;
}
-(void)showTargetSettingsPopover:(id)sender
{
    CGRect pickedSubview=[self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:[sender tag] inSection:0]];
    [self.delegate didBeginEditingTarget:[[targets objectAtIndex:[sender tag]] objectForKey:@"targetID"]];
    
    [main getVoicesListForTargetID:[NSString stringWithFormat:@"%@", [[targets objectAtIndex:[sender tag]]objectForKey:@"targetID"]]];
    BOOL isOnline=NO;
    if ([[[targets objectAtIndex:[sender tag]]objectForKey:@"status"] isEqualToString:@"Online"])
    {
        isOnline=YES;
    }
    [targetSettings editTargetID:[[targets objectAtIndex:[sender tag]]objectForKey:@"targetID"] targetIsOnline:isOnline];
    [targetSettings setCurrentVoice:[[targets objectAtIndex:[sender tag]]objectForKey:@"selectedVoice"]];
    [targetSettingsView presentPopoverFromRect:pickedSubview inView:self.tableView permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([[cell.textLabel text]rangeOfString:@"\u2001"].location != NSNotFound)
    {
        cell.textLabel.text=[NSString stringWithFormat:@"\u2713 %@", [cell.textLabel.text substringFromIndex:2]];
        [selectedIndices replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
    }
    else
    {
        cell.textLabel.text=[NSString stringWithFormat:@"\u2001 %@", [cell.textLabel.text substringFromIndex:2]];
        [selectedIndices replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
    }
}
-(void)didReceiveTargetsList:(NSArray *)inTargets
{
    int lastNum=targets.count;
    targets=[NSMutableArray arrayWithArray:inTargets];
    [addTargetView sendTargets:inTargets];
    if (lastNum != targets.count)
    {
        [selectedIndices removeAllObjects];
        for (int i=0; i<targets.count; i++)
        {
            [selectedIndices addObject:[NSNumber numberWithBool:NO]];
        }
    }
    [self.tableView reloadData];
}
-(NSArray *)getSelectedTargetIDs
{
    NSMutableArray *targetsToSendTo=[[NSMutableArray alloc]init];
    for (int i=0; i<targets.count; i++)
    {
        if ([[selectedIndices objectAtIndex:i] boolValue])
        {
            [targetsToSendTo addObject:[[targets objectAtIndex:i]objectForKey:@"targetID"]];
        }
    }
    return targetsToSendTo;
}
-(void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [navBar.topItem setLeftBarButtonItem:doneButton animated:YES];
}
-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [navBar.topItem setLeftBarButtonItem:editButton animated:YES];
}
-(void)toggleEditing
{
    if ([self.tableView isEditing])
    {
        [self.tableView setEditing:NO animated:YES];
        [navBar.topItem setLeftBarButtonItem:editButton animated:YES];
        [navBar.topItem setRightBarButtonItem:nil animated:YES];
    }
    else
    {
        [self.tableView setEditing:YES animated:YES];
        [navBar.topItem setLeftBarButtonItem:doneButton animated:YES];
        [navBar.topItem setRightBarButtonItem:addTargetButton animated:YES];
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *idToRemove=[[targets objectAtIndex:indexPath.row] objectForKey:@"targetID"];
        [targets removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [main performSelector:@selector(deleteTargetID:) withObject:idToRemove afterDelay:0.5];
    }
}
-(void)showAddTargetView
{
    [addTargetView clearForm];
    addTargetView.modalPresentationStyle=UIModalPresentationFormSheet;
    [self presentModalViewController:addTargetView animated:YES];
}
@end
