//
//  ActivateCaregiverVC.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/19/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import "ActivateCaregiverVC.h"
#import "HttpService.h"
#import "DataUtils.h"

@interface ActivateCaregiverVC ()

@end

@implementation ActivateCaregiverVC

@synthesize caregiverCodeTxt;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//Dismiss keyboard on tap outside the edit box
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.caregiverCodeTxt resignFirstResponder];
}

#pragma mark IBActions

- (IBAction)activateCaregiver:(id)sender {
    NSMutableDictionary *mapData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                             [DataUtils getUserData].guardianToken, @"token",
                             caregiverCodeTxt.text,                 @"guard_pass", nil];
    HttpService *httpService = [[HttpService alloc] init];
    [httpService postJsonRequest:@"assign_to_elder" postDict:mapData callbackOK:^(NSDictionary *jsonDict) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             if ([[jsonDict objectForKey:@"assigned"]  isEqual: @"true"]){
                 //Run on main thread
                 [self performSelector:@selector(performSegueWithIdentifier:sender:) withObject:@"fromActivateElderToShareContacts"];
             } else {
                 [[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Can't assign to elder" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
             }
         }];
    } callbackErr:^(NSString *errStr) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             [[[UIAlertView alloc] initWithTitle:@"Can't assign to elder" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
         }];
    }];
}

- (IBAction)activateAngel:(id)sender {
}
@end
