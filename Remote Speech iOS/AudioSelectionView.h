//
//  AudioSelectionView.h
//  Remote Speech
//
//  Created by Collin Mistr on 1/11/18.
//  Copyright (c) 2018 Got 'Em Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>


@protocol AudioSelectionDelegate <NSObject>
@optional
-(void)didSelectAudioFileToSend:(NSString *)path;
@end

@interface AudioSelectionView : UITableViewController <AVAudioPlayerDelegate, UIAlertViewDelegate>
{
    float IOS_VERSION;
    UIColor *defaultBackgroundColor;
    BOOL darkModeEnabled;
    UIBarButtonItem *closeModalButton;
    NSString *documentsDirectory;
    NSString *audioPath;
    NSMutableArray *audioFileList;
    NSMutableArray *audioPreviewButtons;
    AVAudioPlayer *audioPlayer;
    NSInteger playingIndex;
    NSInteger indexToSend;
}

-(id)init;
@property (nonatomic, strong) id <AudioSelectionDelegate> delegate;
-(void)setDarkModeEnabled:(BOOL)enabled;



@end
