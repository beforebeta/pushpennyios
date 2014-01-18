//
//  FilterCategoryViewController.h
//  pinchpenny
//
//  Created by Tackable Inc on 11/4/13.
//  Copyright (c) 2013 tackable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GAITrackedViewController.h"


@protocol FilterCategoryViewControllerDelegate;

@interface FilterCategoryViewController : GAITrackedViewController
<UITableViewDataSource
,UITableViewDelegate
,UITextFieldDelegate
,CLLocationManagerDelegate
>

@property (nonatomic, weak) id<FilterCategoryViewControllerDelegate> delegate;
@end

@protocol FilterCategoryViewControllerDelegate <NSObject>
- (void)fetchDealFeedwithPaging:(BOOL)usePaging;
- (void)setBackgroundImageWithURL:(NSString *)imageURL;
@end
