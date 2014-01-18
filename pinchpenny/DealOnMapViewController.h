//
//  DealOnMapViewController.h
//  pinchpenny
//
//  Created by Tackable Inc on 11/12/13.
//  Copyright (c) 2013 tackable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GAITrackedViewController.h"


@interface DealOnMapViewController : GAITrackedViewController
<MKMapViewDelegate>

@property (nonatomic, strong) NSString *strLat;
@property (nonatomic, strong) NSString *strLon;
@property (nonatomic, strong) NSString *strBusinessName;
@property (nonatomic, strong) NSString *strAddress;
@end
