//
//  ElderMapVC.h
//  ViGuard
//
//  Created by Ronen Shraga on 12/20/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ElderMapVC : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *elderMapView;
@property (weak, nonatomic) IBOutlet UILabel *addressTxt;

-(void)setAddress:(NSString*)address token:(NSString*)token;

@end
