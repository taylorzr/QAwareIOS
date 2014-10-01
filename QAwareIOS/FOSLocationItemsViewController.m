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

@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;

@end

@implementation FOSLocationItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self loadItems];
}

- (void)viewDidAppear:(BOOL)animated {
//    FOSInspectionViewController *web = [self.storyboard instantiateViewControllerWithIdentifier: @"inspection"];
//    [self presentViewController: web animated:YES completion:nil];
//    [self performSegueWithIdentifier:@"inspectionView" sender:self];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLBeaconRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        NSString *beaconID = [beaconRegion.minor stringValue];
        NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:@"employee_id"];
        NSString *message = [NSString stringWithFormat:@"Minor: %@\nEmployee Id: %@", beaconID, userID];
//        UIAlertView *enterAlert = [[UIAlertView alloc] initWithTitle:@"Enter Region" message:message delegate:nil cancelButtonTitle:@"Cool." otherButtonTitles:nil, nil];
//        [enterAlert show];

        NSDictionary *beaconData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    beaconID, @"minor_id",
                                    userID, @"employee_id", nil];

        NSData *beaconJSON = [NSJSONSerialization dataWithJSONObject:beaconData
                                                             options:NSJSONWritingPrettyPrinted
                                                               error:nil];

        NSString *urlString = [NSString stringWithFormat:@"http://qaware.herokuapp.com/api/beacons"];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"PUT"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:beaconJSON];

        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSLog(@"%i", response.statusCode);
        }
    }

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLBeaconRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        NSString *beaconID = [beaconRegion.minor stringValue];
        NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:@"employee_id"];
        NSString *message = [NSString stringWithFormat:@"Minor: %@\nEmployee Id: %@", beaconID, userID];
//        UIAlertView *exitAlert = [[UIAlertView alloc] initWithTitle:@"Exit Region" message:message delegate:nil cancelButtonTitle:@"Cool." otherButtonTitles:nil, nil];
//        [exitAlert show];
        
        NSDictionary *beaconData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    beaconID, @"minor_id",
                                    userID, @"employee_id", nil];
        
        NSData *beaconJSON = [NSJSONSerialization dataWithJSONObject:beaconData
                                                             options:NSJSONWritingPrettyPrinted
                                                               error:nil];
        
        NSString *urlString = [NSString stringWithFormat:@"http://qaware.herokuapp.com/api/beacons"];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"DELETE"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:beaconJSON];
        
        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSLog(@"%i", response.statusCode);
        
        if ([[self.navigationController visibleViewController] isKindOfClass: [FOSInspectionViewController class]])
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}


- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    for (CLBeacon *beacon in beacons) {
        for (FOSLocationItem *item in self.items) {
            if ([item isEqualToCLBeacon: beacon]) {
                item.lastSeenBeacon = beacon;
                if (beacon.proximity == CLProximityImmediate){
                    UIViewController *currentView = [self.navigationController topViewController];
                    if ([currentView isKindOfClass:[self class]])
                    {
                        NSUInteger *row = [self.items indexOfObject:item];
                        NSIndexPath *index = [NSIndexPath indexPathForItem:row inSection:@1];
                        UITableViewCell *cell = [self.itemsTableView cellForRowAtIndexPath:index];
                        [self performSegueWithIdentifier:@"inspectionView" sender:cell];
                    }
                } else if (beacon.proximity == CLProximityFar || beacon.proximity == CLProximityUnknown) {
                    if ([[self.navigationController visibleViewController] isKindOfClass: [FOSInspectionViewController class]])
                    {
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                }
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
    NSURL *url = [NSURL URLWithString:@"http://qaware.herokuapp.com/api/forms"];
    NSData *responseData = [NSData dataWithContentsOfURL:url];
    NSDictionary *serverData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil];
    
    // Set the static data, UUID & major
//    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:serverData[@"uuid"]];
//    unsigned int major = [serverData[@"major"] intValue];
    
    // Loop through the location data
    // Create a FOSLocationItem and add it to the items array
    // Start monitoring the location's region
    for(NSDictionary *location in serverData) {
        NSDictionary *beaconDict = location[@"beacon"];
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:beaconDict[@"uuid"]];
        unsigned int major = [beaconDict[@"major"] intValue];
        unsigned int minor = [beaconDict[@"minor"] intValue];
        NSString *name = beaconDict[@"location"];
        NSString *url = [NSString stringWithFormat:@"forms/%@", beaconDict[@"id"]];
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

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    FOSLocationItem *item = [self.items objectAtIndex: indexPath.row];
//    if (item.lastSeenBeacon != nil && item.lastSeenBeacon.proximity != CLProximityUnknown && item.lastSeenBeacon.proximity != CLProximityFar){
//        return indexPath;
//    } else {
//        UIAlertView *lazyAlert = [[UIAlertView alloc] initWithTitle: @"Out of Range" message: @"You must be near a beacon to perform this inspection." delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil];
//        [lazyAlert show];
//        return nil;
//    }
    return indexPath;
    
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
