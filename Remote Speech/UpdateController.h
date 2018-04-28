//
//  UpdateController.h
//  Remote Speech
//
//  Created by Collin Mistr on 1/27/17.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateController : NSViewController <NSURLConnectionDelegate>
{
    NSString *updateURL;
    NSString *updateMetaURL;
    NSString *whatsNewURL;
    NSString *fileSavePath;
    NSString *appVersion;
    NSMutableData *receivedData;
    NSWindow *updateConfirmationWindow;
    int connectionNum;
    BOOL userCheckedUpdates;
    BOOL installAutomatically;
    double dlSize;
    double percent;
}
-(instancetype)initWithUpdateURL:(NSString *)udURL withUpdateMetaURL:(NSString *)udMeta withWhatsNewURL:(NSString *)wnURL withFileSavePath:(NSString *)savePath withCurrentAppVersion:(NSString *)currentVersion;
-(void)checkForUpdateByUser:(BOOL)userChecked;
-(void)checkForAndInstallUpdate;

@property (strong) IBOutlet NSTextView *updateMessageField;
- (IBAction)processUpdate:(id)sender;
@property (strong) IBOutlet NSView *updateProgressView;
@property (strong) IBOutlet NSTextField *updateStatusLabel;
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;
@property (strong) IBOutlet NSTextField *downloadProgressLabel;
@property (strong) IBOutlet NSTextField *updatePercentLabel;


@end
