//
//  LocationSingleton.h
//  ViGuard
//
//  Created by Ronen Shraga on 12/25/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//
#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>

@interface LocationSingleton : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager* locationManager;

+ (LocationSingleton*)sharedSingleton;

@end
