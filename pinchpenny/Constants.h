//
//  Constants.h
//  pinchpenny
//
//  Created by Tackable Inc on 10/24/13.
//  Copyright (c) 2013 tackable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define BASE_URL_DEALS @"http://api.pushpenny.com"
#define DEFAULT_BACKGROUND_IMAGE_URL @"http://pushpenny.com/static/img/favicon.png"
#define API_KEY_SQUOOT @"OO0-fDnsPF8UX8GYTIUB"
#define API_KEY_PUSHPENNY @"h7n8we"

extern NSString* const kUserDefinedLatitude;
extern NSString* const kUserDefinedLongitude;
extern NSString* const kUserDefinedCityState;
extern NSString* const kUserDefinedCategory;
extern NSString* const kUserDefinedCategoryImage;
extern NSString* const kUserDefinedCategorySlug;

extern NSString* const kTutorialHasSeenBoarding;

extern NSString* const kDefaultLatitude;
extern NSString* const kDefaultLongitude;
extern NSString* const kDefaultLocation;
extern NSString* const kDefaultBackgroundImage;
extern NSString* const kDefaultBackgroundImage;

extern NSString* const kUUID;

extern NSString* const kAPNSKeyFeedType;
extern NSString* const kAPNSKeyKeyword;
extern NSString* const kAPNSKeyLatitude;
extern NSString* const kAPNSKeyLongitude;
extern NSString* const kAPNSKeyLocation;

extern NSString* const kAPNSValueCategory;
extern NSString* const kAPNSValueDeal;
extern NSString* const kAPNSValueDealID;

extern NSString* const kStringLocationNotFoundTitle;
extern NSString* const kStringLocationNotFoundBody;

extern NSString* const kStringLocationEnterZipTitle;
extern NSString* const kStringLocationEnterZipBody;

extern NSString* const kStringLocationOffTitle;
extern NSString* const kStringLocationOffFoundBody;

@end

/*
 
 SINGLE DEAL
 http://api.pushpenny.com/v3/deal?api_key=h7n8we&ref_id=1711200
 
 URL
 
 pushpenny://api?fd=dl&id=1711200
 
 pushpenny://api?fd=ct&key=bags&lt=37.7749295&ln=-122.4194155&lc=San%20Francisco
 
 // APNS
 
 [{
 "_" = uZyrIKsHEeOPigAbIbyL6A;
 aps = {
 alert = "single device 3";
 badge = 1;
 sound = "bingbong.aiff";
 };
 fd = ct;
 ky = Shoes;
 lc = "San Francisco";
 ln = "-122.4194155";
 lt = "37.7749295";
 }]
 
 */
