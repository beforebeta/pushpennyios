//
//  Style-View-RoundCornerShadow.m
//  tackboard
//
//  Created by Mike Doan on 3/6/12.
//  Copyright (c) 2012 Tackable. All rights reserved.
//

#import "Style-View-RoundCornerShadow.h"
@interface StyleViewRoundCornerShadow ()
- (void)initLayers;
- (void)initBorder;
- (void)addShadowLayer;
@end

@implementation StyleViewRoundCornerShadow

- (void)awakeFromNib {
    [self initLayers];
}


- (void)initLayers {
    [self initBorder];
    [self addShadowLayer];
}


- (void)initBorder {
    CALayer *layer = self.layer;
    self.layer.cornerRadius = 8.0f;
    layer.masksToBounds = YES;
    layer.borderWidth = 1.0f;
    layer.borderColor = [UIColor colorWithWhite:0.5f alpha:0.2f].CGColor;
    
    
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
