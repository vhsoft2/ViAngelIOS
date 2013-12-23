//
//  EditTaskVC.h
//  ViGuard
//
//  Created by Ronen Shraga on 12/23/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditTaskVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *taskTitleTxt;
@property (weak, nonatomic) IBOutlet UITextField *taskStartDateTxt;
@property (weak, nonatomic) IBOutlet UITextField *taskToTxt;
@property (weak, nonatomic) IBOutlet UITextField *taskTypeTxt;
@property (weak, nonatomic) IBOutlet UITextField *taskRecurrentTxt;
@property (weak, nonatomic) IBOutlet UITextField *taskEndDateTxt;
@property (weak, nonatomic) IBOutlet UILabel *endDateLbl;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *recordLengthTxt;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

-(void)setTaskData:(NSDictionary*)dict;

@end
