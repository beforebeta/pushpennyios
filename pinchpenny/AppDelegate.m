//
//  AppDelegate.m
//  pinchpenny
//
//  Created by Tackable Inc on 10/23/13.
//  Copyright (c) 2013 tackable. All rights reserved.
//

#import "AppDelegate.h"
#import "Flurry.h"
#import "UAirship.h"
#import "UAConfig.h"
#import "UAPush.h"
#import "iRate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"VQNHJC57WHGP8MXYMWKN"];
    if (![[NSUserDefaults standardUserDefaults]objectForKey:kUUID]) {
        NSString *uuid = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults]setObject:uuid forKey:kUUID];
        [Flurry setUserID:uuid];
    }
    // Populate AirshipConfig.plist with your app's info from https://go.urbanairship.com
    // or set runtime properties here.
    UAConfig *config = [UAConfig defaultConfig];
    // Call takeOff (which creates the UAirship singleton)
    [UAirship takeOff:config];
    // Request a custom set of notification types
    [UAPush shared].notificationTypes = (UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound |
                                         UIRemoteNotificationTypeAlert |
                                         UIRemoteNotificationTypeNewsstandContentAvailability);
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:151.0/255.0 green:71.0/255.0 blue:48.0/255.0 alpha:1.0]];
    }
    return YES;
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
//    if ([[NSUserDefaults standardUserDefaults]objectForKey:kUUID]) {
//        NSString *uuid = [[NSUserDefaults standardUserDefaults]objectForKey:kUUID];
//        [Flurry setUserID:uuid];
//    }
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"url recieved: %@", url);
    NSLog(@"query string: %@", [url query]);
    NSLog(@"host: %@", [url host]);
    NSLog(@"url path: %@", [url path]);
//    NSDictionary *dict = [self parseQueryString:[url query]];
//    NSLog(@"query dict: %@", dict);
    NSDictionary *payload = [[NSDictionary alloc]initWithObjectsAndKeys:@"gym",@"keyword", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"handlingOpenURL" object:payload];
    // NOTE TO SELF ON MODEL USING NOTIFCATIONS.
    /*
    NSDictionary * chatstream = [[dictionary objectForKey:@"chatstreams"]objectAtIndex:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewChannelFromContactDetails" object:chatstream];
     */
    /*
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(requestingChannelCreation:)
     name:@"NewChannelFromContactDetails"
     object:nil];
     */
    /*
     - (void)requestingChannelCreation:(NSNotification *)notification {
     NSLog(@"createNewChannelFromUserProfileTab %@", notification.object);
     chatChannelPendingID = [notification.object objectForKey:@"chat_stream_id"];
     flagIsWaitingForPendingChatCreation = YES;
     [SVProgressHUD showWithStatus:@"conectar..."];
     // Show HUD max 5 sec to avoid blocking the app
     double delayInSeconds = 5.0;
     dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
     dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
     [SVProgressHUD dismiss];
     });
     }
     */
    return YES;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
    CGPoint location = [[[event allTouches] anyObject] locationInView:[self window]];
	if(location.y > 0 && location.y < 20) {
		[self touchStatusBar];
	}
}

- (void) touchStatusBar {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"touchStatusBarClick" object:nil];
}

+ (void)initialize
{
    NSLog(@"initialize");
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 2;
    [iRate sharedInstance].usesUntilPrompt = 2;
}

#pragma mark - Utility

- (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [dict setObject:val forKey:key];
    }
    return dict;
}

@end
