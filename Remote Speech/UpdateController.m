//
//  UpdateController.m
//  Remote Speech
//
//  Created by Collin Mistr on 1/27/17.
//  Copyright (c) 2018 dosdude1 Apps. All rights reserved.
//

#import "UpdateController.h"

@implementation UpdateController

-(id)init
{
    return self;
}
-(instancetype)initWithUpdateURL:(NSString *)udURL withUpdateMetaURL:(NSString *)udMeta withWhatsNewURL:(NSString *)wnURL withFileSavePath:(NSString *)savePath withCurrentAppVersion:(NSString *)currentVersion
{
    self=[super initWithNibName:@"UpdaterWindows" bundle:nil];
    [super loadView];
    updateURL=udURL;
    updateMetaURL=udMeta;
    whatsNewURL=wnURL;
    fileSavePath=savePath;
    appVersion=currentVersion;
    connectionNum=1;
    return self;
}

-(void)checkForUpdateByUser:(BOOL)userChecked
{
    connectionNum=1;
    installAutomatically=NO;
    userCheckedUpdates=userChecked;
    NSURL* url = [NSURL URLWithString:updateMetaURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection start];
}
-(void)downloadWhatsNewText
{
    connectionNum=2;
    NSURL* url = [NSURL URLWithString:whatsNewURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection start];
}
-(void)checkForAndInstallUpdate
{
    connectionNum=1;
    userCheckedUpdates=NO;
    installAutomatically=YES;
    NSURL* url = [NSURL URLWithString:updateMetaURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection start];
}
- (void)connection: (NSURLConnection*) connection didReceiveResponse: (NSHTTPURLResponse*) response
{
    receivedData = [[NSMutableData alloc] initWithLength:0];
    dlSize = [response expectedContentLength];
}
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
    if (connectionNum==3)
    {
        percent = ((100.0/dlSize)*receivedData.length);
        [self.progressIndicator setDoubleValue:percent];
        [self.updatePercentLabel setStringValue:[[NSString stringWithFormat:@"%d", (int)percent] stringByAppendingString:@"%"]];
        [self.downloadProgressLabel setStringValue:[NSString stringWithFormat:@"%.1f/%.1f MB", receivedData.length/100000*.1, dlSize/1000000]];
    }
}
- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *localFile=@"";
    if (connectionNum==1)
    {
        localFile = [fileSavePath stringByAppendingPathComponent:[updateMetaURL lastPathComponent]];
        [receivedData writeToFile:localFile atomically:YES];
        [self downloadWhatsNewText];
    }
    else if (connectionNum==2)
    {
        localFile = [fileSavePath stringByAppendingPathComponent:[whatsNewURL lastPathComponent]];
        [receivedData writeToFile:localFile atomically:YES];
        connectionNum=1;
        [self processUpdateMeta];
    }
    else if (connectionNum==3)
    {
        localFile = [fileSavePath stringByAppendingPathComponent:[updateURL lastPathComponent]];
        [receivedData writeToFile:localFile atomically:YES];
        [self installUpdate];
    }
}
-(void)processUpdateMeta
{
    if ([self isUpdateAvailable])
    {
        NSString *whatsNew=[NSString stringWithContentsOfFile:[fileSavePath stringByAppendingPathComponent:[whatsNewURL lastPathComponent]] encoding:NSUTF8StringEncoding error:nil];
        [self.updateMessageField setString:whatsNew];
        [self showUpdateConfirmationWindow];
        if (installAutomatically)
        {
            [self setupUpdateWindow];
            [self prepareUpdate];
        }
    }
    else if (userCheckedUpdates)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"No Update Available"];
        [alert setInformativeText:@"There is no update available at this time."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    [[NSFileManager defaultManager]removeItemAtPath:[fileSavePath stringByAppendingPathComponent:[whatsNewURL lastPathComponent]] error:nil];
    [[NSFileManager defaultManager]removeItemAtPath:[fileSavePath stringByAppendingPathComponent:[updateMetaURL lastPathComponent]] error:nil];
}
-(BOOL)isUpdateAvailable
{
    NSString *updateMeta=[NSString stringWithContentsOfFile:[fileSavePath stringByAppendingPathComponent:[updateMetaURL lastPathComponent]] encoding:NSUTF8StringEncoding error:nil];
    return (![updateMeta isEqualToString:appVersion]);
}
-(void)showUpdateConfirmationWindow
{
    if (!updateConfirmationWindow)
    {
        updateConfirmationWindow=[[NSWindow alloc]initWithContentRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:YES];
        [updateConfirmationWindow setAnimationBehavior:NSWindowAnimationBehaviorAlertPanel];
        [updateConfirmationWindow setTitle:@"Update"];
        [updateConfirmationWindow setReleasedWhenClosed:NO];
    }
    [updateConfirmationWindow center];
    [updateConfirmationWindow makeKeyAndOrderFront:self];
    [updateConfirmationWindow.contentView addSubview:self.view];
}
- (IBAction)processUpdate:(id)sender
{
    if ([sender tag]==1)
    {
        [self setupUpdateWindow];
        [self prepareUpdate];
    }
    else
    {
        [updateConfirmationWindow close];
    }
}
-(void)setupUpdateWindow
{
    [updateConfirmationWindow setFrame:CGRectMake(updateConfirmationWindow.frame.origin.x, updateConfirmationWindow.frame.origin.y+(updateConfirmationWindow.frame.size.height-self.updateProgressView.frame.size.height)/2, self.updateProgressView.frame.size.width, self.updateProgressView.frame.size.height) display:YES animate:YES];
    NSMutableArray *subviews=[[NSMutableArray alloc]initWithArray:[updateConfirmationWindow.contentView subviews]];
    [subviews replaceObjectAtIndex:subviews.count-1 withObject:self.updateProgressView];
    [updateConfirmationWindow.contentView setSubviews:subviews];
}
-(void)triggerRelaunch
{
    NSString *daemonPath = [[NSBundle mainBundle] pathForResource:@"relaunch" ofType:nil];
	[NSTask launchedTaskWithLaunchPath:daemonPath arguments:[NSArray arrayWithObjects:[[NSBundle mainBundle] bundlePath], [NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]], nil]];
}
-(void)prepareUpdate
{
    connectionNum=3;
    [self.progressIndicator setMinValue:0.0];
    [self.progressIndicator setMaxValue:115.0];
    [self.progressIndicator startAnimation:self];
    [self performSelector:@selector(beginUpdate) withObject:nil afterDelay:0.75];
}
-(void)beginUpdate
{
    [self.progressIndicator setIndeterminate:NO];
    [self.updatePercentLabel setHidden:NO];
    [self.downloadProgressLabel setHidden:NO];
    NSURL* url = [NSURL URLWithString:updateURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection start];
}
-(void)installUpdate
{
    [self.updatePercentLabel setStringValue:@"100%"];
    [self.updateStatusLabel setStringValue:@"Installing Update..."];
    [self.updatePercentLabel setHidden:YES];
    [self.downloadProgressLabel setHidden:YES];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/unzip"];
    [task setArguments:[NSArray arrayWithObjects:@"-o", [fileSavePath stringByAppendingPathComponent:[updateURL lastPathComponent]], @"-d", [[NSBundle mainBundle] bundlePath], nil]];
    [task launch];
    [task waitUntilExit];
    [self performSelector:@selector(updateComplete) withObject:nil afterDelay:2.0];
}
-(void)updateComplete
{
    [self.progressIndicator setDoubleValue:115.0];
    [self.updateStatusLabel setStringValue:@"Update Installed Successfully."];
    [[NSFileManager defaultManager]removeItemAtPath:[fileSavePath stringByAppendingPathComponent:[updateURL lastPathComponent]] error:nil];
    [self triggerRelaunch];
    [[NSApplication sharedApplication] performSelector:@selector(terminate:) withObject:nil afterDelay:1.5];
}
@end
