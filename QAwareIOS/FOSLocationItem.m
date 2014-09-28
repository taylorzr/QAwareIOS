//
//  FOSLocationItem.m
//  QAwareIOS
//
//  Created by Zach Taylor & Brandon Manson on 9/28/14.
//  Copyright (c) 2014 Flock of Squirrels Studios. All rights reserved.
//

#import "FOSLocationItem.h"

@implementation FOSLocationItem

- (instancetype)initWithName:(NSString *)name
                        uuid:(NSUUID *)uuid
                         url:(NSString *)url
                       major:(uint16_t)major
                       minor:(uint16_t)minor
{
    self = [super init];
    if (!self) {
        return nil;
    }

    _name = name;
    _uuid = uuid;
    _url = url;
    _majorValue = major;
    _minorValue = minor;

    return self;
}

- (BOOL)isEqualToCLBeacon:(CLBeacon *)beacon
{
    if ([[beacon.proximityUUID UUIDString] isEqualToString:[self.uuid UUIDString]] &&
        [beacon.major isEqual: @(self.majorValue)] &&
        [beacon.minor isEqual: @(self.minorValue)]) {
        return YES;
    } else {
        return NO;
    }
}

@end