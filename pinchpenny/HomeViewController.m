//
//  HomeViewController.m
//  pinchpenny
//
//  Created by Tackable Inc on 11/1/13.
//  Copyright (c) 2013 tackable. All rights reserved.
//

#import "HomeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AFHTTPRequestOperationManager.h"
#import "UIImageView+AFNetworking.h"
#import "DKLiveBlurView.h"
#import "MapPin.h"
#import <Accelerate/Accelerate.h>
#import "DealViewController.h"
#import "Flurry.h"

#define kDKTableViewDefaultContentInset 0.0f
#define kTableCell_HeaderBody 0
#define RESULTS_PER_PAGE @"100"
#define SEARCH_RADIUS @"100"

@interface HomeViewController ()
{
    BOOL flagMapVisible;
    BOOL flagFeedFetchInProgress;
    NSMutableArray *lastQueryArray;
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    NSIndexPath *selectedIndexPath;
    UIRefreshControl *refreshControl;
    // MAP
    NSMutableDictionary *selectedDictionary;
    DKLiveBlurView *backgroundView;
    
    //Scrollview tracking
    BOOL flagNoMoreDeals;
    int pageNumber;
    CGPoint lastOffSet;
    // MAP BUG
    BOOL flagUserLocationNotKnown;
    BOOL hasScrolled;
    
    NSString *strUUID;
}
@property (weak, nonatomic) IBOutlet UILabel *labelNavTitle;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *viewMap;
@property (weak, nonatomic) IBOutlet UIView *viewForTable;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *viewMenuLocationCategory;
@property (weak, nonatomic) IBOutlet UIView *viewMenuLocationCategoryOnMap;
@property (weak, nonatomic) IBOutlet UILabel *labelMenuCityStateMap;
@property (weak, nonatomic) IBOutlet UILabel *labelMenuCityStateList;
@property (weak, nonatomic) IBOutlet UILabel *labelMenuCategoryList;
@property (weak, nonatomic) IBOutlet UILabel *labelMenuCategoryMap;
@property (weak, nonatomic) IBOutlet UIView *viewTableHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imageTableBackground;
@end

@implementation HomeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    if(YES){
        [self performSegueWithIdentifier:@"boarding" sender:self];
    }
    if (![[NSUserDefaults standardUserDefaults]objectForKey:kUUID]) {
        strUUID = [[NSUUID UUID] UUIDString];
    } else {
        strUUID =[[NSUserDefaults standardUserDefaults]objectForKey:kUUID];
    }
    [_labelNavTitle setFont:[UIFont fontWithName:@"Quicksand-Regular" size:28]];
    if (![[NSUserDefaults standardUserDefaults]objectForKey:kUserDefinedCategory]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"All Deals" forKey:kUserDefinedCategory];
        [[NSUserDefaults standardUserDefaults] setObject:@"all" forKey:kUserDefinedCategorySlug];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

    pageNumber = 1;
    flagFeedFetchInProgress = NO;
    // UI
    _viewMenuLocationCategory.layer.shadowColor = [UIColor blackColor].CGColor;
    _viewMenuLocationCategory.layer.shadowOpacity = 0.3;
    _viewMenuLocationCategory.layer.shadowOffset = CGSizeMake(1, 1);
    _viewMenuLocationCategory.layer.shadowRadius = 4;
    _viewMenuLocationCategoryOnMap.layer.shadowColor = [UIColor blackColor].CGColor;
    _viewMenuLocationCategoryOnMap.layer.shadowOpacity = 0.3;
    _viewMenuLocationCategoryOnMap.layer.shadowOffset = CGSizeMake(1, 1);
    _viewMenuLocationCategoryOnMap.layer.shadowRadius = 4;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _mapView.delegate = self;
    // UNCOMMENT IF YOU WANT TO USE REFRESH CONTROLS
//    refreshControl = [[UIRefreshControl alloc] init];
//    [refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
//    [self.tableView addSubview:refreshControl];
//    [self setBackgroundImageWithURL:DEFAULT_BACKGROUND_IMAGE_URL];
    
    backgroundView = [[DKLiveBlurView alloc] initWithFrame: self.view.bounds];
    backgroundView.scrollView = self.tableView;
    backgroundView.isGlassEffectOn = YES;
    
    self.tableView.backgroundView = backgroundView;
    self.tableView.contentInset = UIEdgeInsetsMake(kDKTableViewDefaultContentInset, 0, 0, 0);
    // Add Geture for navigation bar
    UITapGestureRecognizer *navSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navSingleTap)];
    navSingleTap.numberOfTapsRequired = 1;
    [[self.navigationController.navigationBar.subviews objectAtIndex:1] setUserInteractionEnabled:YES];
    [[self.navigationController.navigationBar.subviews objectAtIndex:1] addGestureRecognizer:navSingleTap];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navSingleTap) name:@"touchStatusBarClick" object:nil];
    // Network
    [_activityIndicator startAnimating];
    // Location
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    [self getUserLocation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [Flurry logPageView];
}

#pragma mark - Actions

//- (void)refreshData:(UIRefreshControl *)refreshControl {
//    [self fetchDealFeed];
//}

- (IBAction)flipviews:(id)sender
{
    [UIView transitionWithView:_viewContainer
                      duration:1.0
                       options:(flagMapVisible ? UIViewAnimationOptionTransitionFlipFromRight :
                                UIViewAnimationOptionTransitionFlipFromLeft)
                    animations: ^{
                        if(flagMapVisible)
                        {
                            [Flurry logEvent:@"Action_ViewDealsList"];
                            _viewForTable.hidden = NO;
                            _viewMap.hidden = YES;
                        }
                        else
                        {
                            [Flurry logEvent:@"Action_ViewDealsMap"];
                            _viewForTable.hidden = YES;
                            _viewMap.hidden = NO;
                        }
                    }
     
                    completion:^(BOOL finished) {
                        if (finished) {
                            flagMapVisible = !flagMapVisible;
                        }
                    }];
}

- (IBAction)actionShowFilterView:(id)sender {
    
    [self performSegueWithIdentifier:@"filterview" sender:self];
}

- (IBAction)actionRefreshUserLocation:(id)sender {
    [self getUserLocation];
}

- (IBAction)actionRefreshDealsAtMapCenter:(id)sender {
    CLLocationCoordinate2D centre = [_mapView centerCoordinate];
    NSString *strLon = [NSString stringWithFormat:@"%.8f", centre.longitude];
    NSString *strLat = [NSString stringWithFormat:@"%.8f", centre.latitude];
    [[NSUserDefaults standardUserDefaults]setObject:strLon forKey:kUserDefinedLongitude];
    [[NSUserDefaults standardUserDefaults]setObject:strLat forKey:kUserDefinedLatitude];
    [self fetchDealFeedwithPaging:NO];
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:centre.latitude longitude:centre.longitude];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            NSLog(@"%@",[NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                         placemark.subThoroughfare, placemark.thoroughfare,
                         placemark.postalCode, placemark.locality,
                         placemark.administrativeArea,
                         placemark.country]);
            NSString *strCityState = [NSString stringWithFormat:@"%@, %@",placemark.locality,placemark.administrativeArea];
            [[NSUserDefaults standardUserDefaults]setObject:strCityState forKey:kUserDefinedCityState];
            [self updateFeedParameters];
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];

}

-(void)navSingleTap;
{
    [_tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

#pragma mark - Network

- (void)clearTable;
{
    [lastQueryArray removeAllObjects];
    [self.tableView reloadData];
}


- (void)fetchDealFeedwithPaging:(BOOL)usePaging;
{
    NSLog(@"fetchDealFeed");
    if (flagFeedFetchInProgress) {
        return;
    }
    [_activityIndicator startAnimating];
    [self updateFeedParameters];
    if (!usePaging) {
        pageNumber = 1;
        flagNoMoreDeals = NO;
        [self clearTable];
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        lastOffSet = _tableView.contentOffset;
        [self.tableView reloadData];
    }
    
    NSString *strPageNumber = [NSString stringWithFormat:@"%i",pageNumber];
    NSString *strLat = [[NSUserDefaults standardUserDefaults]objectForKey:kUserDefinedLatitude];
    NSString *strLon = [[NSUserDefaults standardUserDefaults]objectForKey:kUserDefinedLongitude];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *feedURL;
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:kUserDefinedCategorySlug]isEqualToString:@"all"]) {
        feedURL = [NSString stringWithFormat:@"%@/v2/deals?api_key=%@&location=%@,%@&radius=%@&per_page=%@&page=%@&order=distance&id=%@",BASE_URL_DEALS, API_KEY_PUSHPENNY,strLat,strLon,SEARCH_RADIUS,RESULTS_PER_PAGE,strPageNumber,strUUID];
    } else {
        NSString *strKeywordCategory =[[NSUserDefaults standardUserDefaults]objectForKey:kUserDefinedCategorySlug];
        NSString *stringForSearch = [strKeywordCategory stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        feedURL = [NSString stringWithFormat:@"%@/v2/deals?api_key=%@&location=%@,%@&radius=%@&query=%@&per_page=%@&page=%@&order=distance&id=%@",BASE_URL_DEALS,API_KEY_PUSHPENNY,strLat,strLon,SEARCH_RADIUS,stringForSearch,RESULTS_PER_PAGE,strPageNumber,strUUID];
    }
    NSLog(@"feedURL = [%@]",feedURL);
    flagFeedFetchInProgress = YES;
    [manager GET:feedURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
        hasScrolled = NO;
        [_activityIndicator stopAnimating];
        flagFeedFetchInProgress = NO;
        if ([responseObject count]>0) {
            if (!usePaging) {
                lastQueryArray = [NSMutableArray arrayWithArray:[responseObject objectForKey:@"deals"]];
                NSLog(@"lastQueryArray count !usePaging = [%i]",[lastQueryArray count]);
            } else {
                [lastQueryArray addObjectsFromArray:[responseObject objectForKey:@"deals"]];
                NSLog(@"lastQueryArray count = [%i]",[lastQueryArray count]);
            }
            if ([[responseObject objectForKey:@"deals"] count] <100) {
                flagNoMoreDeals = YES;
            }
            [self.tableView reloadData];
            [self setMapToUserDefinedLocation];
            [self addDealsToMap];
        }
        [refreshControl endRefreshing];
        [self nudgeScrollViewForEffect];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_activityIndicator stopAnimating];
        flagFeedFetchInProgress = NO;
        NSLog(@"Error: %@", error);
        [refreshControl endRefreshing];
    }];
}

- (void)fetchCategoryKeywordFeed;
{
    NSString *strLat = [[NSUserDefaults standardUserDefaults]objectForKey:kUserDefinedLatitude];
    NSString *strLon = [[NSUserDefaults standardUserDefaults]objectForKey:kUserDefinedLongitude];
//    NSString *feedURL = @"http://api.pushpenny.com/v2/localinfo?api_key=h7n8we";
    NSString *feedURL = [NSString stringWithFormat:@"http://api.pushpenny.com/v2/localinfo?api_key=h7n8we&location=%@,%@",strLat,strLon];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:feedURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"fetchCategoryKeywordFeed [%@]", responseObject);
        NSString *url = [responseObject objectForKey:@"default_image"];
        [self setBackgroundImageWithURL:url];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

- (void)updateFeedParameters;
{
    NSString *strCityState =[[NSUserDefaults standardUserDefaults]objectForKey:kUserDefinedCityState];
    NSString *strCategory =[[NSUserDefaults standardUserDefaults]objectForKey:kUserDefinedCategory];
    _labelMenuCityStateList.text = strCityState;
    _labelMenuCategoryList.text = strCategory;
    _labelMenuCityStateMap.text = strCityState;
    _labelMenuCategoryMap.text = strCategory;
}

#pragma mark - CLLocationManagerDelegate

- (void)getUserLocation;
{
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
    [[NSUserDefaults standardUserDefaults]setObject:@"37.7749295" forKey:kUserDefinedLongitude];
    [[NSUserDefaults standardUserDefaults]setObject:@"-122.4194155" forKey:kUserDefinedLatitude];
    NSString *strCityState = [NSString stringWithFormat:@"Enter location to begin"];
    [[NSUserDefaults standardUserDefaults]setObject:strCityState forKey:kUserDefinedCityState];
    flagUserLocationNotKnown = YES;
    [self updateFeedParameters];
    [self fetchDealFeedwithPaging:NO];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    if (currentLocation != nil) {
        NSString *strLon = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        NSString *strLat = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        [[NSUserDefaults standardUserDefaults]setObject:strLon forKey:kUserDefinedLongitude];
        [[NSUserDefaults standardUserDefaults]setObject:strLat forKey:kUserDefinedLatitude];
        [Flurry setLatitude:currentLocation.coordinate.latitude
                  longitude:currentLocation.coordinate.longitude horizontalAccuracy:currentLocation.horizontalAccuracy verticalAccuracy:currentLocation.verticalAccuracy];
        [self fetchCategoryKeywordFeed];
        [self fetchDealFeedwithPaging:NO];
    }
    // Stop Location Manager
    [locationManager stopUpdatingLocation];
    // Set Up Map
    double lat = (double)currentLocation.coordinate.latitude;
    double lon = (double)currentLocation.coordinate.longitude;
    CLLocationCoordinate2D dealPos = CLLocationCoordinate2DMake(lat, lon);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(dealPos, 1700, 1700);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    // Reverse Geocoding
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            NSLog(@"%@",[NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                         placemark.subThoroughfare, placemark.thoroughfare,
                         placemark.postalCode, placemark.locality,
                         placemark.administrativeArea,
                         placemark.country]);
            NSString *strCityState = [NSString stringWithFormat:@"%@, %@",placemark.locality,placemark.administrativeArea];
            [[NSUserDefaults standardUserDefaults]setObject:strCityState forKey:kUserDefinedCityState];
            [self updateFeedParameters];
        } else {
            NSLog(@"%@", error.debugDescription);
            [_activityIndicator stopAnimating];
        }
    } ];
}

- (void)addDealsToMap;
{
    // REMOVE PREVIOUS ANNOTATIONS
    NSInteger toRemoveCount = _mapView.annotations.count;
    NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:toRemoveCount];
    for (id annotation in _mapView.annotations)
        if (annotation != _mapView.userLocation)
            [toRemove addObject:annotation];
    [_mapView removeAnnotations:toRemove];
    // NOW ADD
    NSMutableArray *dealAnnotations = [[NSMutableArray alloc]init];
    for (NSDictionary *item in lastQueryArray) {
        NSDictionary * dealItem = [item objectForKey:@"deal"];
        MapPin *tempPin = [[MapPin alloc]init];
        [tempPin setTitle:[dealItem objectForKey:@"short_title"]];
        [tempPin setSubtitle:[[dealItem objectForKey:@"merchant"]objectForKey:@"name"]];
        [tempPin setDealDict:item];
        double lat =[[[dealItem objectForKey:@"merchant"]objectForKey:@"latitude"]floatValue];
        double lon =[[[dealItem objectForKey:@"merchant"]objectForKey:@"longitude"]floatValue];
        [tempPin setCoordinate:CLLocationCoordinate2DMake(lat,lon)];
        [dealAnnotations addObject:tempPin];
    }
    [self.mapView addAnnotations:dealAnnotations];
}
         
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if (annotation == mapView.userLocation) {
        return nil;
    }
    static NSString *viewId = @"MKPinAnnotationView";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView*)
    [self.mapView dequeueReusableAnnotationViewWithIdentifier:viewId];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc]
                                initWithAnnotation:annotation reuseIdentifier:viewId];
    }
    // CustomButton
//    UIImage *image = [UIImage imageNamed:@"btn-chevron-1.png"];
//    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
//    [button setImage:image forState:UIControlStateNormal];
//    annotationView.rightCalloutAccessoryView = button;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.canShowCallout = YES;
    annotationView.image = [UIImage imageNamed:@"nav-map"];
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    [Flurry logEvent:@"Action_ViewDealsDetailFromMap"];
    MapPin *annotation = (MapPin *)view.annotation;
    NSLog(@"MapViewController calloutAccessoryControlTapped [%@]",annotation.dealDict);
    selectedDictionary = [NSMutableDictionary dictionaryWithDictionary:annotation.dealDict];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [self performSegueWithIdentifier:@"DetailView2" sender:self];
}
#pragma mark - Scroll View Delegate Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!flagFeedFetchInProgress) {
        float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (endScrolling >= scrollView.contentSize.height && flagNoMoreDeals ==NO)
        {
            NSLog(@"at bottom should reload");
            pageNumber = pageNumber +1;
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        _labelMenuCategoryList, @"Keyword",
                                        _labelMenuCityStateList, @"Location",
                                        nil];
            [Flurry logEvent:@"More_Deals_Searched" withParameters:dictionary];
            [self fetchDealFeedwithPaging:YES];
        }
    }
}




- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    // Keep track of past scroll position for hide/unhide ui
    lastOffSet = scrollView.contentOffset;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //Hide NavBar if scrolling down. Unhide when scrolling up
    if (scrollView.contentOffset.y > lastOffSet.y && scrollView.contentOffset.y >0) {
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
    } else{
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
    }
    // Fades out top and bottom cells in table view as they leave the screen
    NSArray *visibleCells = [self.tableView visibleCells];
    if (visibleCells != nil  &&  [visibleCells count] != 0) {       // Don't do anything for empty table view
        /* Get top cells */
        UITableViewCell *topCell = [visibleCells objectAtIndex:0];
        for (UITableViewCell *cell in visibleCells) {
            cell.contentView.alpha = 1.0;
        }
        /* Set necessary constants */
        NSInteger cellHeight = topCell.frame.size.height - 1;   // -1 To allow for typical separator line height
        NSInteger tableViewTopPosition = self.tableView.frame.origin.y;
        /* Get content offset to set opacity */
        CGRect topCellPositionInTableView = [self.tableView rectForRowAtIndexPath:[self.tableView indexPathForCell:topCell]];
        CGFloat topCellPosition = [self.tableView convertRect:topCellPositionInTableView toView:[self.tableView superview]].origin.y;
        /* Set opacity based on amount of cell that is outside of view */
        CGFloat modifier = 2.5;     /* Increases the speed of fading (1.0 for fully transparent when the cell is entirely off the screen,
                                     2.0 for fully transparent when the cell is half off the screen, etc) */
        CGFloat topCellOpacity = (1.0f - ((tableViewTopPosition - topCellPosition) / cellHeight) * modifier);
        /* Set cell opacity */
        if (topCell) {
            topCell.contentView.alpha = topCellOpacity;
        }
    }
    if (!hasScrolled) {
        hasScrolled = YES;
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    _labelMenuCategoryList.text, @"Keyword",
                                    _labelMenuCityStateList.text, @"Location",
                                    nil];
        [Flurry logEvent:@"ListViewHasScrolled" withParameters:dictionary];
    }
}
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
}

-(void)setMapToUserDefinedLocation;
{
    if (flagUserLocationNotKnown) {
        return;
    }
    CLLocationCoordinate2D location = _mapView.userLocation.coordinate;
    location.latitude  = [[[NSUserDefaults standardUserDefaults]objectForKey:kUserDefinedLatitude]doubleValue];
    location.longitude = [[[NSUserDefaults standardUserDefaults]objectForKey:kUserDefinedLongitude]doubleValue];
    CLLocationCoordinate2D dealPos = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(dealPos, 1700, 1700);;
    region.center = location;
    [_mapView setRegion:region animated:YES];
    [_mapView regionThatFits:region];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if ([lastQueryArray count]) {
        if ([lastQueryArray count]<100 || flagNoMoreDeals==YES) {
            return [lastQueryArray count];
        } else{
            return [lastQueryArray count] +1;
        }
    } else {
        return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *CellIdentifierPagination = @"CellPagination";
    
    if(indexPath.row <[lastQueryArray count]){
        NSString *cellID = CellIdentifier;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
        NSDictionary *item = [[lastQueryArray objectAtIndex:indexPath.row] objectForKey:@"deal"];
        UILabel *cellTitle = (UILabel *)[cell viewWithTag:100];
        UILabel *cellOwner = (UILabel *)[cell viewWithTag:102];
        UILabel *cellDistance = (UILabel *)[cell viewWithTag:103];
        UIView *cellViewBg = (UIView *)[cell viewWithTag:200];
        cellTitle.text = [item objectForKey:@"short_title"];
        cellOwner.text = [[item objectForKey:@"merchant"]objectForKey:@"name"];
        cellViewBg.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
        cellViewBg.layer.cornerRadius = 10;
        cellViewBg.layer.masksToBounds = YES;
        NSString * strItemLat =[[item objectForKey:@"merchant"]objectForKey:@"latitude"];
        NSString * strItemLon =[[item objectForKey:@"merchant"]objectForKey:@"longitude"];
        NSString * strAddress = @"";
        if ([[item objectForKey:@"merchant"]objectForKey:@"address"] && ![[[item objectForKey:@"merchant"]objectForKey:@"address"] isKindOfClass:[NSNull class]]) {
            strAddress = [[item objectForKey:@"merchant"]objectForKey:@"address"];
        }
        NSString * strDistance = [NSString stringWithFormat:@"%@  (~%.1f MI)",strAddress,[self returnDistanceFromLatitude:strItemLat Longitude:strItemLon]];
        cellDistance.text = strDistance;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        NSString *cellID = CellIdentifierPagination;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
         UIActivityIndicatorView *cellActivity= (UIActivityIndicatorView *)[cell viewWithTag:600];
        [cellActivity startAnimating];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didDeselectRowAtIndexPath = %i",indexPath.row);
    [Flurry logEvent:@"Action_ViewDealsDetailFromList"];
    if (indexPath.row >= [lastQueryArray count]) {
        return;
    }
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    selectedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.row];
    selectedDictionary = [lastQueryArray objectAtIndex:selectedIndexPath.row];
    [self performSegueWithIdentifier:@"DetailView2" sender:self];
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    [_viewTableHeader setFrame:CGRectMake(0, 0, _viewTableHeader.frame.size.width, _viewTableHeader.frame.size.height)];
    return _viewTableHeader;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 54;
}

#pragma mark - UTILITY

-(CGFloat)returnDistanceFromLatitude:(NSString *)lat Longitude:(NSString *)lon;
{
    double latUser = [[[NSUserDefaults standardUserDefaults]objectForKey:kUserDefinedLatitude] doubleValue];
    double lonUser = [[[NSUserDefaults standardUserDefaults]objectForKey:kUserDefinedLongitude] doubleValue];
    CLLocation *locUser = [[CLLocation alloc] initWithLatitude:latUser longitude:lonUser];
    double latItem = [lat doubleValue];
    double lonItem = [lon doubleValue];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:latItem longitude:lonItem];
    CLLocationDistance distance = [locUser distanceFromLocation:locB];
    float distanceInMiles = distance * 0.000621371;
    return distanceInMiles;
}


- (void)setBackgroundImageWithURL:(NSString *)imageURL;
{
    NSLog(@"setBackgroundImageWithURL [%@]",imageURL);
    [_imageTableBackground setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        NSLog(@"setBackgroundImageWithURL GOT IMAGE");
        backgroundView.originalImage = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"ERROR setBackgroundImageWithURL ERROR [%@]",error);
    }];
}

- (void)nudgeScrollViewForEffect;
{
    NSLog(@"nudgeScrollViewForEffect");
    CGPoint currentOffSet = _tableView.contentOffset;
    [self.tableView setContentOffset:CGPointMake(currentOffSet.x, currentOffSet.y-1) animated:YES];
    lastOffSet = _tableView.contentOffset;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue = %@",sender);
    if ([[segue identifier] isEqualToString:@"filterview"])
    {
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
        FilterCategoryViewController *vc = (FilterCategoryViewController *)segue.destinationViewController;
        vc.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"DetailView2"])
    {
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
        DealViewController *vc = (DealViewController *)segue.destinationViewController;
        vc.dealDict = selectedDictionary;

    }
}


@end
