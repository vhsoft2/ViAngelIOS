//
//  GuardianTVC.h
//  ViGuard
//
//  Created by Ronen Shraga on 12/22/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CaregiverTVC : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *caregiverImg;
@property (weak, nonatomic) IBOutlet UILabel *caregiverNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *caregiverDistanceLbl;

@end
