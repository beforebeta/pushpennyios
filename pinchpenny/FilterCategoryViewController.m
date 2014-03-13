//
//  FilterCategoryViewController.m
//  pinchpenny
//
//  Created by Tackable Inc on 11/4/13.
//  Copyright (c) 2013 tackable. All rights reserved.
//

#import "FilterCategoryViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import "Flurry.h"
#import "GAITrackedViewController.h"

#define TEXTFIELD_KEYWORD 1
#define TEXTFIELD_LOCATION 2

@interface FilterCategoryViewController ()
{
    NSMutableArray *filterArray;
    NSMutableArray *filterCategoryArray;
    NSMutableArray *filterKeywordsArray;
    NSString *defaultBackgroundURL;
    BOOL hasCategoryImage;
    
    // Location
    CLLocationManager *locationManagerUser;
    CLGeocoder *geocoderUser;
    CLPlacemark *placemarkUser;
    
    NSString *strUUID;
}
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (weak, nonatomic) IBOutlet UIView *viewMenuContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textFieldLocation;
@property (weak, nonatomic) IBOutlet UITextField *textFieldKeyword;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@end

@implementation FilterCategoryViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![[NSUserDefaults standardUserDefaults]objectForKey:kUUID]) {
        strUUID = [[NSUUID UUID] UUIDString];
    } else {
        strUUID =[[NSUserDefaults standardUserDefaults]objectForKey:kUUID];
    }
    [self fetchCategoryKeywordFeed];
    
	_viewMenuContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    _viewMenuContainer.layer.shadowOpacity = 0.3;
    _viewMenuContainer.layer.shadowOffset = CGSizeMake(1, 1);
    _viewMenuContainer.layer.shadowRadius = 4;
    
    _btnCancel.layer.cornerRadius = 5;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _textFieldLocation.delegate = self;
    _textFieldKeyword.delegate = self;
    if (!self.geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [self highlightCategoryRow];
    [Flurry logPageView];
    _textFieldKeyword.text = [[NSUserDefaults standardUserDefaults]objectForKey:kUserDefinedCategory];
    _textFieldLocation.text = [[NSUserDefaults standardUserDefaults]objectForKey:kUserDefinedCityState];
    self.screenName = @"Search";
    [super viewDidAppear:animated];
}

#pragma mark - action
- (IBAction)actionDismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

-(void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionSearch:(id)sender {
    [_textFieldKeyword becomeFirstResponder];
}
- (IBAction)actionLocation:(id)sender {
    [_textFieldLocation becomeFirstResponder];
}
#pragma mark - utility

- (void)fetchCategoryKeywordFeed;
{
    NSString *strLat = [[NSUserDefaults standardUserDefaults]objectForKey:kUserDefinedLatitude];
    NSString *strLon = [[NSUserDefaults standardUserDefaults]objectForKey:kUserDefinedLongitude];
    NSString *feedURL = [NSString stringWithFormat:@"http://api.pushpenny.com/v2/localinfo?api_key=h7n8we&location=%@,%@&id=%@",strLat,strLon,strUUID];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:feedURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"fetchCategoryKeywordFeed [%@]", responseObject);
        defaultBackgroundURL = [responseObject objectForKey:@"default_image"];
        filterCategoryArray = [NSMutableArray arrayWithArray:[responseObject objectForKey:@"search_categories"]];
        filterKeywordsArray =[NSMutableArray arrayWithArray:[responseObject objectForKey:@"popular_nearby"]];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


-(void)highlightCategoryRow;
{
    NSString *strCategory = [[NSUserDefaults standardUserDefaults]objectForKey:kUserDefinedCategorySlug];
    int count = 0;
    for (NSDictionary *item in filterCategoryArray) {
        if ([[item objectForKey:@"slug"] isEqualToString:strCategory]) {
            NSIndexPath *indexMatch = [NSIndexPath indexPathForRow:count inSection:0];
            UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexMatch];
            [cell setSelected:YES];
            break;
        }
        count ++;
        
    }
}

#pragma mark - textfield


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    switch (textField.tag) {
        case TEXTFIELD_KEYWORD:
        {
            if ([textField.text  length] != 0) {
                [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:kUserDefinedCategory];
                [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:kUserDefinedCategorySlug];
                
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"All Deals" forKey:kUserDefinedCategory];
                [[NSUserDefaults standardUserDefaults] setObject:@"all" forKey:kUserDefinedCategorySlug];
                
            }
            if ([_textFieldLocation.text  length] != 0) {
                NSString *strLocationForFlurry = [NSString stringWithFormat:@"%@",_textFieldLocation.text];
                NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                            _textFieldKeyword.text, @"Keyword",
                                            strLocationForFlurry, @"Location",
                                            nil];
                [Flurry logEvent:@"Search" withParameters:dictionary];
                if (hasCategoryImage) {
                    [_delegate setBackgroundImageWithURL:defaultBackgroundURL];
                } else {
                    [_delegate fetchCategoryKeywordFeed];
                }
                [_delegate fetchDealFeedwithPaging:NO];
                [self actionDismissView:Nil];
            } else {
                [self getUserLocation];
            }
            
        }
            break;
        case TEXTFIELD_LOCATION:
        {
            if ([textField.text  length] != 0) {
                [self getCoordinateFromString:textField.text andFetch:YES];
            } else {
                [self getUserLocation];
            }
        }
            break;
        default:
            break;
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case TEXTFIELD_KEYWORD:
        {
            if ([textField.text  length] != 0) {
                [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:kUserDefinedCategory];
                [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:kUserDefinedCategorySlug];
            }
        }
            break;
        case TEXTFIELD_LOCATION:
        {
            if ([textField.text  length] != 0) {
                [Flurry logEvent:@"SpecificLocationSearchValueChanged"];
                [self getCoordinateFromString:textField.text andFetch:NO];
            }
        }
            break;
        default:
            break;
    }

}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    NSLog(@"textFieldShouldClear");
    _textFieldKeyword.placeholder = @"All Deals";
    return YES;
}

#pragma mark - geo

-(void)getCoordinateFromString:(NSString *)strAddress andFetch:(BOOL)fetchFeed;
{
    [self.geocoder geocodeAddressString:strAddress completionHandler:^(NSArray *placemarks, NSError *error) {
         NSLog(@"placemarks = [%@]",placemarks);
         NSLog(@"error =[%@]",error);
        if ([placemarks count] > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            CLLocation *location = placemark.location;
            CLLocationCoordinate2D coordinate = location.coordinate;
            if (placemark.locality && placemark.administrativeArea) {
                NSString *strCityState = [NSString stringWithFormat:@"%@, %@",placemark.locality,placemark.administrativeArea];
                _textFieldLocation.text = strCityState;
                [[NSUserDefaults standardUserDefaults]setObject:strCityState forKey:kUserDefinedCityState];
            }
            NSString *strLon = [NSString stringWithFormat:@"%.8f", coordinate.longitude];
            NSString *strLat = [NSString stringWithFormat:@"%.8f", coordinate.latitude];
            [[NSUserDefaults standardUserDefaults]setObject:strLon forKey:kUserDefinedLongitude];
            [[NSUserDefaults standardUserDefaults]setObject:strLat forKey:kUserDefinedLatitude];
            if (fetchFeed) {
                NSString *strLocationForFlurry = [NSString stringWithFormat:@"%@",_textFieldLocation.text];
                NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                            _textFieldKeyword.text, @"Keyword",
                                            strLocationForFlurry, @"Location",
                                            nil];
                [Flurry logEvent:@"Search" withParameters:dictionary];
                if (hasCategoryImage) {
                    [_delegate setBackgroundImageWithURL:defaultBackgroundURL];
                } else {
                    [_delegate fetchCategoryKeywordFeed];
                }
                
                [_delegate fetchDealFeedwithPaging:NO];
                [self actionDismissView:Nil];
            } else {
                [self fetchCategoryKeywordFeed];
            }
        } else {
            _textFieldLocation.text = @"";
            UIAlertView *errorAlert = [[UIAlertView alloc]
                                       initWithTitle:@"Location Not Found" message:@"Please check your spelling.  You can enter city and state or zipcode." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorAlert show];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [filterCategoryArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[filterCategoryArray objectAtIndex:section]objectForKey:@"list"] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UILabel *cellTitle = (UILabel *)[cell viewWithTag:100];
    NSLog(@"filterCategoryArray section [%@]",[filterCategoryArray objectAtIndex:indexPath.section]);
    NSLog(@"filterCategoryArray section list [%@]",[[filterCategoryArray objectAtIndex:indexPath.section]objectForKey:@"list"]);
    cellTitle.text = [[[[filterCategoryArray objectAtIndex:indexPath.section]objectForKey:@"list"]objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didDeselectRowAtIndexPath = %i",indexPath.row);
    NSString *strSearchKeyword =[[[[filterCategoryArray objectAtIndex:indexPath.section]objectForKey:@"list"]objectAtIndex:indexPath.row] objectForKey:@"name"];
    NSString *strImageURL =[[[[filterCategoryArray objectAtIndex:indexPath.section]objectForKey:@"list"]objectAtIndex:indexPath.row] objectForKey:@"image"];
    if ([strImageURL isKindOfClass:[NSNull class]]) {
        strImageURL = defaultBackgroundURL;
    } else {
        defaultBackgroundURL = strImageURL;
        hasCategoryImage = YES;
    }
    NSLog(@"strImageURL = [%@]",strImageURL);
    [[NSUserDefaults standardUserDefaults] setObject:strSearchKeyword forKey:kUserDefinedCategory];
    [[NSUserDefaults standardUserDefaults] setObject:strSearchKeyword forKey:kUserDefinedCategorySlug];
    [[NSUserDefaults standardUserDefaults] setObject:strImageURL forKey:kUserDefinedCategoryImage];
    if (hasCategoryImage) {
        [_delegate setBackgroundImageWithURL:defaultBackgroundURL];
    } else {
        [_delegate fetchCategoryKeywordFeed];
    };
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                strSearchKeyword, @"Keyword",
                                _textFieldLocation, @"Location",
                                nil];
    [Flurry logEvent:@"Search" withParameters:dictionary];
    [_delegate fetchDealFeedwithPaging:NO];
    [self actionDismissView:Nil];
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *CellIdentifier = @"CellHeader";
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (headerView == nil){
        [NSException raise:@"headerView == nil.." format:@"No cells with matching CellIdentifier loaded from your storyboard"];
    }
    UILabel *labelTitle = (UILabel *)[headerView viewWithTag:150];
    labelTitle.text = [[filterCategoryArray objectAtIndex:section]objectForKey:@"name"];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 34.0;
}


#pragma mark - CLLocationManagerDelegate

- (void)getUserLocation;
{
    [Flurry logEvent:@"SpecificLocationSearchUserLocation"];
    locationManagerUser = [[CLLocationManager alloc] init];
    geocoderUser = [[CLGeocoder alloc] init];
    locationManagerUser.delegate = self;
    locationManagerUser.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManagerUser startUpdatingLocation];
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
    }
    // Stop Location Manager
    [locationManagerUser stopUpdatingLocation];
    // Reverse Geocoding
    NSLog(@"Resolving the Address");
    [geocoderUser reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemarkUser = [placemarks lastObject];
            NSLog(@"%@",[NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                         placemarkUser.subThoroughfare, placemarkUser.thoroughfare,
                         placemarkUser.postalCode, placemarkUser.locality,
                         placemarkUser.administrativeArea,
                         placemarkUser.country]);
            NSString *strCityState = [NSString stringWithFormat:@"%@, %@",placemarkUser.locality,placemarkUser.administrativeArea];
            [[NSUserDefaults standardUserDefaults]setObject:strCityState forKey:kUserDefinedCityState];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        _textFieldKeyword.text, @"Keyword",
                                        strCityState, @"Location",
                                        nil];
            [Flurry logEvent:@"Search" withParameters:dictionary];
            if (hasCategoryImage) {
                [_delegate setBackgroundImageWithURL:defaultBackgroundURL];
            } else {
                [_delegate fetchCategoryKeywordFeed];
            }
            [_delegate fetchDealFeedwithPaging:NO];
            [self actionDismissView:Nil];
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
}


@end
