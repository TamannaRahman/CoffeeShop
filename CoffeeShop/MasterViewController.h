//
//  MasterViewController.h
//  CoffeeShop
//
//  Created by CQUGSR on 28/02/2017.
//  Copyright © 2017 Tamanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController<CLLocationManagerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (nonatomic, strong) NSMutableArray *venues;
@property (nonatomic, strong) NSMutableArray *urlArray;

@end

