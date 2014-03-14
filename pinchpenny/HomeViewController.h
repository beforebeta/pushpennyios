//
//  HomeViewController.h
//  pinchpenny
//
//  Created by Tackable Inc on 11/1/13.
//  Copyright (c) 2013 tackable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "FilterCategoryViewController.h"
#import "BaseIntroductionViewController.h"


@interface HomeViewController : GAITrackedViewController
<
UIScrollViewDelegate
,CLLocationManagerDelegate
,MKMapViewDelegate
,UITableViewDataSource
,UITableViewDelegate
,FilterCategoryViewControllerDelegate
,BaseIntroductionViewControllerDelegate,
UIAlertViewDelegate
>

@end
