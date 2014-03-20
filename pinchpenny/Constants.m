//
//  Constants.m
//  pinchpenny
//
//  Created by Tackable Inc on 10/24/13.
//  Copyright (c) 2013 tackable. All rights reserved.
//

#import "Constants.h"

@implementation Constants

 NSString* const kUserDefinedLatitude =     @"kUserDefinedLatitude";
 NSString* const kUserDefinedLongitude=     @"kUserDefinedLongitude";
 NSString* const kUserDefinedCategory=      @"kUserDefinedCategory";
 NSString* const kUserDefinedCategorySlug=  @"kUserDefinedCategorySlug";
 NSString* const kUserDefinedCategoryImage= @"kUserDefinedCategoryImage";
 NSString* const kUserDefinedCityState=     @"kUserDefinedCityState";

 NSString* const kUUID=                     @"kUDID";

 NSString* const kTutorialHasSeenBoarding   = @"kTutorialHasSeenBoarding";

// Default fallback location is san francisco
 NSString* const kDefaultLatitude           = @"40.7610";
 NSString* const kDefaultLongitude          = @"-73.9814";
 NSString* const kDefaultLocation           = @"New York, NY";
 NSString* const kDefaultBackgroundImage    = @"launch_640x1136.png";

 NSString* const kAPNSKeyFeedType           = @"fd";
 NSString* const kAPNSKeyKeyword            = @"ky";;
 NSString* const kAPNSKeyLatitude           = @"lt";
 NSString* const kAPNSKeyLongitude          = @"ln";
 NSString* const kAPNSKeyLocation           = @"lc";

 NSString* const kAPNSValueCategory         = @"ct";

 NSString* const kStringLocationNotFoundTitle   = @"Can't Find Your Location";
 NSString* const kStringLocationNotFoundBody    = @"We are unable to get your current location at the moment. Giving us your location allows us to automatically show you deals nearby. Enter your zip code or city instead?";

 NSString* const kStringLocationEnterZipTitle   = @"Enter Location";
 NSString* const kStringLocationEnterZipBody    = @"Enter your zip code or city and state.";

 NSString* const kStringLocationOffTitle        = @"Turn on Location Services Later";
 NSString* const kStringLocationOffFoundBody    = @"If you change your mind and want PushPenny to be able to determine your current location, go to Settings>Privacy>Location Services and look for PushPenny.";
@end
