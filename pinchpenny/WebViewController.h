//
//  WebViewController.h
//  pinchpenny
//
//  Created by Tackable Inc on 11/4/13.
//  Copyright (c) 2013 tackable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController
<UIWebViewDelegate>

@property (nonatomic, strong) NSString *strURL;
@property (nonatomic, strong) NSString *strSourceName;

@end
