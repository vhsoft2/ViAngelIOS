//
//  ElderStatusVC.h
//  ViGuard
//
//  Created by Ronen Shraga on 12/19/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ElderStatusVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *elderNameLbl;
@property (weak, nonatomic) IBOutlet UIImageView *elderImage;
@property (weak, nonatomic) IBOutlet UIButton *elderStatusBtn;

@property (weak, nonatomic) IBOutlet UILabel *elderAddressLbl;
@property (weak, nonatomic) IBOutlet UILabel *elderLastStatTmLbl;
@property (weak, nonatomic) IBOutlet UILabel *tasksLbl;
@property (weak, nonatomic) IBOutlet UILabel *angelsStatusLbl;
@property (weak, nonatomic) IBOutlet UILabel *angelsProximityLbl;
@property (weak, nonatomic) IBOutlet UILabel *taskTimeLbl;

@end
