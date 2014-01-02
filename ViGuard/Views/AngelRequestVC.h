//
//  AngelRequestVC.h
//  ViGuard
//
//  Created by Ronen Shraga on 12/30/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AngelRequestVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *elderDistanceLbl;
@property (weak, nonatomic) IBOutlet UIButton *yesBtn;
@property (weak, nonatomic) IBOutlet UIButton *noBtn;

-(void)setData:(NSNumber*)distance elder_id:(NSNumber*)elder_id panic_id:(NSNumber*)panic_id status:(NSString*)status;

@end
