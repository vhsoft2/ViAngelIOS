//
//  EventLogCell.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/22/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import "EventLogCell.h"

@implementation EventLogCell

@synthesize eventLogImg;
@synthesize eventLogTxt;
@synthesize playImg;
@synthesize eventLogId;

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
