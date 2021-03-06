//
//  ElderStatusVC.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/19/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import "ElderStatusVC.h"
#import "DataUtils.h"
#import "HttpService.h"
#import "ElderMapVC.h"
#import "AngelsMapVC.h"
//#import "PanicHandleVC.h"
#import "UIAlertView+WithBlock.h"
//#import "ActivateCaregiverVC.h"

//#import "CallActionVC.h"

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
@synthesize listenBtn;
@synthesize versionLbl;

UserData *userData;

//Status variables
double elderLat;
double elderLon;
int angelCount;
double angelProximity;
NSString *scheduleType;
NSDate *scheduleStartDate;
NSString *scheduleComments;
NSNumber *listenEnabled;
NSNumber *panicId;

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
   // self.screenName = @"Elder Status";
    
    userData = [DataUtils getUserData];
    //Show the version
    versionLbl.text = [NSString stringWithFormat:@"V(%@) B(%@)", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    //Make elder image round
    CALayer *btnLayer = [elderBtn layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:elderBtn.frame.size.width/2.0f];
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
//
//
//
-(void)panicStatusChanged:(NSNumber*)panic_id panic_status:(NSString*)pnic_status battery_status:(NSString*)battery_status comm_status:(NSString*)comm_status {
    panicId = panic_id;
    if (![panic_id isKindOfClass:[NSNull class]] && panic_id > 0) {
        elderStatusBtn.enabled = YES;
        [elderStatusBtn setBackgroundImage:[UIImage imageNamed:@"status-panic.png"] forState:UIControlStateNormal];
    } else {
        elderStatusBtn.enabled = NO;
        [elderStatusBtn setBackgroundImage:[UIImage imageNamed:[battery_status isEqualToString:@"OK"] && [comm_status isEqualToString:@"OK"]?@"status-ok.png":@"status-warning.png"] forState:UIControlStateNormal];
    }
}

//Pass parameters to children view controllers
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"fromElderStatusToElderMap"]) {
        ElderMapVC *evc = [segue destinationViewController];
        [evc setAddress:elderAddressLbl.text token:userData.guardianToken];
    } else if ([[segue identifier] isEqualToString:@"fromElderStatusToPanicHandle"]) {
//        PanicHandleVC *pvc = [segue destinationViewController];
//        pvc.userData = userData;
//        [pvc setData:userData.guardianToken panic_id:panicId angel_id:nil elderName:elderNameLbl.text elderLat:elderLat elderLon:elderLon];
    } else if ([segue.identifier isEqualToString:@"CallScreenSegue"]) {
       // CallActionVC *callVC = segue.destinationViewController;
       // callVC.userData = userData;
    }
}
//
//HTTP stuff
//
-(void)getElderStatus {
    NSMutableDictionary *mapData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:userData.guardianToken,    @"token", nil];
    HttpService *httpService = [[HttpService alloc] init];
    [httpService postJsonRequest:@"get_elder_status" postDict:mapData callbackOK:^(NSDictionary *jsonDict) {
        //Set user data
        
        
        if ([[jsonDict objectForKey:@"community_phone"] isKindOfClass:[NSNull class]]) {
            userData.communityPhone = @"";
        } else {
            userData.communityPhone    =  [jsonDict objectForKey:@"community_phone"];
        }
        
        userData.elderEmail         = [jsonDict objectForKey:@"email"];
        userData.elderMobilePhone   = [jsonDict objectForKey:@"phone"];
        userData.elderFirstName     = [jsonDict objectForKey:@"first_name"];
        userData.elderLastName      = [jsonDict objectForKey:@"last_name"];
        userData.elderGender        = [[jsonDict objectForKey:@"gender"] isKindOfClass:NSString.class] ? [jsonDict objectForKey:@"gender"] : @"Female";
        userData.elderDateOfBirth   = [DataUtils dateFromStr:[jsonDict objectForKey:@"dob"]];
        userData.elderHomeAddress   = [jsonDict objectForKey:@"address"];
        userData.elderUpdateTime    = [DataUtils dateFromMilliSeconds:[jsonDict objectForKey:@"update_time"]];
        //Set local variables
        elderLat                    = [[jsonDict objectForKey:@"lat"] doubleValue];
        elderLon                    = [[jsonDict objectForKey:@"lon"] doubleValue];;
        angelCount                  = [[jsonDict objectForKey:@"angel_count"]isKindOfClass:NSNumber.class ] ? [[jsonDict objectForKey:@"angel_count"] intValue] : 0;
        angelProximity              = [[jsonDict objectForKey:@"shortest_distance"] isKindOfClass:NSNumber.class] ? [[jsonDict objectForKey:@"shortest_distance"] floatValue] : -1;
        scheduleType                = [jsonDict objectForKey:@"schedule_type"];
        scheduleStartDate           = [DataUtils dateFromMilliSeconds:[jsonDict objectForKey:@"schedule_start_date"]];
        scheduleComments            = [jsonDict objectForKey:@"schedule_comments"];
        listenEnabled               = [jsonDict objectForKey:@"listen"];
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
                //dispatch_async(dispatch_get_main_queue(), ^{
                //     [[[UIAlertView alloc] initWithTitle:@"Get Elder Status" message:imgErrStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                 //});
            }];
        } else {
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [DataUtils saveAllData];
            [self displayElderStatus];
        });
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
    tasksLbl.text           = [scheduleComments isKindOfClass:[NSString class]] ? scheduleComments:NSLocalizedString(@"Reminders", nil);
    taskTimeLbl.text        = [DataUtils strFromDate:scheduleStartDate format:@"HH:mm"];
    angelsStatusLbl.text    = NSLocalizedString(@"Relatives", nil);
    if (angelProximity>=0)
        angelsProximityLbl.text = [NSString stringWithFormat:@"%.1f%@",(angelProximity>1000.0) ? angelProximity/1000.0:angelProximity, (angelProximity>1000.0) ? @"km":@"m"];
    elderLastStatTmLbl.text =  [DataUtils strFromDate:userData.elderUpdateTime format:@"dd-MM HH:mm"];
    listenBtn.enabled = ![listenEnabled isKindOfClass:[NSNull class]] && [listenEnabled isEqualToNumber:@1];
    //Reverse geocode location
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:elderLat longitude:elderLon];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error || placemarks.count == 0) {
            NSLog(@"%@:%@", NSStringFromSelector(_cmd), error);
        } else {
            CLPlacemark *place = [placemarks firstObject];
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
    [[[UIAlertView alloc] initWithTitle:@"Rest Application Data" message:@"This action will reset your application, you will need to re-enter your details! Are you Sure?" delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex==1) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setBool:NO forKey:@"hasRunBefore"];
            [prefs synchronize];
            [self.navigationController popViewControllerAnimated:YES];
            exit(0);
        }
    }];
    //[self panicStatusChanged:@2 panic_status:@"new" battery_status:@"OK" comm_status:@"OK"];
}

- (IBAction)elderConfig:(id)sender {
    [self performSegueWithIdentifier:@"fromElderStatusToElderConfiguration" sender:self];
}

- (IBAction)elderStatusClicked:(id)sender {
    [self performSegueWithIdentifier:@"fromElderStatusToPanicHandle" sender:self];
}




@end
