//
//  Style-View-Circle.m
//  tackboard
//
//  Created by Mike Doan on 3/6/12.
//  Copyright (c) 2012 Tackable. All rights reserved.
//

#import "Style-View-Circle.h"
@interface StyleViewCircle ()
- (void)initLayers;
- (void)initBorder;
@end

@implementation StyleViewCircle

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
    self.layer.cornerRadius = 15.0f;
    layer.masksToBounds = YES;
    layer.borderWidth = 2.0f;
    layer.borderColor = [UIColor colorWithWhite:1.0f alpha:1.0f].CGColor;
}



@end
