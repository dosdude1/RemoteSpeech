//
//  TargetTableView.m
//  Remote Speech
//
//  Created by Collin Mistr on 1/3/17.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import "TargetTableView.h"

@interface TargetTableView ()

@end

@implementation TargetTableView

-(id)initWithMainController:(RemoteSpeechController *)inMain withNavigationBar:(UINavigationBar *)inNavBar
{
    self=[self init];
    main=inMain;
    main.tableDelegate=self;
    navBar=inNavBar;
    selectedIndex=0;
    darkModeEnabled=NO;
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
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView=[[UIView alloc]init];
    targets=[[NSMutableArray alloc]init];
    targetView=[[TargetViewController alloc]initWithMainController:main];
    CGSizeMake(targetView.view.frame.size.width, targetView.view.frame.size.height);
    editButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEditing)];
    doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleEditing)];
    addTargetButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddTargetView)];
    navBar.topItem.leftBarButtonItem = editButton;
    defaultBackgroundColor=[self.tableView backgroundColor];
    settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(showSettingsView)];
    self.navigationController.navigationBar.topItem.rightBarButtonItem=settingsButton;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
}
-(void)showSettingsView
{
    if (!settingsView)
    {
        settingsView = [[SettingsView alloc] initWithStyle:UITableViewStyleGrouped];
        settingsViewNavController = [[UINavigationController alloc] initWithRootViewController:settingsView];
        [settingsView setDarkModeEnabled:darkModeEnabled];
    }
    [self presentModalViewController:settingsViewNavController animated:YES];
}
-(void)setDarkModeEnabled:(BOOL)enabled
{
    darkModeEnabled=enabled;
    if (enabled)
    {
        [self.navigationController.toolbar setBarStyle:UIBarStyleBlack];
        [self.tableView setBackgroundColor:[UIColor colorWithRed:45.0/255.0 green:45.0/255.0 blue:45.0/255.0 alpha:1.0]];
        [navBar setBarStyle:UIBarStyleBlack];
        if (IOS_VERSION >= 7.0)
        {
            [navBar setTintColor:[UIColor whiteColor]];
            [self.navigationController.toolbar setTintColor:[UIColor whiteColor]];
            [settingsButton setTintColor:[UIColor whiteColor]];
        }
    }
    else
    {
        [self.navigationController.toolbar setBarStyle:UIBarStyleDefault];
        [self.view setBackgroundColor:defaultBackgroundColor];
        [navBar setBarStyle:UIBarStyleDefault];
        if (IOS_VERSION >= 7.0)
        {
            [navBar setTintColor:nil];
            [self.navigationController.toolbar setTintColor:nil];
            [settingsButton setTintColor:nil];
        }
    }
    [self.tableView reloadData];
    [settingsView setDarkModeEnabled:enabled];
    [targetView setDarkModeEnabled:enabled];
    [addTargetView setDarkModeEnabled:enabled];
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
        NSInteger labelHeight=25;
        UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (tableView.bounds.size.height/2)-labelHeight, tableView.bounds.size.width, labelHeight)];
        noDataLabel.text = @"No Targets Added";
        noDataLabel.font=[UIFont systemFontOfSize:22];
        noDataLabel.backgroundColor = [UIColor clearColor];
        noDataLabel.textAlignment = NSTextAlignmentCenter;
        UILabel *addTargetLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ((tableView.bounds.size.height/2)-labelHeight)+labelHeight+5, tableView.bounds.size.width, labelHeight)];
        addTargetLabel.text = @"Add a target by tapping \"Edit\", \"+\".";
        addTargetLabel.backgroundColor = [UIColor clearColor];
        addTargetLabel.textAlignment = NSTextAlignmentCenter;
        if (darkModeEnabled)
        {
            noDataLabel.textColor = [UIColor whiteColor];
            addTargetLabel.textColor = [UIColor whiteColor];
        }
        else
        {
            noDataLabel.textColor = [UIColor grayColor];
            addTargetLabel.textColor = [UIColor grayColor];
        }
        UIView *bgView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height)];
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
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text=[[targets objectAtIndex:indexPath.row] objectForKey:@"targetName"];
    //cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x, cell.imageView.frame.origin.y, 10, 10);
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
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (darkModeEnabled)
    {
        [cell setBackgroundColor:[UIColor blackColor]];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    else
    {
        [cell setBackgroundColor:[UIColor whiteColor]];
        cell.textLabel.textColor = [UIColor blackColor];
    }
}
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex=indexPath.row;
    [targetView getData:[[targets objectAtIndex:indexPath.row] objectForKey:@"targetID"] targetName:[[targets objectAtIndex:indexPath.row] objectForKey:@"targetName"] status:[[targets objectAtIndex:indexPath.row] objectForKey:@"status"] selectedVoice:[[targets objectAtIndex:indexPath.row] objectForKey:@"selectedVoice"]];
    [self.navigationController pushViewController:targetView animated:YES];
}

-(void)didReceiveTargetsList:(NSArray *)inTargets
{
    NSString *lastTargID=@"";
    if (targets.count > 0 && selectedIndex<targets.count)
    {
        lastTargID=[[targets objectAtIndex:selectedIndex] objectForKey:@"targetID"];
    }
    targets=[[NSMutableArray alloc] initWithArray:inTargets];
    [addTargetView sendTargets:inTargets];
    [self.tableView reloadData];
    if (selectedIndex<targets.count && [[[targets objectAtIndex:selectedIndex] objectForKey:@"targetID"] isEqualToString:lastTargID])
    {
        [targetView getData:[[targets objectAtIndex:selectedIndex] objectForKey:@"targetID"] targetName:[[targets objectAtIndex:selectedIndex] objectForKey:@"targetName"] status:[[targets objectAtIndex:selectedIndex] objectForKey:@"status"] selectedVoice:[[targets objectAtIndex:selectedIndex] objectForKey:@"selectedVoice"]];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}
-(void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [navBar.topItem setLeftBarButtonItem:doneButton animated:YES];
    [navBar.topItem setRightBarButtonItem:nil animated:YES];
}
-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [navBar.topItem setLeftBarButtonItem:editButton animated:YES];
    [navBar.topItem setRightBarButtonItem:settingsButton animated:YES];
}
-(void)toggleEditing
{
    if ([self.tableView isEditing])
    {
        [self.tableView setEditing:NO animated:YES];
        [navBar.topItem setLeftBarButtonItem:editButton animated:YES];
        [navBar.topItem setRightBarButtonItem:settingsButton animated:YES];
    }
    else
    {
        [self.tableView setEditing:YES animated:YES];
        [navBar.topItem setLeftBarButtonItem:doneButton animated:YES];
        [navBar.topItem setRightBarButtonItem:addTargetButton animated:YES];
    }
}
-(void)showAddTargetView
{
    [addTargetView clearForm];
    if (!addTargetView)
    {
        addTargetView=[[AddTargetView alloc]initWithMainController:main];
        [addTargetView sendTargets:targets];
        addTargetViewNavController=[[UINavigationController alloc]init];
        [addTargetViewNavController setViewControllers:[NSArray arrayWithObject:addTargetView]];
        [addTargetViewNavController.navigationBar.topItem setTitle:@"Add Target"];
        addTargetViewNavController.navigationBar.topItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:addTargetView action:@selector(dismissModal)];
        addTargetViewNavController.navigationBar.topItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStyleDone target:addTargetView action:@selector(addTarget)];
        [addTargetView setDarkModeEnabled:darkModeEnabled];
    }
    [self presentModalViewController:addTargetViewNavController animated:YES];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *idToRemove=[[targets objectAtIndex:indexPath.row] objectForKey:@"targetID"];
        [targets removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [main performSelector:@selector(deleteTargetID:) withObject:idToRemove afterDelay:0.5];
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

@end
