//
//  EditTaskVC.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/23/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import "EditTaskVC.h"
#import "DataUtils.h"

@interface EditTaskVC ()

@end

@implementation EditTaskVC

@synthesize taskEndDateTxt;
@synthesize taskRecurrentTxt;
@synthesize taskStartDateTxt;
@synthesize taskTitleTxt;
@synthesize taskToTxt;
@synthesize taskTypeTxt;
@synthesize recordButton;
@synthesize playButton;
@synthesize recordLengthTxt;
@synthesize endDateLbl;
@synthesize saveBtn;
@synthesize cancelBtn;

NSDictionary *taskDict;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[saveBtn layer] setBorderWidth:2.0f];
    [[saveBtn layer] setBorderColor:[UIColor colorWithRed:66.0/255 green:152.0/255 blue:252.0/255 alpha:1].CGColor];
    saveBtn.layer.cornerRadius = 8.0f;
    [self displayTask];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////{ "task_id": 589, "elder_id": 132, "schedule_type": "text", "create_date": null, "start_date": 1384908913000, "end_date": 1384908913000, "repeat_type": "none", "repeat_parameters": "", "record": 1, "title": "Testing SMS from the server", "to": "elder" }
-(void)displayTask {
    if (taskDict) {
        taskTitleTxt.text = [taskDict objectForKey:@"title"];
        taskStartDateTxt.text = [DataUtils dateTimeStrFromDate:[DataUtils dateFromMilliSeconds:[taskDict objectForKey:@"start_date"]]];
        taskToTxt.text = [taskDict objectForKey:@"to"];
        taskTypeTxt.text = [taskDict objectForKey:@"schedule_type"];
        taskRecurrentTxt.text = [taskDict objectForKey:@"repeat_type"];
        if ([taskRecurrentTxt.text isEqualToString:@""] || [taskRecurrentTxt.text isEqualToString:@"none"]) {
            endDateLbl.hidden = YES;
            taskEndDateTxt.hidden = YES;
        } else {
            endDateLbl.hidden = NO;
            taskEndDateTxt.hidden = NO;
        }
        taskEndDateTxt.text = [DataUtils dateTimeStrFromDate:[DataUtils dateFromMilliSeconds:[taskDict objectForKey:@"end_date"]]];
    }
}

-(void)setTaskData:(NSDictionary*)dict {
    taskDict = dict;
}

#pragma mark IBActions

- (IBAction)backToParentClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)recordClicked:(id)sender {
    recordButton.selected ^= YES;
}
- (IBAction)playClicked:(id)sender {
}
- (IBAction)saveClicked:(id)sender {
}
- (IBAction)cancelClicked:(id)sender {
}
- (IBAction)deleteClicked:(id)sender {
}
@end
