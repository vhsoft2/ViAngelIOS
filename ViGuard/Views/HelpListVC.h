//
//  HelpListVC.h
//  ViGuard
//
//  Created by Ronen Shraga on 12/26/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@interface HelpListVC : UIViewController <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *helpListTV;
@property (weak, nonatomic) IBOutlet MKMapView *helpMap;

-(void)setData:(NSString*)token panicid:(NSNumber*)panicid elderName:(NSString*)name elderLat:(double)lat elderLon:(double)lon;

@end
