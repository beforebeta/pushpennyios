//
//  Style-View-RoundCorner.m
//  tackboard
//
//  Created by Mike Doan on 3/6/12.
//  Copyright (c) 2012 Tackable. All rights reserved.
//

#import "Style-View-RoundCorner.h"
@interface StyleViewRoundCorner ()
- (void)initLayers;
- (void)initBorder;
@end

@implementation StyleViewRoundCorner

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  //  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initLayers];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
 //   [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)awakeFromNib {
    [self initLayers];
}




- (void)initLayers {
    [self initBorder];
}


- (void)initBorder {
    CALayer *layer = self.layer;
    self.layer.cornerRadius = 2.0f;
    layer.masksToBounds = YES;
    //layer.borderWidth = 1.0f;
    //layer.borderColor = [UIColor colorWithWhite:0.5f alpha:0.2f].CGColor;
}



@end
