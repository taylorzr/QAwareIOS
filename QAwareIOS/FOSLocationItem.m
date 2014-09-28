//
//  FOSLocationItem.m
//  QAwareIOS
//
//  Created by Zach Taylor & Brandon Manson on 9/28/14.
//  Copyright (c) 2014 Flock of Squirrels Studios. All rights reserved.
//

#import "FOSLocationItem.h"

static NSString * const kRWTItemNameKey = @"name";
static NSString * const kRWTItemUUIDKey = @"uuid";
static NSString * const kRWTItemMajorValueKey = @"major";
static NSString * const kRWTItemMinorValueKey = @"minor";

@implementation FOSLocationItem

- (instancetype)initWithName:(NSString *)name
                        uuid:(NSUUID *)uuid
                       major:(uint16_t)major
                       minor:(uint16_t)minor
{
    self = [super init];
    if (!self) {
        return nil;
    }

    _name = name;
    _uuid = uuid;
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

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _name = [aDecoder decodeObjectForKey:kRWTItemNameKey];
    _uuid = [aDecoder decodeObjectForKey:kRWTItemUUIDKey];
    _majorValue = [[aDecoder decodeObjectForKey:kRWTItemMajorValueKey] unsignedIntegerValue];
    _minorValue = [[aDecoder decodeObjectForKey:kRWTItemMinorValueKey] unsignedIntegerValue];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:kRWTItemNameKey];
    [aCoder encodeObject:self.uuid forKey:kRWTItemUUIDKey];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.majorValue] forKey:kRWTItemMajorValueKey];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.minorValue] forKey:kRWTItemMinorValueKey];
}

@end
