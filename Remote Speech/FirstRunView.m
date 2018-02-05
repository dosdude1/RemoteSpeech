//
//  FirstRunView.m
//  Remote Speech
//
//  Created by Collin Mistr on 12/29/16.
//  Copyright (c) 2016 Got 'Em Apps. All rights reserved.
//

#import "FirstRunView.h"

@interface FirstRunView ()

@end

@implementation FirstRunView

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    currentIndex=0;
    viewArray=[[NSArray alloc]initWithObjects:self.introView, self.interfaceView, self.targetsView, self.extraFeaturesView, self.gettingStartedView, nil];
    [self.window.contentView addSubview:[viewArray objectAtIndex:currentIndex]];
    [self.backButton setEnabled:NO];
}

- (IBAction)nextAction:(id)sender
{
    currentIndex++;
    if (currentIndex == viewArray.count-1)
    {
        [self.nextButton setTitle:@"Finish"];
    }
    if (currentIndex < viewArray.count)
    {
        NSMutableArray *subviews = [[NSMutableArray alloc]initWithArray:[self.window.contentView subviews]];
        [subviews replaceObjectAtIndex:[subviews count]-1 withObject:[viewArray objectAtIndex:currentIndex]];
        [self.window.contentView setSubviews:subviews];
    }
    else
    {
        [self closeWindow];
    }
    [self.backButton setEnabled:YES];
}

- (IBAction)skipTutorial:(id)sender
{
    [self closeWindow];
}
- (IBAction)backAction:(id)sender
{
    currentIndex--;
    NSMutableArray *subviews = [[NSMutableArray alloc]initWithArray:[self.window.contentView subviews]];
    [subviews replaceObjectAtIndex:[subviews count]-1 withObject:[viewArray objectAtIndex:currentIndex]];
    [self.window.contentView setSubviews:subviews];
    if (currentIndex == 0)
    {
        [self.backButton setEnabled:NO];
    }
    [self.nextButton setTitle:@"Next"];
}
-(void)closeWindow
{
    [self.delegate didFinishTutorial];
    [self.window close];
}
@end
