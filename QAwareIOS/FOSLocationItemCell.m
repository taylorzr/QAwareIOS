//
//  FOSLocationItemCell.m
//  QAwareIOS
//
//  Created by Zach Taylor & Brandon Manson on 9/28/14.
//  Copyright (c) 2014 Flock of Squirrels Studios. All rights reserved.
//

#import "FOSLocationItemCell.h"
#import "FOSLocationItem.h"

@implementation FOSLocationItemCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.item = nil;
}

- (void)setItem:(FOSLocationItem *)item {
    if (_item) {
        [_item removeObserver:self forKeyPath:@"lastSeenBeacon"];
    }
    
    _item = item;
    [_item addObserver:self
            forKeyPath:@"lastSeenBeacon"
               options:NSKeyValueObservingOptionNew
               context:NULL];
    
    self.textLabel.text = _item.name;
}

-(void)dealloc {
    [_item removeObserver: self forKeyPath:@"lastSeenBeacon"];
}

- (NSString *)nameForProximity:(CLProximity)proximity {
    switch (proximity) {
        case CLProximityUnknown:
            return @"Unknown";
            break;
        case CLProximityImmediate:
            return @"Immediate";
            break;
        case CLProximityNear:
            return @"Near";
            break;
        case CLProximityFar:
            return @"Far";
            break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([object isEqual:self.item] && [keyPath isEqualToString:@"lastSeenBeacon"]) {
        NSString *proximity = [self nameForProximity:self.item.lastSeenBeacon.proximity];
        self.detailTextLabel.text = [NSString stringWithFormat:@"Location: %@", proximity];
        if (proximity == @"Near" || proximity == @"Immediate") {
            self.detailTextLabel.textColor = [UIColor whiteColor];
            self.textLabel.textColor = [UIColor whiteColor];
            self.detailTextLabel.backgroundColor = [UIColor colorWithRed:0.557 green:0.267 blue:0.678 alpha:0.5];
            self.textLabel.backgroundColor = [UIColor colorWithRed:0.557 green:0.267 blue:0.678 alpha:0.5];
            self.backgroundColor = [UIColor colorWithRed:0.557 green:0.267 blue:0.678 alpha:0.5];
        }
        else {
            self.detailTextLabel.textColor = [UIColor grayColor];
            self.textLabel.textColor = [UIColor grayColor];
            self.backgroundColor = [UIColor whiteColor];
        }
    }
}

@end
