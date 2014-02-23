//
//  AngelWaitVC.h
//  ViGuard
//
//  Created by Ronen Shraga on 1/2/14.
//  Copyright (c) 2014 Vitalitix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface AngelWaitVC : GAITrackedViewController

-(void)setData:(NSString*)token elder_id:(NSNumber*)elder_id panic_id:(NSNumber*)panic_id status:(NSString*)status;

@end
