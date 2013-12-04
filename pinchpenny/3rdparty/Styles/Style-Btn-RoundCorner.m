//
//  Style-Btn-RoundCorner.m
//  tackboard
//
//  Created by Mike Doan on 2/29/12.
//  Copyright (c) 2012 Tackable. All rights reserved.
//

#import "Style-Btn-RoundCorner.h"


@interface RoundButton ()
- (void)initLayers;
- (void)initBorder;
- (void)addShineLayer;
- (void)addHighlightLayer;
@end


@implementation RoundButton


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
    [self addHighlightLayer];
}


- (void)initBorder {
    CALayer *layer = self.layer;
    layer.cornerRadius = 8.0f;
    layer.masksToBounds = NO;
    
    layer.borderWidth = 1.0f;
    layer.borderColor = [UIColor colorWithWhite:0.5f alpha:0.2f].CGColor;
    // A thin border.
    //layer.borderColor = [UIColor blackColor].CGColor;
    //layer.borderWidth = 0.3;
    
    // Drop shadow.
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.4;
    layer.shadowRadius = 2.0;
    layer.shadowOffset = CGSizeMake(0, 1.2);
}

#pragma mark -
#pragma mark Highlight button while touched


- (void)addHighlightLayer {
    highlightLayer = [CALayer layer];
    highlightLayer.backgroundColor = [UIColor colorWithRed:0.25f green:0.25f blue:0.25f alpha:0.75].CGColor;
    highlightLayer.cornerRadius = 8.0f;
    highlightLayer.masksToBounds = NO;
    highlightLayer.frame = self.layer.bounds;
    highlightLayer.hidden = YES;
    [self.layer insertSublayer:highlightLayer below:shineLayer];
}


- (void)setHighlighted:(BOOL)highlight {
    highlightLayer.hidden = !highlight;
    [super setHighlighted:highlight];
}

- (void)addShineLayer {
    //unimplemented
}
@end
