//
//  EditTaskVC.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/23/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import "EditTaskVC.h"
#import "HttpService.h"

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
@synthesize audioTimer;
@synthesize recordMessageLbl;

//picker properties
@synthesize picekerSelectedIndex;
@synthesize actionSheetPicker;
//Globals
NSDictionary *taskDict;
NSDate *taskEndDate;
NSString *taskRecurrent;
NSDate *taskStartDate;
NSString *taskTitle;
NSString *taskTo;
NSString *taskType;
NSArray *toOptionsArr;
NSArray *repeatTypesArr;
NSArray *taskTypesArr;
UserData *userData;
NSNumber *taskId;
//Audio
AVAudioRecorder *recorder;
AVAudioPlayer *player;
typedef enum {Recording,Playing,Paused,Stopped} PlayStatus;
PlayStatus playStatus;
NSString *b64Voice;

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
    //initialize picker arrays
    toOptionsArr = @[@"elder",@"both"];
    repeatTypesArr = @[@"none", @"daily",@"weekly"];
    taskTypesArr = @[@"reminder",@"listen"];
    //Beautify the save button
    [[saveBtn layer] setBorderWidth:2.0f];
    [[saveBtn layer] setBorderColor:[UIColor colorWithRed:66.0/255 green:152.0/255 blue:252.0/255 alpha:1].CGColor];
    saveBtn.layer.cornerRadius = 8.0f;
    //
    //Audio setup
    playStatus = Stopped;
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects: [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], @"MyAudioMemo.m4a", nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    //Show the task
    [self displayTask];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [taskTitleTxt resignFirstResponder];
}



////{ "task_id": 589, "elder_id": 132, "schedule_type": "text", "create_date": null, "start_date": 1384908913000, "end_date": 1384908913000, "repeat_type": "none", "repeat_parameters": "", "record": 1, "title": "Testing SMS from the server", "to": "elder" }
-(void)displayTask {
    if (taskDict) {
        taskEndDate = [DataUtils dateFromMilliSeconds:[taskDict objectForKey:@"end_date"]];
        taskRecurrent = [taskDict objectForKey:@"repeat_type"];
        taskStartDate = [DataUtils dateFromMilliSeconds:[taskDict objectForKey:@"start_date"]];
        taskTitle = [taskDict objectForKey:@"title"];
        taskTo = [taskDict objectForKey:@"to"];
        taskType = [taskDict objectForKey:@"schedule_type"];
        taskId = [taskDict objectForKey:@"task_id"];
    } else {
        taskEndDate = [[NSDate date] dateByAddingTimeInterval:84600];
        taskRecurrent = @"none";
        taskStartDate = [[NSDate date] dateByAddingTimeInterval:120];
        taskTitle = @"";
        taskTo = toOptionsArr[0];
        taskType = taskTypesArr[0];
        taskId = nil;
    }
    taskTitleTxt.text = taskTitle;
    taskStartDateTxt.text = [DataUtils dateTimeStrFromDate:taskStartDate];
    taskToTxt.text = taskTo;
    taskTypeTxt.text = taskType;
    taskRecurrentTxt.text = taskRecurrent;
    taskEndDateTxt.text = [DataUtils dateTimeStrFromDate:taskEndDate];
    [self showTaskEndDate:taskRecurrent];
    [self showRecordControl];
    if (taskId && [taskType isEqualToString:@"reminder"])
        [self getTaskAudio];
    
}

-(void)showRecordControl {
    if ([taskType isEqualToString:@"listen"]) {
        recordButton.hidden = YES;
        recordLengthTxt.hidden = YES;
        playButton.hidden = YES;
        recordMessageLbl.hidden = YES;
    } else {
        recordButton.hidden = NO;
        recordLengthTxt.hidden = NO;
        playButton.hidden = NO;
        recordMessageLbl.hidden = NO;
    }
}

-(void)showTaskEndDate:(NSString*)repeatType {
    if ([repeatType isEqualToString:@""] || [repeatType isEqualToString:@"none"]) {
        endDateLbl.hidden = YES;
        taskEndDateTxt.hidden = YES;
    } else {
        endDateLbl.hidden = NO;
        taskEndDateTxt.hidden = NO;
    }
}
//
//Called from sague
//
-(void)setTaskData:(NSDictionary*)dict uData:(UserData*)uData {
    taskDict = dict;
    userData = uData;
}

-(void)saveTask {
    //[[NSData alloc] initWithContentsOfURL:recorder.url options:NSDataReadingMapped error:@selector(<#selector#>):];
    NSNumber *startDateMs = [DataUtils milliSecondsFromDate:[DataUtils dateFromStr:taskStartDateTxt.text]];
    NSNumber *endDateMs;
    if ([taskRecurrentTxt.text isEqualToString:@"none"])
        endDateMs = [DataUtils milliSecondsFromDate:[[DataUtils dateFromStr:taskStartDateTxt.text] dateByAddingTimeInterval:1]];
    else
        endDateMs = [DataUtils milliSecondsFromDate:[DataUtils dateFromStr:taskEndDateTxt.text]];
    //b64Voice = [DataUtils dataToBase64:[NSData dataWithContentsOfURL:recorder.url]];
    NSData *data = [NSData dataWithContentsOfURL:recorder.url];
    b64Voice = [DataUtils dataToBase64:data];
    
    NSMutableDictionary *mapData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                    userData.guardianToken, @"token",
                                    taskId,                 @"task_id",
                                    taskTypeTxt.text,       @"schedule_type",
                                    startDateMs,            @"start_date",
                                    endDateMs,              @"end_date",
                                    taskRecurrentTxt.text,  @"repeat_type",
                                    //taskRepeatParams,     @"repeat_parameters",
                                    taskToTxt.text,         @"to",
                                    taskTitleTxt.text,      @"title",
                                    //taskTimeout,          @"timeout",
                                    b64Voice,               @"voice",
                                    @"iPhone-",              @"platform",nil];
    HttpService *httpService = [[HttpService alloc] init];
    [httpService postDataRequest:@"add_update_elder_task" postDict:mapData callbackOK:^(NSString *tid) {
        NSLog(@"%@:%@", NSStringFromSelector(_cmd), tid);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    } callbackErr:^(NSString* errStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Get Task Audio" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        });
    }];
}

-(void)getTaskAudio {
    NSMutableDictionary *mapData = [[NSMutableDictionary alloc] initWithObjectsAndKeys: userData.guardianToken, @"token", taskId,@"task_id",@"iPhone-",@"platform",nil];
    HttpService *httpService = [[HttpService alloc] init];
    [httpService postDataRequest:@"get_task_audio" postDict:mapData callbackOK:^(NSString *audioStr) {
        //NSLog(@"%@: Audio Size:%lu", NSStringFromSelector(_cmd), (unsigned long)audioStr.length);
        if (audioStr.length > 0) {
            
            NSData *audio = [DataUtils dataFromBase64:audioStr];
            NSError *error;
            
            player = [[AVAudioPlayer alloc] initWithData:audio error:&error];
            //audioPlayer = [[AVAudioPlayer alloc] initWithData:(NSData*)[DataUtils dataFromBase64:audioStr] fileTypeHint:AVFileTypeAMR error:&error];
            if (error)
            {
                playStatus = Stopped;
                NSLog(@"Error in audioPlayer: %@", [error localizedDescription]);
            } else {
                player.delegate = self;
                if (![player play]) {
                    playStatus = Stopped;
                    NSLog(@"%@:Error in prapareToPlay", NSStringFromSelector(_cmd));
                } else {
                    //Save to local file
                    [audio writeToURL:recorder.url atomically:YES];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self startPlay];
                    });
                }
            }
        } else {
            playStatus = Stopped;
        }
    } callbackErr:^(NSString* errStr) {
        playStatus = Stopped;
        NSLog(@"%@:%@", NSStringFromSelector(_cmd), errStr);
        //dispatch_async(dispatch_get_main_queue(), ^{
        //    [[[UIAlertView alloc] initWithTitle:@"Get Task Audio" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        //});
    }];
}

#pragma mark UITextViewDelegate

- (void)startDateWasSelected:(NSDate *)selectedDate element:(id)element {
    taskStartDate = selectedDate;
    taskStartDateTxt.text = [DataUtils dateTimeStrFromDate:taskStartDate];
}

- (void)endDateWasSelected:(NSDate *)selectedDate element:(id)element {
    taskEndDate = selectedDate;
    taskEndDateTxt.text = [DataUtils dateTimeStrFromDate:taskEndDate];
}

- (void)toWasSelected:(NSNumber *)selectedIndex element:(id)element {
    picekerSelectedIndex = [selectedIndex intValue];
    taskTo = toOptionsArr[picekerSelectedIndex];
    taskToTxt.text = taskTo;
}

- (void)recurranceWasSelected:(NSNumber *)selectedIndex element:(id)element {
    picekerSelectedIndex = [selectedIndex intValue];
    taskRecurrent = repeatTypesArr[picekerSelectedIndex];
    taskRecurrentTxt.text = taskRecurrent;
    [self showTaskEndDate:taskRecurrent];
}

- (void)taskTypeWasSelected:(NSNumber *)selectedIndex element:(id)element {
    picekerSelectedIndex = [selectedIndex intValue];
    taskType = taskTypesArr[picekerSelectedIndex];
    taskTypeTxt.text = taskType;
    [self showRecordControl];
}

// Delegate function
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL ret = YES;
    // We are now showing the UIPickerViewer instead
    if ([textField isEqual:self.taskRecurrentTxt]) {
        [ActionSheetStringPicker showPickerWithTitle:@"Select Recurrance" rows:repeatTypesArr initialSelection:picekerSelectedIndex target:self successAction:@selector(recurranceWasSelected:element:) cancelAction:nil origin:textField];
        ret = NO;
    } else if ([textField isEqual:self.taskToTxt]) {
        [ActionSheetStringPicker showPickerWithTitle:@"Select To" rows:toOptionsArr initialSelection:picekerSelectedIndex target:self successAction:@selector(toWasSelected:element:) cancelAction:nil origin:textField];
        ret = NO;
    } else if ([textField isEqual:self.taskTypeTxt]) {
        [ActionSheetStringPicker showPickerWithTitle:@"Select Task Type" rows:taskTypesArr initialSelection:picekerSelectedIndex target:self successAction:@selector(taskTypeWasSelected:element:) cancelAction:nil origin:textField];
        ret = NO;
    } else if ([textField isEqual:self.taskStartDateTxt]) {
        actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Start Date" datePickerMode:UIDatePickerModeDateAndTime selectedDate:taskStartDate target:self action:@selector(startDateWasSelected:element:) origin:textField];
        [self.actionSheetPicker addCustomButtonWithTitle:@"Today" value:[NSDate date]];
        [self.actionSheetPicker addCustomButtonWithTitle:@"Tomorrow" value:[[NSDate date] dateByAddingTimeInterval:86400]];
        self.actionSheetPicker.hideCancel = YES;
        [self.actionSheetPicker showActionSheetPicker];
        ret = NO;
    } else if ([textField isEqual:self.taskEndDateTxt]) {
        actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"End Date" datePickerMode:UIDatePickerModeDateAndTime selectedDate:taskEndDate target:self action:@selector(endDateWasSelected:element:) origin:textField];
        [self.actionSheetPicker addCustomButtonWithTitle:@"Today" value:[NSDate date]];
        [self.actionSheetPicker addCustomButtonWithTitle:@"Tomorrow" value:[[NSDate date] dateByAddingTimeInterval:86400]];
        self.actionSheetPicker.hideCancel = YES;
        [self.actionSheetPicker showActionSheetPicker];
        ret = NO;
    }
    if (ret == NO) {
        // Close the keypad if it is showing
        [self.view.superview endEditing:YES];
    }
    // Return NO if picker so that there won't be a cursor in the box
    return ret;
}

#pragma mark AudioPlayerDelegate
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [playButton setBackgroundImage:[UIImage imageNamed:@"play-80.png"] forState:UIControlStateNormal];
    playStatus = Stopped;
    [recordButton setEnabled:YES];
    [self updateProgress];
}

- (void)updateProgress
{
    float timeLeft = player.duration - player.currentTime;
    if (playStatus == Recording) {
        timeLeft = recorder.currentTime;
    }
    recordLengthTxt.text = [NSString stringWithFormat:@"%2.2f\'\'",timeLeft ];
}

-(void)startPlay {
    playStatus = Playing;
    [playButton setBackgroundImage:[UIImage imageNamed:@"stop-80.png"] forState:UIControlStateNormal];
    [recordButton setEnabled:NO];
    [playButton setEnabled:YES];
    audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}

-(void)stopPlay:(PlayStatus)status {
    playStatus = status;
    [playButton setBackgroundImage:[UIImage imageNamed:@"pause-80.png"] forState:UIControlStateNormal];
    [recordButton setEnabled:YES];
    [audioTimer invalidate];
}

#pragma mark IBActions
- (IBAction)backToParentClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)recordClicked:(id)sender {
    recordButton.selected ^= YES;
    if (player.playing) {
        [player stop];
    }
    if (recordButton.selected) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        // Start recording
        [recorder record];
        [playButton setEnabled:NO];
        [playButton setBackgroundImage:[UIImage imageNamed:@"play-80.png"] forState:UIControlStateNormal];
        playStatus = Recording;
        audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    } else {
        [recorder stop];
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        //Initiate the player
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [playButton setEnabled:YES];
        playStatus = Stopped;
        [audioTimer invalidate];
    }
}

- (IBAction)playClicked:(id)sender {
    if (!recorder.recording) {
        switch (playStatus) {
            case Playing:
                [player pause];
                [self stopPlay:Paused];
                break;
            case Paused:
            case Stopped:
                [player play];
                [self startPlay];
                break;
            default:
                break;
        }
    }
}
- (IBAction)saveClicked:(id)sender {
    [self saveTask];
}
- (IBAction)cancelClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)deleteClicked:(id)sender {
}
@end
