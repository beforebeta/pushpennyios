//
//  BaseIntroductionViewController.h
//  solomo.tyrell
//
//  Created by edward lucero on 2/15/14.
//  Copyright (c) 2014 tapclicks. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BaseIntroductionViewControllerDelegate;

@interface BaseIntroductionViewController : UIViewController
@property (nonatomic, weak) id<BaseIntroductionViewControllerDelegate> delegate;
@end


@protocol BaseIntroductionViewControllerDelegate <NSObject>
@optional
- (void)fetchDealFeedwithPaging:(BOOL)usePaging;
- (void)refreshBackgroundImageUsingCurrentLocation;
@end


