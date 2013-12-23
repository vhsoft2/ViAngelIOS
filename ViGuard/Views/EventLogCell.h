//
//  EventLogCell.h
//  ViGuard
//
//  Created by Ronen Shraga on 12/22/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventLogCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *eventLogTxt;
@property (weak, nonatomic) IBOutlet UIImageView *eventLogImg;
@property (weak, nonatomic) IBOutlet UIImageView *playImg;
@property int eventLogId;

@end
