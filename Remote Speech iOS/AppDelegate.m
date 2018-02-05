//
//  AppDelegate.m
//  Remote Speech iOS
//
//  Created by Collin Mistr on 12/31/16.
//  Copyright (c) 2016 Got 'Em Apps. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    shouldRotate=YES;
    main=[[RemoteSpeechController alloc]init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [self initViews];
    [self initPreferences];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signOut) name:@"UserDidSignOut" object:nil];
    return YES;
}
-(void)initViews
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        ipadLoginView=[[iPadLoginView alloc]initWithMainController:main];
    }
    else
    {
        iphoneLoginView=[[LoginViewController alloc]initWithMainController:main];
    }
}
-(void)initInitialiPadView:(BOOL)animate
{
    ipadLoginView.delegate=self;
    UINavigationController *navController=[[UINavigationController alloc]init];
    [navController setViewControllers:[NSArray arrayWithObject:ipadLoginView]];
    [navController.navigationBar.topItem setTitle:@"Remote Speech - Login"];
    if (animate)
    {
        if(UIInterfaceOrientationIsLandscape(self.window.rootViewController.interfaceOrientation))
        {
            [UIView transitionWithView:self.window
                              duration:0.5
                               options:UIViewAnimationOptionTransitionFlipFromBottom
                            animations:^{ [self.window setRootViewController:navController]; }
                            completion:nil];
        }
        else
        {
            [UIView transitionWithView:self.window
                              duration:0.5
                               options:UIViewAnimationOptionTransitionFlipFromRight
                            animations:^{ [self.window setRootViewController:navController]; }
                            completion:nil];
        }
    }
    else
    {
        [self.window setRootViewController:navController];
    }
}
-(void)initMainiPadView:(BOOL)animate
{
    UINavigationController *navController2=[[UINavigationController alloc]init];
    iPadTableViewController *iPadTable=[[iPadTableViewController alloc] initWithMainController:main withNavigationBar:navController2.navigationBar];
    iPadTargetViewController *iPadTargetView=[[iPadTargetViewController alloc]initWithMainController:main withTargetTable:iPadTable];
    [navController2 setViewControllers:[NSArray arrayWithObject:iPadTable]];
    [navController2.navigationBar.topItem setTitle:@"Targets"];
    UINavigationController *navController3=[[UINavigationController alloc]init];
    [navController3 setViewControllers:[NSArray arrayWithObject:iPadTargetView]];
    [navController3.navigationBar.topItem setTitle:@"Send Message"];
    [navController3.view setBackgroundColor:[UIColor whiteColor]];
    navController3.navigationBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(signOut)];
    UISplitViewController *splitVC=[[UISplitViewController alloc]init];
    [splitVC setDelegate:self];
    [splitVC setViewControllers:[NSArray arrayWithObjects:navController2, navController3, nil]];
    if (animate)
    {
        if(UIInterfaceOrientationIsLandscape(self.window.rootViewController.interfaceOrientation))
        {
            [UIView transitionWithView:self.window
                              duration:0.5
                               options:UIViewAnimationOptionTransitionFlipFromTop
                            animations:^{ [self.window setRootViewController:splitVC]; }
                            completion:nil];
        }
        else
        {
            [UIView transitionWithView:self.window
                              duration:0.5
                               options:UIViewAnimationOptionTransitionFlipFromLeft
                            animations:^{ [self.window setRootViewController:splitVC]; }
                            completion:nil];
        }
    }
    else
    {
        [self.window setRootViewController:splitVC];
    }
}
-(void)initInitialiPhoneView:(BOOL)animate
{
    shouldRotate=NO;
    iphoneLoginView.delegate=self;
    UINavigationController *navController=[[UINavigationController alloc]init];
    [navController setViewControllers:[NSArray arrayWithObject:iphoneLoginView]];
    [navController.navigationBar.topItem setTitle:@"Remote Speech - Login"];
    if (animate)
    {
        [UIView transitionWithView:self.window
                          duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{ [self.window setRootViewController:navController]; }
                        completion:nil];
    }
    else
    {
        [self.window setRootViewController:navController];
    }
}
-(void)initMainiPhoneView:(BOOL)animate
{
    shouldRotate=YES;
    UINavigationController *navController=[[UINavigationController alloc]init];
    mainiPhoneView=[[TargetTableView alloc]initWithMainController:main withNavigationBar:navController.navigationBar];
    [navController setViewControllers:[NSArray arrayWithObject:mainiPhoneView]];
    [navController.navigationBar.topItem setTitle:@"Targets"];
    [mainiPhoneView setDarkModeEnabled:[[PreferencesHandler sharedInstance] shouldUseDarkMode]];
    if (animate)
    {
        [UIView transitionWithView:self.window
                          duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{ [self.window setRootViewController:navController]; }
                        completion:nil];
    }
    else
    {
        [self.window setRootViewController:navController];
    }
}
-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (!shouldRotate)
        {
            return UIInterfaceOrientationMaskPortrait;
        }
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskAll;
}
-(void)initPreferences
{
    PreferencesHandler *ph = [PreferencesHandler sharedInstance];
    ph.darkModeDelegate=self;
    if ([ph shouldAutoLogin])
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [self initMainiPadView:NO];
        }
        else
        {
            [self initMainiPhoneView:NO];
        }
        [main loginToServer:[ph getRememberedUsername] withPassword:[ph getRememberedPassword] isRememberedAccount:YES];
    }
    else
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [self initInitialiPadView:NO];
        }
        else
        {
            [self initInitialiPhoneView:NO];
        }
    }
    if ([ph shouldUseDarkMode])
    {
        [self.window setBackgroundColor:[UIColor blackColor]];
    }
}
-(void)setPrefs:(BOOL)shouldRememberLogin withUsername:(NSString *)username withPassword:(NSString *)password
{
    [[PreferencesHandler sharedInstance] setRememberedUser:username withPassword:password];
}
-(void)didLoginSuccessfully
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self initMainiPadView:YES];
        [main sendToServer:[NSString stringWithFormat:@"send-targets\n"]];
    }
    else
    {
        [self initMainiPhoneView:YES];
        [main sendToServer:[NSString stringWithFormat:@"send-targets\n"]];
    }
}
-(void)signOut
{
    [main closeSocket];
    [main initSocket];
    [[PreferencesHandler sharedInstance] setRememberedUser:@"" withPassword:@""];
    [[PreferencesHandler sharedInstance] setShouldUseDarkMode:NO];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self initInitialiPadView:YES];
    }
    else
    {
        [self initInitialiPhoneView:YES];
    }
}
- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController: (UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    
    //  Force master view to show in portrait and landscape
    
    return NO;
}
-(void)darkModeChangedToState:(BOOL)state
{
    [mainiPhoneView setDarkModeEnabled:state];
    if (state)
    {
        [self.window setBackgroundColor:[UIColor blackColor]];
    }
    else
    {
        [self.window setBackgroundColor:[UIColor whiteColor]];
    }
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //[main temporarilyCloseSocket];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //[main resumeSocket];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [main closeSocket];
}


@end
