//
//  PanicHandleVC.h
//  ViGuard
//
//  Created by Ronen Shraga on 12/26/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface PanicHandleVC : GAITrackedViewController

-(void)setData:(NSString*)token panic_id:(NSNumber*)panic_id angel_id:(NSNumber*)angel_id elderName:(NSString*)name elderLat:(double)lat elderLon:(double)lon;

@end
