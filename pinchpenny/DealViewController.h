//
//  DealViewController.h
//  pinchpenny
//
//  Created by Tackable Inc on 11/12/13.
//  Copyright (c) 2013 tackable. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DealViewController : GAITrackedViewController
 <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) NSDictionary *dealDict;

@end
