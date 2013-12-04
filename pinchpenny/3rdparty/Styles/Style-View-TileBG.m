//
//  Style-View-TileBG.m
//  toolbox
//
//  Created by Mike Doan on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Style-View-TileBG.h"

@interface StyleViewTileBG ()
- (void)initTileBG;
- (void)initLayers;

@end

@implementation StyleViewTileBG

- (void)awakeFromNib {
    [self initLayers];
}

- (void)initLayers{
    [self initTileBG];
}

- (void)initTileBG{
    UIImage *theImage = [UIImage imageNamed:@"tile-wood.jpg"];
    UIColor *theColor = [UIColor colorWithPatternImage:theImage];
    [self setBackgroundColor:theColor];
}

@end
