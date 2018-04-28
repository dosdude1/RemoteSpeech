//
//  FirstRunView.h
//  Remote Speech
//
//  Created by Collin Mistr on 12/29/16.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol FirstRunViewDelegate <NSObject>
@optional
- (void)didFinishTutorial;

@end
@interface FirstRunView : NSWindowController
{
    NSArray *viewArray;
    int currentIndex;
}
@property (nonatomic, strong) id <FirstRunViewDelegate> delegate;
@property (strong) IBOutlet NSView *introView;
@property (strong) IBOutlet NSView *targetsView;
@property (strong) IBOutlet NSView *interfaceView;
@property (strong) IBOutlet NSButton *nextButton;
@property (strong) IBOutlet NSView *extraFeaturesView;
@property (strong) IBOutlet NSView *gettingStartedView;
- (IBAction)nextAction:(id)sender;
- (IBAction)skipTutorial:(id)sender;
@property (strong) IBOutlet NSButton *backButton;
- (IBAction)backAction:(id)sender;


@end
