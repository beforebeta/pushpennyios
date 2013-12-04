//
//  Style-imageView-RoundCorner.m
//  TackboardStoryboard
//
//  Created by Mike Doan on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Style-imageView-RoundCorner.h"



@interface RoundCorner ()
- (void)initLayers;
- (void)initBorder;
@end


@implementation RoundCorner


#pragma mark -
#pragma mark Initialization


- (void)awakeFromNib {
    [self initLayers];
}


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initLayers];
    }
    return self;
}


- (void)initLayers {
    [self initBorder];
}


- (void)initBorder {
    CALayer *layer = self.layer;
    layer.cornerRadius = 8.0f;
    layer.masksToBounds = YES;
    layer.borderWidth = 1.0f;
    layer.borderColor = [UIColor colorWithWhite:0.5f alpha:0.2f].CGColor;
}



@end
