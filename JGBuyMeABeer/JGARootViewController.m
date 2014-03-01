//
//  JGARootViewController.m
//  JGBuyMeABeer
//
//  Created by John Grant on 2014-02-28.
//  Copyright (c) 2014 John Grant. All rights reserved.
//

#import "JGARootViewController.h"
#import <CoreLocation/CoreLocation.h>

static NSString * beaconRegionUUID = @"E132EBAE-AB52-4ABD-B6A8-6B7C65BA407D";
static NSString * beaconRegionIdentifier = @"ca.jg.buymeabeer";


@interface JGARootViewController () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UILabel *majorLabel;
@property (weak, nonatomic) IBOutlet UILabel *minorLabel;
@property (weak, nonatomic) IBOutlet UILabel *proximityLabel;
@property (weak, nonatomic) IBOutlet UILabel *accuracyLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (weak, nonatomic) IBOutlet UIView *indicatorView;

@end

@implementation JGARootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Beacon Information";

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:beaconRegionUUID];
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                identifier:beaconRegionIdentifier];
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    region.notifyEntryStateOnDisplay = YES;
    
    [self.locationManager startMonitoringForRegion:region];
    
    [self.locationManager requestStateForRegion:region];
    
    self.proximityLabel.font = self.accuracyLabel.font;
    self.proximityLabel.textColor = self.accuracyLabel.textColor;
    
    self.indicatorView.layer.cornerRadius = CGRectGetWidth(self.indicatorView.frame) / 2 ;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    if (state == CLRegionStateInside) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        [self.locationManager startRangingBeaconsInRegion:beaconRegion];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        if ([beaconRegion.identifier isEqualToString:beaconRegionIdentifier]) {
            
            [self.locationManager startRangingBeaconsInRegion:beaconRegion];
            
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        if ([beaconRegion.identifier isEqualToString:beaconRegionIdentifier]) {
            
            [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
            
        }
    }
}

- (NSString *)stringForProximity:(CLProximity)proximity {
    switch (proximity) {
        case CLProximityUnknown:    return @"Unknown";
        case CLProximityFar:        return @"Far";
        case CLProximityNear:       return @"Near";
        case CLProximityImmediate:  return @"Immediate";
        default:
            return nil;
    }
}
- (UIColor *)colorForProximity:(CLProximity)proximity {
    switch (proximity) {
        case CLProximityUnknown:    return [UIColor whiteColor];
        case CLProximityFar:        return [UIColor grayColor];
        case CLProximityNear:       return [UIColor yellowColor];
        case CLProximityImmediate:  return [UIColor greenColor];
        default:
            return nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    for (CLBeacon *beacon in beacons) {
        NSLog(@"Ranging beacon: %@", beacon.proximityUUID);
        NSLog(@"%@ - %@", beacon.major, beacon.minor);
        NSLog(@"Range: %@", [self stringForProximity:beacon.proximity]);
        
        [self updateWithBeacon:beacon];
    }
}

- (void)updateWithBeacon:(CLBeacon *)beacon
{
    self.majorLabel.text = [beacon.major description];
    self.minorLabel.text = [beacon.minor description];
    self.proximityLabel.text = [self stringForProximity:beacon.proximity];
    self.accuracyLabel.text = [NSString stringWithFormat:@"%f", beacon.accuracy];
    self.rssiLabel.text = [NSString stringWithFormat:@"%d", beacon.rssi];
    self.indicatorView.backgroundColor = [self colorForProximity:beacon.proximity];
}


@end
