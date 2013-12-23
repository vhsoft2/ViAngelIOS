//
//  EventLogVC.h
//  ViGuard
//
//  Created by Ronen Shraga on 12/21/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface EventLogVC : UIViewController <UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (weak, nonatomic) IBOutlet UITableView *eventLogTV;

@end
