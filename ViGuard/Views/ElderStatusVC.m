//
//  ElderStatusVC.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/19/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ElderStatusVC.h"
#import "DataUtils.h"
#import "HttpService.h"
#import "ElderMapVC.h"
#import "AngelsMapVC.h"

@interface ElderStatusVC ()

@end

@implementation ElderStatusVC

@synthesize elderNameLbl;
@synthesize elderImage;
@synthesize elderStatusBtn;
@synthesize elderAddressLbl;
@synthesize elderLastStatTmLbl;
@synthesize tasksLbl;
@synthesize taskTimeLbl;
@synthesize angelsStatusLbl;
@synthesize angelsProximityLbl;

UserData *userData;

//Status variables
NSNumber *elderLat;
NSNumber *elderLon;
NSNumber *angelCount;
NSNumber *angelProximity;
NSString *scheduleType;
NSDate *scheduleStartDate;
NSString *scheduleComments;


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
    
    CALayer * l = [elderImage layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:20.0];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getElderStatus];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"fromElderStatusToElderMap"])
    {
        // Get reference to the destination view controller
        ElderMapVC *evc = [segue destinationViewController];
        // Pass any objects to the view controller here, like...
        [evc setAddress:elderAddressLbl.text token:userData.guardianToken];
    } else if ([[segue identifier] isEqualToString:@"fromElderStatusToAngelsMap"]) {
        // Get reference to the destination view controller
        AngelsMapVC *avc = [segue destinationViewController];
        // Pass any objects to the view controller here, like...
        [avc setElderDetails:elderNameLbl.text lat:[elderLat doubleValue] lon:[elderLon doubleValue]];
    }
}

-(void)getElderStatus {
    NSMutableDictionary *mapData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:userData.guardianToken,    @"token", nil];
    HttpService *httpService = [[HttpService alloc] init];
    [httpService postJsonRequest:@"get_elder_status" postDict:mapData callbackOK:^(NSDictionary *jsonDict) {
        userData.elderEmail         = [jsonDict objectForKey:@"email"];
        userData.elderMobilePhone   = [jsonDict objectForKey:@"phone"];
        userData.elderFirstName     = [jsonDict objectForKey:@"first_name"];
        userData.elderLastName      = [jsonDict objectForKey:@"last_name"];
        userData.elderGender        = [jsonDict objectForKey:@"gender"];
        userData.elderDateOfBirth   = [DataUtils dateFromStr:[jsonDict objectForKey:@"dob"]];
        userData.elderHomeAddress   = [jsonDict objectForKey:@"address"];
        userData.elderUpdateTime    = [DataUtils dateFromMilliSecondStr:[jsonDict objectForKey:@"update_time"]];
        
        elderLat                    = [jsonDict objectForKey:@"lat"];
        elderLon                    = [jsonDict objectForKey:@"lon"];
        angelCount                  = [jsonDict objectForKey:@"angel_count"];
        angelProximity              = [jsonDict objectForKey:@"shortest_distance"];
        scheduleType                = [jsonDict objectForKey:@"schedule_type"];
        scheduleStartDate           = [DataUtils dateFromMilliSecondStr:[jsonDict objectForKey:@"schedule_start_date"]];
        scheduleComments            = [jsonDict objectForKey:@"schedule_comments"];
        NSDate *elderImageUpdated   = [DataUtils dateFromMilliSecondStr:[jsonDict objectForKey:@"elder_image_updated"]];
        if ([userData.elderImageUpdated compare:elderImageUpdated] != NSOrderedSame) {
            NSMutableDictionary *reqData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                     userData.guardianToken,@"token",
                                     @"elder",              @"image_type", nil];
            HttpService *httpImgService = [[HttpService alloc] init];
            [httpImgService postDataRequest:@"get_image" postDict:reqData callbackOK:^(NSString *imgStr) {
                userData.elderImage = imgStr;
                userData.elderImageUpdated = elderImageUpdated;
                [[NSOperationQueue mainQueue] addOperationWithBlock:^
                 {
                     [DataUtils saveAllData];
                     [self displayElderStatus];
                 }];
            } callbackErr:^(NSString *imgErrStr) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^
                 {
                     [[[UIAlertView alloc] initWithTitle:@"Get Elder Status" message:imgErrStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                 }];
            }];
        } else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^
             {
                 [DataUtils saveAllData];
                 [self displayElderStatus];
             }];
        }
    } callbackErr:^(NSString* errStr) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             [[[UIAlertView alloc] initWithTitle:@"Get Elder Status" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
         }];
    }];
}

-(void)displayElderStatus {
    elderNameLbl.text       = [[userData.elderFirstName stringByAppendingString:@", "] stringByAppendingString:userData.elderLastName];
    if (userData.elderImage) {
        elderImage.image        = [DataUtils fromBase64:userData.elderImage];
    }
    //elderStatusBtn          = ;
    tasksLbl.text           = scheduleComments ;
    taskTimeLbl.text        = [DataUtils strFromDate:scheduleStartDate format:@"MM-dd HH:mm"];
    angelsStatusLbl.text    = [NSString stringWithFormat:@"%@ angels are nearby", angelCount];
    angelsProximityLbl.text = [NSString stringWithFormat:@"%.1f%@",([angelProximity floatValue]>1000.0) ? [angelProximity floatValue]/1000.0:[angelProximity floatValue], ([angelProximity floatValue]>1000.0) ? @"m":@"km"];
    elderLastStatTmLbl.text =  [DataUtils strFromDate:userData.elderUpdateTime format:@"MM-dd HH:mm"];
    //Reverse geocode location
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:elderLat.doubleValue longitude:elderLon.doubleValue];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error || placemarks.count == 0) {
            NSLog(@"%@:%@", NSStringFromSelector(_cmd), error);
        } else {
            CLPlacemark *place = [placemarks objectAtIndex:0];
            NSString *addrStr = @"";
            for (NSString *str in [place.addressDictionary objectForKey:@"FormattedAddressLines"]) {
                addrStr = [[addrStr stringByAppendingString:@", "] stringByAppendingString:str];
            }
            addrStr = [addrStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "]];
            elderAddressLbl.text = addrStr;
        }
    }];

}

#pragma mark IBActions
- (IBAction)resetApplication:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hasRunBefore"];
}

- (IBAction)showElderMap:(id)sender {
}

- (IBAction)showTasks:(id)sender {
}

- (IBAction)showAngelsMap:(id)sender {
}

- (IBAction)showEventLog:(id)sender {
}

- (IBAction)callElder:(id)sender {
}

- (IBAction)listenToElder:(id)sender {
}


@end
