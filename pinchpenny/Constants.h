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

extern NSString* const kUUID;

@end
