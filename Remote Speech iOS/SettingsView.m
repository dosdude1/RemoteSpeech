//
//  SettingsView.m
//  Remote Speech
//
//  Created by Collin Mistr on 6/7/17.
//  Copyright (c) 2017 Got 'Em Apps. All rights reserved.
//

#import "SettingsView.h"

@interface SettingsView ()

@end

@implementation SettingsView

-(id)init
{
    self=[super init];
    return self;
}
-(id)initWithStyle:(UITableViewStyle)style
{
    self=[super initWithStyle:style];
    numberOfSections = 2;
    IOS_VERSION = [[[UIDevice currentDevice] systemVersion] floatValue];
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    defaultBackgroundColor=[self.tableView backgroundColor];
    doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissModal)];
    [self.navigationController.navigationBar.topItem setRightBarButtonItem:doneButton];
    [self.navigationController.navigationBar.topItem setTitle:@"Settings"];
    darkModeSwitch = [[UISwitch alloc] init];
    [darkModeSwitch addTarget:self action:@selector(toggleDarkMode) forControlEvents:UIControlEventValueChanged];
    [darkModeSwitch setOn:[[PreferencesHandler sharedInstance] shouldUseDarkMode]];
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
-(void)dismissModal
{
    [self dismissModalViewControllerAnimated:YES];
}
-(void)toggleDarkMode
{
    [[PreferencesHandler sharedInstance] setShouldUseDarkMode:[darkModeSwitch isOn]];
}
-(void)setDarkModeEnabled:(BOOL)enabled
{
    darkModeEnabled=enabled;
    if (enabled)
    {
        [self.navigationController.toolbar setBarStyle:UIBarStyleBlack];
        [self.tableView setBackgroundColor:[UIColor colorWithRed:45.0/255.0 green:45.0/255.0 blue:45.0/255.0 alpha:1.0]];
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        if (IOS_VERSION >= 7.0)
        {
            [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        }
    }
    else
    {
        [self.navigationController.toolbar setBarStyle:UIBarStyleDefault];
        [self.tableView setBackgroundColor:defaultBackgroundColor];
        [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
        if (IOS_VERSION >= 7.0)
        {
            [self.navigationController.navigationBar setTintColor:nil];
        }
    }
    for (int i=0; i<numberOfSections; i++)
    {
        for (int j=0; j<[self getNumberOfRowsInSection:i]; j++)
        {
            SettingsTableCell *c = (SettingsTableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            if (c != nil)
            {
                [c setDarkModeEnabled:enabled];
            }
        }
    }
}
/*- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
    [sectionView setBackgroundColor:[UIColor blackColor]];
    return sectionView;
}*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self getNumberOfRowsInSection:section];
}
-(NSInteger)getNumberOfRowsInSection:(section)s
{
    switch (s)
    {
        case sectionGeneral:
            return 1;
            break;
        case sectionAccount:
            return 1;
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    SettingsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    switch (indexPath.section)
    {
        case sectionGeneral:
            switch (indexPath.row)
            {
                case 0:
                    cell = [[SettingsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                    cell.textLabel.text=@"Dark Mode";
                    cell.accessoryView = darkModeSwitch;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
            }
            break;
        case sectionAccount:
            switch (indexPath.row)
            {
                    
                case 0:
                    cell = [[SettingsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                    cell.textLabel.text=[NSString stringWithFormat:@"Username: %@", [[PreferencesHandler sharedInstance] getRememberedUsername]];
                    if (IOS_VERSION >= 7.0)
                    {
                        cell.lightModeTextColor = [UIColor colorWithRed:0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
                        cell.darkModeTextColor = [UIColor colorWithRed:0/255.0 green:122.0/255.0 blue:180.0/255.0 alpha:1.0];;
                    }
                    else
                    {
                        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
                    }
                    break;
                    
            }
            break;
    }
    if (cell == nil) {
        cell = [[SettingsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return @"General";
            break;
        case 1:
            return @"Account";
            break;
    }
    return @"";
}
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingsTableCell *c = (SettingsTableCell *)cell;
    [c setDarkModeEnabled:darkModeEnabled];
}
-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
    if (IOS_VERSION < 7.0)
    {
        [[view.subviews objectAtIndex:0] setBackgroundColor:[UIColor clearColor]];
    }
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case sectionAccount:
            switch (indexPath.row) {
                case 0:
                    [self showAccountActionsAlert];
                    break;
            }
            break;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(void)showAccountActionsAlert
{
    UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Username" message:[[PreferencesHandler sharedInstance] getRememberedUsername] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Sign Out",  nil];
    [alert setTag:alertAccountActions];
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case alertAccountActions:
            switch (buttonIndex)
            {
                case 1:
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidSignOut" object:nil];
                    break;
            }
            break;
    }
}
@end
