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
@synthesize elderBtn;
@synthesize elderStatusBtn;
@synthesize elderAddressLbl;
@synthesize elderLastStatTmLbl;
@synthesize tasksLbl;
@synthesize taskTimeLbl;
@synthesize angelsStatusLbl;
@synthesize angelsProximityLbl;

UserData *userData;

//Status variables
double elderLat;
double elderLon;
int angelCount;
double angelProximity;
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
    
    //CALayer * l = [elderBtn.imageView layer];
    //[l setMasksToBounds:YES];
    //[l setCornerRadius:20.0];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getElderStatus];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
        [avc setElderDetails:elderNameLbl.text lat:elderLat lon:elderLon];
    }
}

-(void)getElderStatus {
    NSMutableDictionary *mapData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:userData.guardianToken,    @"token", nil];
    HttpService *httpService = [[HttpService alloc] init];
    [httpService postJsonRequest:@"get_elder_status" postDict:mapData callbackOK:^(NSDictionary *jsonDict) {
        //Set user data
        userData.elderEmail         = [jsonDict objectForKey:@"email"];
        userData.elderMobilePhone   = [jsonDict objectForKey:@"phone"];
        userData.elderFirstName     = [jsonDict objectForKey:@"first_name"];
        userData.elderLastName      = [jsonDict objectForKey:@"last_name"];
        userData.elderGender        = [jsonDict objectForKey:@"gender"];
        userData.elderDateOfBirth   = [DataUtils dateFromStr:[jsonDict objectForKey:@"dob"]];
        userData.elderHomeAddress   = [jsonDict objectForKey:@"address"];
        userData.elderUpdateTime    = [DataUtils dateFromMilliSeconds:[jsonDict objectForKey:@"update_time"]];
        //Set local variables
        elderLat                    = [[jsonDict objectForKey:@"lat"] doubleValue];
        elderLon                    = [[jsonDict objectForKey:@"lon"] doubleValue];;
        angelCount                  = [[jsonDict objectForKey:@"angel_count"] intValue];
        angelProximity              = [[jsonDict objectForKey:@"shortest_distance"] floatValue];
        scheduleType                = [jsonDict objectForKey:@"schedule_type"];
        scheduleStartDate           = [DataUtils dateFromMilliSeconds:[jsonDict objectForKey:@"schedule_start_date"]];
        scheduleComments            = [jsonDict objectForKey:@"schedule_comments"];
        NSDate *elderImageUpdateTime   = [DataUtils dateFromMilliSeconds:[jsonDict objectForKey:@"elder_image_updated"]];
        if (userData.elderImageUpdated == nil || [userData.elderImageUpdated compare:elderImageUpdateTime ] != NSOrderedSame) {
            NSMutableDictionary *reqData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                     userData.guardianToken,@"token",
                                     @"elder",              @"image_type", nil];
            HttpService *httpImgService = [[HttpService alloc] init];
            [httpImgService postDataRequest:@"get_image" postDict:reqData callbackOK:^(NSString *imgStr) {
                userData.elderImage = imgStr;
                userData.elderImageUpdated = elderImageUpdateTime;
                dispatch_async(dispatch_get_main_queue(), ^{
                     [DataUtils saveAllData];
                     [self displayElderStatus];
                 });
            } callbackErr:^(NSString *imgErrStr) {
                dispatch_async(dispatch_get_main_queue(), ^{
                     [[[UIAlertView alloc] initWithTitle:@"Get Elder Status" message:imgErrStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                 });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                 [DataUtils saveAllData];
                 [self displayElderStatus];
             });
        }
    } callbackErr:^(NSString* errStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
             [[[UIAlertView alloc] initWithTitle:@"Get Elder Status" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
         });
    }];
}

-(void)displayElderStatus {
    elderNameLbl.text       = [[userData.elderFirstName stringByAppendingString:@", "] stringByAppendingString:userData.elderLastName];
    if (userData.elderImage) {
        [elderBtn setBackgroundImage:[DataUtils fromBase64:userData.elderImage] forState:UIControlStateNormal];
    }
    //elderStatusBtn          = ;
    tasksLbl.text           = scheduleComments ;
    taskTimeLbl.text        = [DataUtils strFromDate:scheduleStartDate format:@"MM-dd HH:mm"];
    angelsStatusLbl.text    = [NSString stringWithFormat:@"%d angels are nearby", angelCount];
    angelsProximityLbl.text = [NSString stringWithFormat:@"%.1f%@",(angelProximity>1000.0) ? angelProximity/1000.0:angelProximity, (angelProximity>1000.0) ? @"km":@"m"];
    elderLastStatTmLbl.text =  [DataUtils strFromDate:userData.elderUpdateTime format:@"MM-dd HH:mm"];
    //Reverse geocode location
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:elderLat longitude:elderLon];
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

- (IBAction)elderConfig:(id)sender {
    [self performSelector:@selector(performSegueWithIdentifier:sender:) withObject:@"fromElderStatusToElderConfiguration"];
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
