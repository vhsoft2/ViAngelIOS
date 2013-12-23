//
//  EventLogVC.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/21/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import "EventLogVC.h"
#import "EventLogCell.h"
#import "DataUtils.h"
#import "HttpService.h"

@interface EventLogVC ()

@end

@implementation EventLogVC

@synthesize audioPlayer;
@synthesize eventLogTV;

typedef enum {AudioOff, AudioLoading, AudioPlaying, AudioPaused} AudioStatus;

NSArray *eventLogArr;
AudioStatus audioStatus = AudioOff;
long audioIdx = -1;
UserData *userData;

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
	// Do any additional setup after loading the view.
    userData = [DataUtils getUserData];
    eventLogArr = [[NSArray alloc] init];
    [self getEventLog];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getEventLog {
    NSMutableDictionary *mapData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:userData.guardianToken, @"token", nil];
    HttpService *httpService = [[HttpService alloc] init];
    [httpService postJsonRequest:@"get_elder_log" postDict:mapData callbackOK:^(NSDictionary *jsonDict) {
        eventLogArr = (NSArray*)jsonDict;
        dispatch_async(dispatch_get_main_queue(), ^{
             [eventLogTV reloadData];
         });
    } callbackErr:^(NSString* errStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
             [[[UIAlertView alloc] initWithTitle:@"Get Elder Log" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
         });
    }];
}

-(void)loadEventAudio:(NSNumber*)eventLogId {
    NSMutableDictionary *mapData = [[NSMutableDictionary alloc] initWithObjectsAndKeys: userData.guardianToken, @"token", eventLogId,@"event_log_id",@"iPhone",@"platform",nil];
    HttpService *httpService = [[HttpService alloc] init];
    [httpService postDataRequest:@"get_event_audio" postDict:mapData callbackOK:^(NSString *audioStr) {
        NSLog(@"%@: Audio Size:%lu", NSStringFromSelector(_cmd), (unsigned long)audioStr.length);
        if (audioStr.length > 0) {
            if (audioIdx >=0 ) {
                audioStatus = AudioPlaying;
                NSError *error;
                audioPlayer = [[AVAudioPlayer alloc] initWithData:(NSData*)[DataUtils dataFromBase64:audioStr] error:&error];
                if (error)
                {
                    audioStatus = AudioOff;
                    NSLog(@"Error in audioPlayer: %@", [error localizedDescription]);
               } else {
                    audioPlayer.delegate = self;
                    if (![audioPlayer play]) {
                        audioStatus = AudioOff;
                        NSLog(@"%@:Error in prapareToPlay", NSStringFromSelector(_cmd));
                    }
                }
            }
        } else {
            audioStatus = AudioOff;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
             [eventLogTV reloadData];
         });
    } callbackErr:^(NSString* errStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
             [[[UIAlertView alloc] initWithTitle:@"Get Event Audio" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
             audioStatus = AudioOff;
             [eventLogTV reloadData];
         });
    }];
}

#pragma mark IBActions
- (IBAction)backToParent:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark AVAudioPlayerDelegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //NSLog(@"%@: Done playing %hhd", NSStringFromSelector(_cmd), flag);
    audioStatus = AudioOff;
    [eventLogTV reloadData];
}
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"%@:%@", NSStringFromSelector(_cmd), error);
}
-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    NSLog(@"%@:audioPlayerBeginInterruption", NSStringFromSelector(_cmd));
}
-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    NSLog(@"%@:audioPlayerEndInterruption", NSStringFromSelector(_cmd));
}

#pragma mark UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
	long idx=indexPath.row;
    NSString *recFile = [eventLogArr[idx] objectForKey:@"recording"];
    if (![recFile isKindOfClass:[NSNull class]]) {
        if (idx == audioIdx) {
            switch (audioStatus) {
                case AudioOff:
                    audioStatus = AudioLoading;
                    break;
                case AudioLoading:
                    audioStatus = AudioOff;
                    audioIdx = -1;
                    break;
                case AudioPlaying:
                    audioStatus = AudioPaused;
                    [audioPlayer pause];
                    break;
                case AudioPaused:
                    audioStatus = AudioPlaying;
                    [audioPlayer play];
                    break;
                default:
                    break;
            }
        } else {
            audioIdx = idx;
            audioStatus = AudioLoading;
        }
        if (audioStatus == AudioLoading) {
            [self loadEventAudio:@([[eventLogArr[idx] objectForKey:@"id"] intValue])];
        }
        [eventLogTV reloadData];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return eventLogArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"eventCell";
    
    EventLogCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[EventLogCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:CellIdentifier];
    }
    //"id": 95, "schedule_type": null, "date": 1385478386000, "comments": "Listen at 4", "recording": ""
    NSDictionary *cellDict = [eventLogArr objectAtIndex:indexPath.row];
    NSString *scheduleType =[cellDict objectForKey:@"schedule_type"];
    if ([scheduleType isKindOfClass:[NSNull class]]) {
        cell.eventLogImg = nil;
    } else if ([scheduleType isEqualToString:@"listen"]) {
        [cell.eventLogImg setImage:[UIImage imageNamed:@"listen-30.png"]];
    } else if ([scheduleType isEqualToString:@"conf"]) {
        [cell.eventLogImg setImage:[UIImage imageNamed:@"call-30.png"]];
    } else if ([scheduleType isEqualToString:@"reminder"]) {
        [cell.eventLogImg setImage:[UIImage imageNamed:@"reminder-30.png"]];
    } else if ([scheduleType isEqualToString:@"panic"]) {
        [cell.eventLogImg setImage:[UIImage imageNamed:@"panic-30.png"]];
    }
    NSString *audio =[cellDict objectForKey:@"recording"];
    if ([audio isKindOfClass:[NSNull class]]) {
        cell.playImg.image = nil;
    } else {
        if (audioStatus == AudioOff || indexPath.row != audioIdx) {
            [cell.playImg setImage:[UIImage imageNamed:@"play-30.png"]];
        } else {
            if (indexPath.row == audioIdx) {
                switch (audioStatus) {
                    case AudioLoading:
                        [cell.playImg setImage:[UIImage imageNamed:@"waiting-30.png"]];
                        break;
                    case AudioPlaying:
                        [cell.playImg setImage:[UIImage imageNamed:@"stop-30.png"]];
                        break;
                    case AudioPaused:
                        [cell.playImg setImage:[UIImage imageNamed:@"pause-30.png"]];
                        break;
                    default:
                        break;
                }
            }
        }
    }
    cell.eventLogTxt.text = [NSString stringWithFormat:@"%@ %@", [DataUtils strFromDate:[DataUtils dateFromMilliSeconds:[cellDict objectForKey:@"date"]] format:@"dd-MM HH:mm"], [cellDict objectForKey:@"comments"]];
    return cell;
}

@end
