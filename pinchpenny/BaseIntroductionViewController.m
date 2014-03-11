//
//  BaseIntroductionViewController.m
//  solomo.tyrell
//
//  Created by edward lucero on 2/15/14.
//  Copyright (c) 2014 tapclicks. All rights reserved.
//

#import "BaseIntroductionViewController.h"
#import "SwipeView.h"

#define TOTAL_BOARDING_PAGES (6)

@interface BaseIntroductionViewController ()
<SwipeViewDataSource, SwipeViewDelegate>
@property (weak, nonatomic) IBOutlet SwipeView *swipeView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *items;
@property (weak, nonatomic) IBOutlet UIView *btnStart;
@property (weak, nonatomic) IBOutlet UIButton *btnGetStarted;
@property (weak, nonatomic) IBOutlet UIButton *btnSkip;
@end

@implementation BaseIntroductionViewController


- (void)viewDidLoad
{
    NSLog(@"IntroductionViewController viewDidLoad");
    [super viewDidLoad];
    _swipeView.delegate = self;
    _swipeView.dataSource = self;
	self.items = [NSMutableArray array];
    for (int i = 0; i < TOTAL_BOARDING_PAGES; i++)
    {
        [_items addObject:@(i)];
    }
    self.pageControl.numberOfPages = TOTAL_BOARDING_PAGES;
    self.pageControl.currentPage = 0;
    _btnStart.hidden = YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)actionDismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionSkip:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    //return the total number of items in the carousel
    return [_items count];
}

- (void)swipeViewDidEndDecelerating:(SwipeView *)swipeView;
{
    self.pageControl.currentPage = swipeView.currentPage;
    if (swipeView.currentPage >=(TOTAL_BOARDING_PAGES-1)) {
        _btnGetStarted.hidden = NO;
        _btnSkip.hidden = YES;
    } 
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    UIImageView *imageBg = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        view = [[UIView alloc] initWithFrame:self.swipeView.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [label.font fontWithSize:50];
        label.tag = 1;
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    imageBg = [[UIImageView alloc] initWithFrame:view.bounds];
    imageBg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _btnStart.hidden = YES;
    switch (index) {
        case 0:
            [imageBg setImage:[UIImage imageNamed:@"onboarding1.png"]];
            break;
        case 1:
            [imageBg setImage:[UIImage imageNamed:@"onboarding2.png"]];
            break;
        case 2:
            [imageBg setImage:[UIImage imageNamed:@"onboarding3.png"]];
            break;
        case 3:
            [imageBg setImage:[UIImage imageNamed:@"onboarding4.png"]];
            break;
        case 4:
            [imageBg setImage:[UIImage imageNamed:@"onboarding5.png"]];
            break;
        case 5:
            [imageBg setImage:[UIImage imageNamed:@"onboarding6.png"]];
            break;
        default:
            [imageBg setImage:[UIImage imageNamed:@"onboarding6.png"]];
            break;
    }
    [view addSubview:imageBg];
    //    [view addSubview:label];
    
    //set background color
    CGFloat red = arc4random() / (CGFloat)INT_MAX;
    CGFloat green = arc4random() / (CGFloat)INT_MAX;
    CGFloat blue = arc4random() / (CGFloat)INT_MAX;
    view.backgroundColor = [UIColor colorWithRed:red
                                           green:green
                                            blue:blue
                                           alpha:1.0];
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    label.text = [_items[index] stringValue];
    
    return view;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return self.swipeView.bounds.size;
}


@end
