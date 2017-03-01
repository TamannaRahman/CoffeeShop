//
//  VenueCell.h
//  CoffeeShop
//
//  Created by CQUGSR on 1/03/2017.
//  Copyright © 2017 Tamanna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VenueCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;

@end
