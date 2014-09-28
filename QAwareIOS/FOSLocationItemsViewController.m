//
//  FOSLocationItemsViewController.m
//  QAwareIOS
//
//  Created by Zach Taylor & Brandon Manson on 9/28/14.
//  Copyright (c) 2014 Flock of Squirrels Studios. All rights reserved.
//

#import "FOSLocationItemsViewController.h"
#import "FOSLocationItem.h"
#import "FOSLocationItemCell.h"
#import "FOSInspectionViewController.h"

@import CoreLocation;

@interface FOSLocationItemsViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;

@end

@implementation FOSLocationItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self loadItems];
}


- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    for (CLBeacon *beacon in beacons) {
        for (FOSLocationItem *item in self.items) {
            if ([item isEqualToCLBeacon: beacon]) {
                item.lastSeenBeacon = beacon;
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"Failed monitoring region: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager failed: %@", error);
}

- (CLBeaconRegion *)beaconRegionWithItem:(FOSLocationItem *)item
{
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc]
                                     initWithProximityUUID: item.uuid
                                     major: item.majorValue
                                     minor: item.minorValue
                                     identifier: item.name
                                    ];
    return beaconRegion;
}

- (void)startMonitoringItem:(FOSLocationItem *)item
{
    CLBeaconRegion *beaconRegion = [self beaconRegionWithItem: item];
    [self.locationManager startMonitoringForRegion: beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:beaconRegion];
}

- (void)stopMonitoringItem:(FOSLocationItem *)item
{
    CLBeaconRegion *beaconRegion = [self beaconRegionWithItem: item];
    [self.locationManager stopMonitoringForRegion: beaconRegion];
    [self.locationManager stopRangingBeaconsInRegion: beaconRegion];
}

- (void)loadItems {
    self.items = [NSMutableArray array];
    
    // Make URL request and parse json response
    NSURL *url = [NSURL URLWithString:@"http://qaware.herokuapp.com/api"];
    NSData *responseData = [NSData dataWithContentsOfURL:url];
    NSDictionary *serverData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil];
    
    // Set the static data, UUID & major
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:serverData[@"uuid"]];
    unsigned int major = [serverData[@"major"] intValue];
    
    // Loop through the location data
    // Create a FOSLocationItem and add it to the items array
    // Start monitoring the location's region
    NSDictionary *locations = serverData[@"locations"];
    for(NSDictionary *location in locations) {
        unsigned int minor = [location[@"minor"] intValue];
        NSString *name = location[@"name"];
        NSString *url = location[@"url"];
        FOSLocationItem *item = [[FOSLocationItem alloc]initWithName: name
                                                uuid: uuid
                                                 url: url
                                               major: major
                                               minor: minor];
        [self.items addObject: item];
        [self startMonitoringItem: item];
    }
}


#pragma mark - UITableViewDataSource 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FOSLocationItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Item" forIndexPath:indexPath];
    FOSLocationItem *item = self.items[indexPath.row];
    cell.item = item;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    FOSLocationItem *item = [self.items objectAtIndex:indexPath.row];
//
//    NSString *detailMessage = [NSString stringWithFormat:@"UUID: %@\nMajor: %d\nMinor: %d\nUrl: %@", item.uuid.UUIDString, item.majorValue, item.minorValue, item.url];
//    UIAlertView *detailAlert = [[UIAlertView alloc] initWithTitle:@"Details" message:detailMessage delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
//    [detailAlert show];
//    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"inspectionView"]) {
        NSIndexPath *indexPath = [self.itemsTableView indexPathForSelectedRow];
        FOSLocationItem *locationItem = [self.items objectAtIndex:indexPath.row];
        FOSInspectionViewController *controller = (UIWebView *)segue.destinationViewController;
        controller.query = locationItem.url;
    }
}
    
@end
