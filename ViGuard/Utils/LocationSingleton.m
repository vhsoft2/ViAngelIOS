//
//  LocationSingleton.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/25/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//
#import "LocationSingleton.h"

@implementation LocationSingleton

@synthesize locationManager;

- (id)init {
    self = [super init];
    
    if(self) {
        self.locationManager = [CLLocationManager new];
        [self.locationManager setDelegate:self];
        [self.locationManager setDistanceFilter:50];//kCLDistanceFilterNone];
        [self.locationManager setHeadingFilter:kCLHeadingFilterNone];
        [self.locationManager startUpdatingLocation];
        [self.locationManager setActivityType:CLActivityTypeFitness];
        //do any more customization to your location manager
    }
    
    return self;
}

+ (LocationSingleton*)sharedSingleton {
    static LocationSingleton* sharedSingleton;
    if(!sharedSingleton) {
        @synchronized(sharedSingleton) {
            sharedSingleton = [LocationSingleton new];
        }
    }
    
    return sharedSingleton;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //NSLog(@"%@:%@", NSStringFromSelector(_cmd), newLocation);
    //handle your location updates here
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    //handle your heading updates here- I would suggest only handling the nth update, because they
    //come in fast and furious and it takes a lot of processing power to handle all of them
}

@end
