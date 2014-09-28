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

@import CoreLocation;

static NSString * const kRWTStoredItemsKey = @"storedItems";

@interface FOSLocationItemsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) CLLocationManager *locationManager;

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

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"Add"]) {
//        UINavigationController *navController = segue.destinationViewController;
//        RWTAddItemViewController *addItemViewController = (RWTAddItemViewController *)navController.topViewController;
//        [addItemViewController setItemAddedCompletion:^(RWTItem *newItem) {
//            [self.items addObject:newItem];
//            [self.itemsTableView beginUpdates];
//            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.items.count-1 inSection:0];
//            [self.itemsTableView insertRowsAtIndexPaths:@[newIndexPath]
//                                       withRowAnimation:UITableViewRowAnimationAutomatic];
//            [self.itemsTableView endUpdates];
//            [self startMonitoringItem: newItem];
//            [self persistItems];
//        }];
//    }
//}

- (void)loadItems {
//    NSArray *storedItems = [[NSUserDefaults standardUserDefaults] arrayForKey:kRWTStoredItemsKey];
//    self.items = [NSMutableArray array];
//    
//    if (storedItems) {
//        for (NSData *itemData in storedItems) {
//            RWTItem *item = [NSKeyedUnarchiver unarchiveObjectWithData:itemData];
//            [self.items addObject:item];
//            [self startMonitoringItem: item];
//        }
//    }
    self.items = [NSMutableArray array];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"FFC26D16-3710-4922-80CB-7E53E92443E4"];
    unsigned int major = 1;
    
    NSDictionary *locations = @{@"Kegerator": @2, @"Bathroom": @4, @"Kitchen": @3 };
    for(id name in locations) {
        unsigned int minor = [locations[name] intValue];
        FOSLocationItem *item = [[FOSLocationItem alloc]initWithName: name
                                                uuid: uuid
                                               major: major
                                               minor: minor];
        [self.items addObject: item];
        [self startMonitoringItem: item];
    }
}

- (void)persistItems {
    NSMutableArray *itemsDataArray = [NSMutableArray array];
    for (FOSLocationItem *item in self.items) {
        NSData *itemData = [NSKeyedArchiver archivedDataWithRootObject:item];
        [itemsDataArray addObject:itemData];
    }
    [[NSUserDefaults standardUserDefaults] setObject:itemsDataArray forKey:kRWTStoredItemsKey];
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FOSLocationItem *itemToRemove = [self.items objectAtIndex:indexPath.row];
        [self stopMonitoringItem:itemToRemove];
        [tableView beginUpdates];
        [self.items removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
        [self persistItems];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FOSLocationItem *item = [self.items objectAtIndex:indexPath.row];
//    NSURL *url = [NSURL URLWithString:@"http://192.168.0.17:3000/api"];
//    NSData *responseData = [NSData dataWithContentsOfURL:url];
//    NSDictionary *forms = [NSJSONSerialization JSONObjectWithData: responseData options: NSJSONReadingMutableLeaves error: nil];
//    
//    NSString *message = [[NSString alloc] init];
//    if ([item.name isEqualToString: @"Kegerator"]){
//        message = forms[@"form1"];
//    } else if ([item.name isEqualToString: @"Kitchen"]) {
//        message = forms[@"form2"];
//    } else if ([item.name isEqualToString: @"Bathroom"]) {
//        message = forms[@"form3"];
//    } else {
//        message = @"Something went horribly wrong";
//    }
    
    NSString *message = @"WTF";
    
    UIAlertView *formAlert = [[UIAlertView alloc]
                              initWithTitle:item.name message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [formAlert show];
//    NSString *detailMessage = [NSString stringWithFormat:@"UUID: %@\nMajor: %d\nMinor: %d", item.uuid.UUIDString, item.majorValue, item.minorValue];
//    UIAlertView *detailAlert = [[UIAlertView alloc] initWithTitle:@"Details" message:detailMessage delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
//    [detailAlert show];
    
}

@end