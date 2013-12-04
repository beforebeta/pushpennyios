//
//  Style-Btn-RoundCorner.h
//  tackboard
//
//  Created by Mike Doan on 2/29/12.
//  Copyright (c) 2012 Tackable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface RoundButton : UIButton {
    CAGradientLayer *shineLayer;
    CALayer         *highlightLayer;
}

@end
