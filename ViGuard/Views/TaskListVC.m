//
//  TaskListVC.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/21/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import "TaskListVC.h"
#import "TaskListTVC.h"
#import "DataUtils.h"
#import "HttpService.h"
#import "UserData.h"
#import "EditTaskVC.h"

@interface TaskListVC ()

@end

@implementation TaskListVC

@synthesize tasksTV;

UserData *userData;
NSArray *tasksArr;
bool rowClicked;

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
    userData = [DataUtils getUserData];
    rowClicked = false;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getTaskList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getTaskList {
    [[[HttpService alloc] init] postJsonRequest:@"get_elder_tasks" postDict:[[NSMutableDictionary alloc] initWithDictionary:@{@"token": userData.guardianToken}] callbackOK:^(NSDictionary *jsonDict) {
        tasksArr = (NSArray*)jsonDict;
        dispatch_async(dispatch_get_main_queue(), ^{
            [tasksTV reloadData];
        });
    } callbackErr:^(NSString* errStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Get Elder Tasks" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        });
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"fromTaskListToEditTask"])
    {
        long selectedTaskIdx = tasksTV.indexPathForSelectedRow.row;
        EditTaskVC *evc = [segue destinationViewController];
        if (rowClicked) {
            
            if (selectedTaskIdx>=0 && selectedTaskIdx<tasksArr.count)
                [evc setTaskData:tasksArr[selectedTaskIdx] uData:userData];
        }
        else
            [evc setTaskData:nil uData:userData];
    }
}

#pragma mark IBActions

- (IBAction)backToParent:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)newTaskClicked:(id)sender {
    rowClicked = false;
    [self performSelector:@selector(performSegueWithIdentifier:sender:) withObject:@"fromTaskListToEditTask"];
}

#pragma mark UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    rowClicked = true;
    [self performSelector:@selector(performSegueWithIdentifier:sender:) withObject:@"fromTaskListToEditTask"];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tasksArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{//{ "task_id": 589, "elder_id": 132, "schedule_type": "text", "create_date": null, "start_date": 1384908913000, "end_date": 1384908913000, "repeat_type": "none", "repeat_parameters": "", "record": 1, "title": "Testing SMS from the server", "to": "elder" }
    static NSString *CellIdentifier = @"taskCell";
    
    TaskListTVC *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TaskListTVC alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:CellIdentifier];
    }
    NSDictionary *taskDict = [tasksArr objectAtIndex:indexPath.row];
    //The title
    cell.taskTitleLbl.text = [taskDict objectForKey:@"title"];
    //The type icon
    NSString *taskType = [taskDict objectForKey:@"schedule_type"];
    if ([taskType isEqualToString:@"listen"]) {
        cell.taskTypeImg.image = [UIImage imageNamed:@"listen-30.png"];
    } else if ([taskType isEqualToString:@"reminder"]) {
        cell.taskTypeImg.image = [UIImage imageNamed:@"reminder-30.png"];
    }
    //The date
    cell.taskDateLbl.text = [DataUtils strFromDate:[DataUtils dateFromMilliSeconds:[taskDict objectForKey:@"start_date"]] format:@"dd-MM-yy HH:mm:ss"];
    return cell;
}

@end
