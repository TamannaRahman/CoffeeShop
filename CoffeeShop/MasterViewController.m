//
//  MasterViewController.m
//  CoffeeShop
//
//  Created by CQUGSR on 28/02/2017.
//  Copyright © 2017 Tamanna. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Venue.h"
#import "Location.h"
#import "VenueCell.h"
#import "Menu.h"

#define kCLIENTID @"YTI0POTACEAK0OOVGSPM4N4BRVHWZ2E1XOC4G3XTTHVSY31S"
#define kCLIENTSECRET @"LJYH4SWC15EX22G055VXXNRIYQ5OOYQU3FA0ZVY1OHHIDY0T"


@interface MasterViewController ()


@end

@implementation MasterViewController{
    
    CLLocationManager *locationManager;
    NSMutableArray *distanceArray;
    NSMutableArray *sortedArray;
    NSMutableArray *sortedVenues;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    sortedVenues = [[NSMutableArray alloc] init];
    distanceArray = [[NSMutableArray alloc] init];
    sortedArray = [[NSMutableArray alloc] init];
    _urlArray = [[NSMutableArray alloc] init];
    
    [self createActivityIndicator];
    [self.activityIndicator startAnimating];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [locationManager requestAlwaysAuthorization];
    
    [locationManager startUpdatingLocation];

}

-(void)createActivityIndicator{
    
    UIActivityIndicatorView *actInd=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    actInd.color=[UIColor whiteColor];
    
    [actInd setCenter:self.view.center];
    
    self.activityIndicator=actInd;
    [self.view addSubview:self.activityIndicator];
}

- (void)configureRestKit
{

    // initialize AFNetworking HTTPClient
    NSURL *baseURL = [NSURL URLWithString:@"https://api.foursquare.com"];
    AFRKHTTPClient *client = [[AFRKHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // setup object mappings
    RKObjectMapping *venueMapping = [RKObjectMapping mappingForClass:[Venue class]];
    [venueMapping addAttributeMappingsFromArray:@[@"name"]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:venueMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/v2/venues/search"
                                                keyPath:@"response.venues"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
    // define location object mapping
    RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:[Location class]];
    [locationMapping addAttributeMappingsFromArray:@[@"address", @"city", @"country", @"postalCode", @"state", @"distance", @"lat", @"lng"]];
    
    // define relationship mapping
    [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location" toKeyPath:@"location" withMapping:locationMapping]];
    
    
    RKObjectMapping *menuMapping = [RKObjectMapping mappingForClass:[Menu class]];
    [menuMapping addAttributeMappingsFromArray:@[@"url", @"mobileUrl"]];
    
    [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"menu" toKeyPath:@"menu" withMapping:menuMapping]];
}

- (void)loadVenues:(NSString *)currentLocation
{
    NSString *clientID = kCLIENTID;
    NSString *clientSecret = kCLIENTSECRET;
    
    NSString *location;
  /*  if (currentLocation) {
        location = currentLocation;
    }
    else{
        // For simulator, dummy location
        location = @"-33.97,151.11";
    }
    
    NSLog(@"location %@", location);
    */
#if TARGET_IPHONE_SIMULATOR
    
    NSLog(@"Running in Simulator - no app store or giro");
    location = @"-33.97,151.11";
    
#else
    
    NSLog(@"Running on the Device");
    location = currentLocation;
    
#endif
    
    NSDictionary *queryParams = @{@"ll" : location,
                                  @"client_id" : clientID,
                                  @"client_secret" : clientSecret,
                                  @"categoryId" : @"4bf58dd8d48988d1e0931735",
                                  @"v" : @"20140118"};
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/v2/venues/search"
        parameters:queryParams
            success:^(RKObjectRequestOperation *operation,
            RKMappingResult *mappingResult) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (_venues){
                        
                        [self.venues removeAllObjects ];
                    }
                    else{
                        self.venues = [NSMutableArray arrayWithArray:mappingResult.array];
                    }
                    [self sortVenues];
                    [self getWebUrl];
                });
                

                }
                       failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"What do you mean by 'there is no coffee?': %@", error);
                                              }];
}
- (void)getWebUrl{
    
    for (Venue *venue in _venues) {
        
        NSString *url = [NSString stringWithFormat:@"%@", venue.menu.mobileUrl];
        
        if ([url  isEqual: @"(null)"]) {
            [_urlArray addObject:@"https://foursquare.com/v"];

        }
        else
        [_urlArray addObject:url];

    }
}

- (void)sortVenues{
    
       for (Venue *venue in _venues) {
        
        [distanceArray addObject:venue.location.distance];
    }

    //avoid duplication
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:distanceArray];
    
    if (distanceArray.count > 0 ) {
        [distanceArray removeAllObjects];
        [distanceArray addObjectsFromArray:[orderedSet array]];
    }
    
    if (sortedArray.count){
    
        [sortedArray removeAllObjects];
    }

    //ascending order sorting
    [sortedArray addObjectsFromArray: [distanceArray  sortedArrayUsingComparator:
                            ^NSComparisonResult(id obj1, id obj2){
                                return [obj1 compare:obj2];
                            }]];
    
    for (int i=0; i<sortedArray.count ; i++) {
        
        for (Venue *venue in _venues) {
        
            if ([[sortedArray objectAtIndex:i] isEqualToNumber:venue.location.distance]) {
                
                [sortedVenues insertObject:venue atIndex:i];
            }
        }
    }
    
    [self.activityIndicator stopAnimating];

    [self.tableView reloadData];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
    UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:@"Error"  message:@"Failed to Get Your Location"  preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    CLLocation *currentLocation = [locations lastObject];
    
    [self configureRestKit];

    [self loadVenues:[NSString stringWithFormat:@"%.2f,%.2f",currentLocation.coordinate.latitude, currentLocation.coordinate.longitude]];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
       
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
       controller.urlString = [NSString stringWithFormat:@"%@",[_urlArray objectAtIndex:indexPath.row]];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return sortedVenues.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VenueCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VenueCell" forIndexPath:indexPath];
    
    
        Venue *sortedVenue = sortedVenues[indexPath.row];
        cell.nameLabel.text = sortedVenue.name;
        cell.addressLabel.text = [NSString stringWithFormat:@"%@, %@, %@-%@", sortedVenue.location.address, sortedVenue.location.city,sortedVenue.location.state,sortedVenue.location.postalCode];
        cell.distanceLabel.text = [NSString stringWithFormat:@"%.0fm", sortedVenue.location.distance.floatValue];
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



@end
