//
//  FOSLocationItemsViewController.h
//  QAwareIOS
//
//  Created by Zach Taylor & Brandon Manson on 9/28/14.
//  Copyright (c) 2014 Flock of Squirrels Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

@interface FOSLocationItemsViewController : UIViewController


@property (strong, nonatomic) NSMutableArray *items;
@property (nonatomic) BOOL *allowsSelection;
@property (strong, nonatomic) CLLocationManager *locationManager;


@end
