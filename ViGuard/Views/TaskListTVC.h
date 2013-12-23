//
//  TaskListTVC.h
//  ViGuard
//
//  Created by Ronen Shraga on 12/23/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskListTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *taskDateLbl;
@property (weak, nonatomic) IBOutlet UIImageView *taskTypeImg;
@property (weak, nonatomic) IBOutlet UILabel *taskTitleLbl;

@end
