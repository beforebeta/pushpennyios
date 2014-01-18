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
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"
#import "GAIFields.h"
#import "GAILogger.h"
#import "GAITrackedViewController.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker.
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-47276819-1"];

    
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

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *) url {
    
    NSString *urlString = [url absoluteString];
    
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithName:@"tracker"
                                                        trackingId:@"UA-XXXX-Y"];
    
    // setCampaignParametersFromUrl: parses Google Analytics campaign ("UTM")
    // parameters from a string url into a Map that can be set on a Tracker.
    GAIDictionaryBuilder *hitParams = [[GAIDictionaryBuilder alloc] init];
    
    // Set campaign data on the map, not the tracker directly because it only
    // needs to be sent once.
    [[hitParams setCampaignParametersFromUrl:urlString] build];
    
    // Campaign source is the only required campaign field. If previous call
    // did not set a campaign source, use the hostname as a referrer instead.
    /*
    if(![hitParams valueForKey:kGAICampaignSource]) && [url host].length !=0) {
        // Set campaign data on the map, not the tracker.
        [hitParams set:kGAICampaignMedium
                 value:@"referrer"];
        [hitParams set:kGAICampaignSource
                 value:[url host]];
    }*/
    
    [tracker send:[[[GAIDictionaryBuilder createAppView] setAll:hitParams] build]];
    return YES;
}
@end
