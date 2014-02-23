//
//  TaskListVC.h
//  ViGuard
//
//  Created by Ronen Shraga on 12/21/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface TaskListVC : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tasksTV;

@end
