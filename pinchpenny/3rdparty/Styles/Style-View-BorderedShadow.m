//
//  Style-View-BorderedShadow.m
//  tackboard
//
//  Created by Mike Doan on 3/7/12.
//  Copyright (c) 2012 Tackable. All rights reserved.
//

#import "Style-View-BorderedShadow.h"

@interface StyleViewBorderedShadow ()
- (void)initLayers;
- (void)initBorder;
- (void)addShadowLayer;
@end

@implementation StyleViewBorderedShadow

- (void)awakeFromNib {
    [self initLayers];
}


- (void)initLayers {
    [self initBorder];
    [self addShadowLayer];
    
}


- (void)initBorder {
    CALayer *layer = self.layer;
    layer.masksToBounds = YES;
    layer.borderWidth = 5.0f;
    layer.borderColor = [UIColor colorWithWhite:1.0f alpha:1.0f].CGColor;
    
    
}
- (void)addShadowLayer {
    CALayer *layer = self.layer;
    layer.masksToBounds = NO;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.4;
    layer.shadowRadius = 2.0;
    layer.shadowOffset = CGSizeMake(0, 1.2);
}


@end
