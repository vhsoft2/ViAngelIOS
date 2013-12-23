//
//  TaskListTVC.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/23/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import "TaskListTVC.h"

@implementation TaskListTVC

@synthesize taskDateLbl;
@synthesize taskTitleLbl;
@synthesize taskTypeImg;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
