//
//  AudioSelectionView.m
//  Remote Speech
//
//  Created by Collin Mistr on 1/11/18.
//  Copyright (c) 2018 Got 'Em Apps. All rights reserved.
//

#import "AudioSelectionView.h"

@interface AudioSelectionView ()

@end

@implementation AudioSelectionView


-(id)init
{
    self = [super init];
    darkModeEnabled = NO;
    IOS_VERSION = [[[UIDevice currentDevice] systemVersion] floatValue];
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView=[[UIView alloc]init];
    defaultBackgroundColor=[self.tableView backgroundColor];
    [self.navigationController.navigationBar.topItem setTitle:@"Send Audio"];
    closeModalButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(dismissModal)];
    [self.navigationItem setRightBarButtonItem:closeModalButton];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = paths.firstObject;
    audioPath = [documentsDirectory stringByAppendingPathComponent:@"Audio"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:audioPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:audioPath withIntermediateDirectories:YES attributes:nil error:nil];
        audioFileList = [[NSMutableArray alloc] init];
    }
    else
    {
        audioFileList = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:audioPath error:nil]];
        if ([audioFileList containsObject:@".DS_Store"])
        {
            [audioFileList removeObject:@".DS_Store"];
        }
        else if ([audioFileList containsObject:@".Trashes"])
        {
            [audioFileList removeObject:@".Trashes"];
        }
    }
    [self setUpPreviewButtons];
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
-(void)setUpPreviewButtons
{
    audioPreviewButtons = [[NSMutableArray alloc] init];
    for (int i=0; i<audioFileList.count; i++)
    {
        UIButton *playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [playPauseButton addTarget:self action:@selector(playPauseAudioPreview:) forControlEvents:UIControlEventTouchUpInside];
        [playPauseButton setTag:i];
        [playPauseButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        playPauseButton.frame = CGRectMake(0, 0, 60, 30);
        if (darkModeEnabled)
        {
            [playPauseButton setImage:[UIImage imageNamed:@"playbutton-dark"] forState:UIControlStateNormal];
        }
        else
        {
            [playPauseButton setImage:[UIImage imageNamed:@"playbutton"] forState:UIControlStateNormal];
        }
        [audioPreviewButtons addObject:playPauseButton];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (audioFileList.count > 0)
    {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.backgroundView = nil;
    }
    else
    {
        NSInteger labelHeight=25;
        UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (tableView.bounds.size.height/2)-labelHeight, tableView.bounds.size.width, labelHeight)];
        noDataLabel.text = @"No Audio Available";
        noDataLabel.font=[UIFont systemFontOfSize:22];
        noDataLabel.backgroundColor = [UIColor clearColor];
        noDataLabel.textAlignment = NSTextAlignmentCenter;
        UILabel *addAudioText = [[UILabel alloc] initWithFrame:CGRectMake(0, ((tableView.bounds.size.height/2)-labelHeight)+labelHeight+5, tableView.bounds.size.width, labelHeight)];
        addAudioText.text = @"You can add audio using iTunes File";
        addAudioText.backgroundColor = [UIColor clearColor];
        addAudioText.textAlignment = NSTextAlignmentCenter;
        UILabel *addAudioText2 = [[UILabel alloc] initWithFrame:CGRectMake(0, ((tableView.bounds.size.height/2)-labelHeight)+labelHeight+25, tableView.bounds.size.width, labelHeight)];
        addAudioText2.text = @"Sharing.";
        addAudioText2.backgroundColor = [UIColor clearColor];
        addAudioText2.textAlignment = NSTextAlignmentCenter;
        
        if (darkModeEnabled)
        {
            noDataLabel.textColor = [UIColor whiteColor];
            addAudioText.textColor = [UIColor whiteColor];
            addAudioText2.textColor = [UIColor whiteColor];
        }
        else
        {
            noDataLabel.textColor = [UIColor grayColor];
            addAudioText.textColor = [UIColor grayColor];
            addAudioText2.textColor = [UIColor grayColor];
        }
        UIView *bgView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height)];
        [bgView addSubview:noDataLabel];
        [bgView addSubview:addAudioText];
        [bgView addSubview:addAudioText2];
        tableView.backgroundView = bgView;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return [audioFileList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setAccessoryView:[audioPreviewButtons objectAtIndex:indexPath.row]];
    cell.textLabel.text=[audioFileList objectAtIndex:indexPath.row];;
    
    return cell;
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    indexToSend = indexPath.row;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Send Audio"
                                                    message:[NSString stringWithFormat:@"Are you sure you want to send \"%@\"?", [audioFileList objectAtIndex:indexPath.row]]
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Send", nil];
    [alert show];
}

-(void)dismissModal
{
    if (audioPlayer)
    {
        [audioPlayer stop];
        UIButton *cellPlayBtn = [audioPreviewButtons objectAtIndex:playingIndex];
        if (darkModeEnabled)
        {
            [cellPlayBtn setImage:[UIImage imageNamed:@"playbutton-dark"] forState:UIControlStateNormal];
        }
        else
        {
            [cellPlayBtn setImage:[UIImage imageNamed:@"playbutton"] forState:UIControlStateNormal];
        }
    }
    [self dismissModalViewControllerAnimated:YES];
}
-(void)playPauseAudioPreview:(id)sender
{
    if (audioPlayer && [sender tag] == playingIndex)
    {
        if ([audioPlayer isPlaying])
        {
            [audioPlayer pause];
            if (darkModeEnabled)
            {
                [sender setImage:[UIImage imageNamed:@"playbutton-dark"] forState:UIControlStateNormal];
            }
            else
            {
                [sender setImage:[UIImage imageNamed:@"playbutton"] forState:UIControlStateNormal];
            }
        }
        else
        {
            [audioPlayer play];
            if (darkModeEnabled)
            {
                [sender setImage:[UIImage imageNamed:@"pausebutton-dark"] forState:UIControlStateNormal];
            }
            else
            {
                [sender setImage:[UIImage imageNamed:@"pausebutton"] forState:UIControlStateNormal];
            }
        }
    }
    else
    {
        UIButton *cellPlayBtn = [audioPreviewButtons objectAtIndex:playingIndex];
        if (darkModeEnabled)
        {
            [cellPlayBtn setImage:[UIImage imageNamed:@"playbutton-dark"] forState:UIControlStateNormal];
        }
        else
        {
            [cellPlayBtn setImage:[UIImage imageNamed:@"playbutton"] forState:UIControlStateNormal];
        }
        NSString *audioFilePath = [NSString stringWithFormat:@"%@/Audio/%@", documentsDirectory, [audioFileList objectAtIndex:[sender tag]]];
        NSURL *audioFileURL = [NSURL fileURLWithPath:audioFilePath];
        if (audioPlayer)
        {
            [audioPlayer stop];
        }
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:nil];
        [audioPlayer setDelegate:self];
        [audioPlayer play];
        if (darkModeEnabled)
        {
            [sender setImage:[UIImage imageNamed:@"pausebutton-dark"] forState:UIControlStateNormal];
        }
        else
        {
            [sender setImage:[UIImage imageNamed:@"pausebutton"] forState:UIControlStateNormal];
        }
    }
    playingIndex = [sender tag];
}
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    UIButton *cellPlayBtn = [audioPreviewButtons objectAtIndex:playingIndex];
    if (darkModeEnabled)
    {
        [cellPlayBtn setImage:[UIImage imageNamed:@"playbutton-dark"] forState:UIControlStateNormal];
    }
    else
    {
        [cellPlayBtn setImage:[UIImage imageNamed:@"playbutton"] forState:UIControlStateNormal];
    }
}
-(void)setDarkModeEnabled:(BOOL)enabled
{
    darkModeEnabled = enabled;
    if (enabled)
    {
        [self.navigationController.toolbar setBarStyle:UIBarStyleBlack];
        [self.tableView setBackgroundColor:[UIColor colorWithRed:45.0/255.0 green:45.0/255.0 blue:45.0/255.0 alpha:1.0]];
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        if (IOS_VERSION >= 7.0)
        {
            [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
            [self.navigationController.toolbar setTintColor:[UIColor whiteColor]];
            [closeModalButton setTintColor:[UIColor whiteColor]];
        }
    }
    else
    {
        [self.navigationController.toolbar setBarStyle:UIBarStyleDefault];
        [self.view setBackgroundColor:defaultBackgroundColor];
        [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
        if (IOS_VERSION >= 7.0)
        {
            [self.navigationController.navigationBar setTintColor:nil];
            [self.navigationController.toolbar setTintColor:nil];
            [closeModalButton setTintColor:nil];
        }
    }
    [self setUpPreviewButtons];
    [self.tableView reloadData];
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
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 1:
            [self dismissModal];
            [self.delegate didSelectAudioFileToSend:[NSString stringWithFormat:@"%@/Audio/%@", documentsDirectory, [audioFileList objectAtIndex:indexToSend]]];
            break;
    }
}
@end
