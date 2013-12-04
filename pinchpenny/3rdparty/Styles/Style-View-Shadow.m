//
//  Style-View-Shadow.m
//  toolbox
//
//  Created by Mike Doan on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Style-View-Shadow.h"

@interface StyleViewShadow ()
- (void)initLayers;
- (void)initBorder;
@end

@implementation StyleViewShadow

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