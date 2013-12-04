//
//  DealViewController.m
//  pinchpenny
//
//  Created by Tackable Inc on 11/12/13.
//  Copyright (c) 2013 tackable. All rights reserved.
//

#import "DealViewController.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import "WebViewController.h"
#import "DealOnMapViewController.h"
#import "Flurry.h"

@interface DealViewController ()
{
    NSString *title;
    NSString *businessName;
    NSString *category;
    NSString *addressLine1;
    NSString *addressLine2City;
    NSString *addressLine2State;
    NSString *addressLine2Zip;
    NSString *dealSource;
    NSString *expireDate;
    NSString *finePrint;
    NSString *description;
    float viewHieght;
    NSDate *dateExpiration;
    BOOL flagDescriptionFullyVisible;
    BOOL hasScrolled;
}
@property (strong, nonatomic) IBOutlet UIView *viewStickyNote;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnGetDeal;
@property (weak, nonatomic) IBOutlet UILabel *labelSource;
@property (weak, nonatomic) IBOutlet UILabel *labelDaysLeft;
@end

@implementation DealViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // SetUp UI and iVars
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _dealDict = [_dealDict objectForKey:@"deal"];
	NSLog(@"%@",_dealDict);
    _btnGetDeal.layer.cornerRadius = 5.0;
    _btnGetDeal.layer.masksToBounds = YES;
    
    // SetUp Custom NavBar Settings
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, [UIFont fontWithName:@"Avenir-Light" size:18.0], UITextAttributeFont,nil];
    UIImage *buttonImage = [UIImage imageNamed:@"btn-back.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 30, 30);
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = customBarItem;
    [self parseDictionaryIntoIVars];
    flagDescriptionFullyVisible = NO;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [Flurry logPageView];
}


- (IBAction)actionShowWebView:(id)sender {
    NSLog(@"actionShowWebView");
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                title, @"Title",
                                businessName, @"Merchant",
                                dealSource, @"Provider_Name",
                                addressLine2City, @"City",
                                addressLine2State, @"State",
                                nil];
    [Flurry logEvent:@"Action_GetDeal" withParameters:dictionary];
    [self performSegueWithIdentifier:@"DealOnWeb" sender:self];
}

-(void)back {
    [Flurry logEvent:@"Action_DealDetailBackButton"];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)parseDictionaryIntoIVars;
{
    // SET UP STRINGS TO SET DYNAMIC HIEGHT
    title =@"";
    businessName=@"";
    category=@"";
    addressLine1=@"";
    addressLine2City=@"";
    addressLine2State=@"";
    addressLine2Zip=@"";
    dealSource=@"";
    expireDate=@"";
    description=@"";
    finePrint = @"";
    // GET VALUES FROM DICTIONARY.  VALIDATE ITEM
    if ([_dealDict objectForKey:@"title"]&& ![[_dealDict objectForKey:@"title"] isKindOfClass:[NSNull class]]) {
        title = [_dealDict objectForKey:@"title"];
    }
    if ([[_dealDict objectForKey:@"merchant"]objectForKey:@"name"]&& ![[[_dealDict objectForKey:@"merchant"]objectForKey:@"name"] isKindOfClass:[NSNull class]]) {
        businessName = [[_dealDict objectForKey:@"merchant"]objectForKey:@"name"];
    }
    if ([_dealDict objectForKey:@"category_name"]&& ![[_dealDict objectForKey:@"category_name"] isKindOfClass:[NSNull class]]) {
        category = [_dealDict objectForKey:@"category_name"];
    }
    if ([[_dealDict objectForKey:@"merchant"]objectForKey:@"address"] && ![[[_dealDict objectForKey:@"merchant"]objectForKey:@"address"] isKindOfClass:[NSNull class]]) {
        addressLine1 = [[_dealDict objectForKey:@"merchant"]objectForKey:@"address"];
    }
    if ([[_dealDict objectForKey:@"merchant"]objectForKey:@"locality"]&& ![[[_dealDict objectForKey:@"merchant"]objectForKey:@"locality"] isKindOfClass:[NSNull class]]) {
        addressLine2City = [[_dealDict objectForKey:@"merchant"]objectForKey:@"locality"];
    }
    if ([[_dealDict objectForKey:@"merchant"]objectForKey:@"region"]&& ![[[_dealDict objectForKey:@"merchant"]objectForKey:@"region"] isKindOfClass:[NSNull class]]) {
        addressLine2State = [[_dealDict objectForKey:@"merchant"]objectForKey:@"region"];
    }
    if ([[_dealDict objectForKey:@"merchant"]objectForKey:@"postal_code"]&& ![[[_dealDict objectForKey:@"merchant"]objectForKey:@"postal_code"] isKindOfClass:[NSNull class]]) {
        addressLine2Zip = [[_dealDict objectForKey:@"merchant"]objectForKey:@"postal_code"];
    }
    if ([_dealDict objectForKey:@"provider_name"]&& ![[_dealDict objectForKey:@"provider_name"] isKindOfClass:[NSNull class]]) {
        dealSource = [_dealDict objectForKey:@"provider_name"];
    }
    if ([_dealDict objectForKey:@"expires_at"]&& ![[_dealDict objectForKey:@"expires_at"] isKindOfClass:[NSNull class]]) {
        expireDate = [self createReadableExpirationDate:[_dealDict objectForKey:@"expires_at"]];
    }
    if ([_dealDict objectForKey:@"description"]&& ![[_dealDict objectForKey:@"description"] isKindOfClass:[NSNull class]]) {
        description = [_dealDict objectForKey:@"description"];
    }
    if ([_dealDict objectForKey:@"fine_print"]&& ![[_dealDict objectForKey:@"fine_print"] isKindOfClass:[NSNull class]]) {
        finePrint = [_dealDict objectForKey:@"fine_print"];
    }
    self.navigationItem.title = businessName;
    _labelSource.text = [NSString stringWithFormat:@"%@",dealSource];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                title, @"Title",
                                businessName, @"Merchant",
                                dealSource, @"Provider_Name",
                                addressLine2City, @"City",
                                addressLine2State, @"State",
                                nil];
    [Flurry logEvent:@"Detail_Viewed" withParameters:dictionary];
}

-(NSString *)createReadableExpirationDate:(NSString *)dateString;
{
    // Sqoots date format
    //2013-11-16T07:59:59Z
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSDate *dateExpires = [dateFormatter dateFromString:dateString];
    [dateFormatter setDateFormat:@"MMM d, YYYY"];
    int seconds = (int)[dateExpires timeIntervalSinceNow];
    NSLog(@"seconds = [%i]",seconds);
    int days = seconds/(60*60*24);
    int hours = seconds/(60*60);
    NSLog(@"days = [%i]",days);
    if (days==1) {
        _labelDaysLeft.text = [NSString stringWithFormat:@"%i Day Left",days];
    } else if (days>1) {
        _labelDaysLeft.text = [NSString stringWithFormat:@"%i Days Left",days];
    } else if (hours>0) {
        _labelDaysLeft.text = [NSString stringWithFormat:@"%i Hours Left",hours];
    } else {
        _labelDaysLeft.text = @"";
    }
    return [NSString stringWithFormat:@"Expires %@",[dateFormatter stringFromDate:dateExpires]];
}


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

// Ensures Navigation Bar is visible.  In some cases may disappear if not visible in parent view controller
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y <= 0) {
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
    }
    if (!hasScrolled) {
        hasScrolled = YES;
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    title, @"Title",
                                    businessName, @"Merchant",
                                    dealSource, @"Provider_Name",
                                    addressLine2City, @"City",
                                    addressLine2State, @"State",
                                    nil];
        [Flurry logEvent:@"DealDetailViewHasScrolled" withParameters:dictionary];
    }
}

#pragma mark - TABLE VIEW DELEGATE STUBS

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *CellImageIdentifier = @"CellImage";
    static NSString *CellTitleIdentifier = @"CellTitle";
    static NSString *CellLocationIdentifier = @"CellLocation";
    static NSString *CellDescriptionIdentifier = @"CellDescription";
    static NSString *CellMapIdentifier = @"CellMap";
    static NSString *CellFinePrintIdentifier = @"CellFinePrint";
    static NSString *CellFooterIdentifier = @"CellFooter";
    NSString *cellID;
    switch (indexPath.row) {
        case 0:
            cellID = CellImageIdentifier;
            break;
        case 1:
            cellID = CellTitleIdentifier;
            break;
        case 2:
            cellID = CellLocationIdentifier;
            break;
        case 3:
            cellID = CellDescriptionIdentifier;
            break;
        case 4:
            cellID = CellMapIdentifier;
            //300
            break;
        case 5:
            cellID = CellFinePrintIdentifier;
            break;
        case 6:
            cellID = CellFooterIdentifier;
            break;
        default:
            cellID = CellIdentifier;
            break;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
        {
            UIImageView *cellImage = (UIImageView *)[cell viewWithTag:200];
            if ([_dealDict objectForKey:@"image_url"] &&![[_dealDict objectForKey:@"image_url"] isKindOfClass:[NSNull class]]) {
                NSLog(@"image_url = [%@]",[_dealDict objectForKey:@"image_url"]);
                NSURL *imageURL = [NSURL URLWithString:[_dealDict objectForKey:@"image_url"]];
                [cellImage setImageWithURL:imageURL];
            }
            cellImage.contentMode = UIViewContentModeScaleAspectFill;
        }
            break;
        case 1:
        {
            
            UILabel *cellTitle = (UILabel *)[cell viewWithTag:100];
            cellTitle.text = title;
        }
            break;
        case 2:
        {
            UILabel *cellCityState = (UILabel *)[cell viewWithTag:100];
            UILabel *cellDistance = (UILabel *)[cell viewWithTag:101];
            NSString *strCity = addressLine2City;
            NSString *strState = addressLine2State;
            cellCityState.text = [NSString stringWithFormat:@"%@, %@",strCity,strState];
            NSString * strItemLat =[[_dealDict objectForKey:@"merchant"]objectForKey:@"latitude"];
            NSString * strItemLon =[[_dealDict objectForKey:@"merchant"]objectForKey:@"longitude"];
            NSString * strDistance = [NSString stringWithFormat:@"%.1f mi",[self returnDistanceFromLatitude:strItemLat Longitude:strItemLon]];
            cellDistance.text = strDistance;
        }
            break;
        case 3:
        {
            UILabel *cellDescription = (UILabel *)[cell viewWithTag:100];
            UIView *cellViewMaskMore = (UIView *)[cell viewWithTag:200];
            if ([_dealDict objectForKey:@"description"]&& ![[_dealDict objectForKey:@"description"] isKindOfClass:[NSNull class]]) {
                cellDescription.text = [_dealDict objectForKey:@"description"];
            }
            if (flagDescriptionFullyVisible || SYSTEM_VERSION_LESS_THAN(@"7.0")) {
                cellViewMaskMore.hidden = YES;
            }
        }
            break;
        case 4:
        {
            MKMapView *cellMap = (MKMapView *)[cell viewWithTag:300];
            UILabel *cellAddress1 = (UILabel *)[cell viewWithTag:100];
            UILabel *cellAddress2 = (UILabel *)[cell viewWithTag:101];
            UIView *cellViewBase = (UIView *)[cell viewWithTag:400];
            double lat = [[[_dealDict objectForKey:@"merchant"]objectForKey:@"latitude"]doubleValue];
            double lon = [[[_dealDict objectForKey:@"merchant"]objectForKey:@"longitude"]doubleValue];
            CLLocationCoordinate2D dealPos = CLLocationCoordinate2DMake(lat, lon);
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(dealPos, 500, 500);
            [cellMap setRegion:[cellMap regionThatFits:region] animated:YES];
            // Add an annotation
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            point.coordinate = dealPos;
            [cellMap addAnnotation:point];
            cellAddress1.text = [NSString stringWithFormat:@"%@",addressLine1];
            cellAddress2.text = [NSString stringWithFormat:@"%@ %@ %@",addressLine2City, addressLine2State, addressLine2Zip];
            cellViewBase.layer.shadowColor = [UIColor blackColor].CGColor;
            cellViewBase.layer.shadowOpacity = 0.3;
            cellViewBase.layer.shadowOffset = CGSizeMake(0, 1);
            cellViewBase.layer.shadowRadius = 2;
            
        }
            break;
        case 5:
        {
            UILabel *cellExpiration = (UILabel *)[cell viewWithTag:100];
            UILabel *cellFinePrint = (UILabel *)[cell viewWithTag:101];
            cellExpiration.text = expireDate;
            cellFinePrint.text = finePrint;
        }
            break;
        case 6:
        {
            // Footer
        }
            break;
        default:
            cellID = CellIdentifier;
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    switch (indexPath.row) {
        case 0: // Image
            return 175;
            break;
        case 1: // Title
        {
            CGSize boundingSize = CGSizeMake(280, 600);
            CGSize requiredSize = [title sizeWithFont:[UIFont fontWithName:@"Avenir-Medium" size:18]
                                        constrainedToSize:boundingSize
                                            lineBreakMode:NSLineBreakByWordWrapping];
            return requiredSize.height+5;
        }
            break;
        case 2: // Location
            return 32;
            break;
        case 3: // Description
            if ([description length]==0) {
                return 0;
            } else {
                CGSize boundingSize = CGSizeMake(280, 900);
                CGSize requiredSize = [description sizeWithFont:[UIFont fontWithName:@"Avenir-Roman" size:15]
                                            constrainedToSize:boundingSize
                                                lineBreakMode:NSLineBreakByWordWrapping];
                if (requiredSize.height <= 160 || flagDescriptionFullyVisible == YES) {
                    return requiredSize.height + 25;
                } else {
                    return 160;
                }
            }
            break;
        case 4: // Map
            return 240;
            break;
        case 5: // Fine Print
        {
            if ([finePrint length]==0) {
                return 0;
            } else {
                NSLog(@"fineprint [%@]",finePrint);
                CGSize boundingSize = CGSizeMake(280, 600);
                CGSize requiredSize = [finePrint sizeWithFont:[UIFont systemFontOfSize:12]
                                            constrainedToSize:boundingSize
                                                lineBreakMode:NSLineBreakByWordWrapping];
                return requiredSize.height + 40;
            }
        }
            
            break;
        case 6:
            return 0;
            break;
        default:
            return 44;
            break;
    }
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@",indexPath);
    switch (indexPath.row) {
        case 3:
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIView *cellViewMaskMore = (UIView *)[cell viewWithTag:200];
            cellViewMaskMore.hidden = YES;
            flagDescriptionFullyVisible = YES;
            NSMutableArray *array = [NSMutableArray array];
            [array addObject:indexPath];
            [tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
        case 4:
        {
            [self performSegueWithIdentifier:@"MapView" sender:self];
        }
            break;
        case 5:
        {
            [self performSegueWithIdentifier:@"DealOnWeb" sender:self];
        }
            break;
        default:
            break;
    }
}


 #pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     NSLog(@"prepareForSegue = %@",sender);
     if ([[segue identifier] isEqualToString:@"DealOnWeb"])
     {
         WebViewController *vc = (WebViewController *)segue.destinationViewController;
         vc.strURL = [_dealDict objectForKey:@"url"];
         vc.strSourceName = businessName;
     } else if ([[segue identifier] isEqualToString:@"MapView"])
     {
         DealOnMapViewController *vc = (DealOnMapViewController *)segue.destinationViewController;
         vc.strLat = [[_dealDict objectForKey:@"merchant"]objectForKey:@"latitude"];
         vc.strLon = [[_dealDict objectForKey:@"merchant"]objectForKey:@"longitude"];
         vc.strBusinessName = businessName;
         vc.strAddress = [NSString stringWithFormat:@"%@ %@ %@", addressLine1, addressLine2City, addressLine2State];
     }
 }
 



@end
