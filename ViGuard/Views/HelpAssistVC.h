//
//  HelpAssistVC.h
//  ViGuard
//
//  Created by Ronen Shraga on 12/30/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GAITrackedViewController.h"

@interface HelpAssistVC : GAITrackedViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *elderHomeAddrBtn;
@property (weak, nonatomic) IBOutlet UIButton *elderCurrentAddrBtn;
@property (weak, nonatomic) IBOutlet MKMapView *helpMap;
@property (weak, nonatomic) IBOutlet UIButton *elderPhoneBtn;
@property (weak, nonatomic) IBOutlet UILabel *elderNameLbl;
@property (weak, nonatomic) IBOutlet UIImageView *elderImg;
@property (weak, nonatomic) IBOutlet UILabel *distanceLbl;

-(void)setData:(NSString*)token elder_id:(NSNumber*)elder_id panic_id:(NSNumber*)panic_id status:(NSString*)status;

@end
