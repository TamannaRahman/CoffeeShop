//
//  Venue.h
//  CoffeeShop
//
//  Created by CQUGSR on 28/02/2017.
//  Copyright © 2017 Tamanna. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Location;
@class Menu;

@interface Venue : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) Location *location;
@property (nonatomic, strong) Menu *menu;

@end
