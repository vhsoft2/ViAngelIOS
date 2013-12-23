//
//  AngelsMapVC.h
//  ViGuard
//
//  Created by Ronen Shraga on 12/21/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface AngelsMapVC : UIViewController <UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *caregiversTV;
@property (weak, nonatomic) IBOutlet MKMapView *angelsMap;

-(void)setElderDetails:(NSString*)name lat:(double)lat lon:(double)lon;

@end
