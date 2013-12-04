//
//  DealOnMapViewController.m
//  pinchpenny
//
//  Created by Tackable Inc on 11/12/13.
//  Copyright (c) 2013 tackable. All rights reserved.
//

#import "DealOnMapViewController.h"
#import "Flurry.h"

@interface DealOnMapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation DealOnMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // SetUp Custom NavBar Settings
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, [UIFont fontWithName:@"Avenir-Light" size:18.0], UITextAttributeFont,nil];
    UIImage *buttonImage = [UIImage imageNamed:@"btn-back.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 30, 30);
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = customBarItem;
    self.navigationItem.title = _strBusinessName;
    // SetUp Map
	double lat = [_strLat doubleValue];
    double lon = [_strLon doubleValue];
    CLLocationCoordinate2D dealPos = CLLocationCoordinate2DMake(lat, lon);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(dealPos, 500, 500);
    [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
    // Add an annotation
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = dealPos;
    point.title = _strBusinessName;
    point.subtitle = _strAddress;
    [_mapView addAnnotation:point];
    [_mapView selectAnnotation:point animated:YES];
}
- (void)viewDidAppear:(BOOL)animated
{
    [Flurry logPageView];
}

-(void)back {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
