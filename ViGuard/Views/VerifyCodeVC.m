//
//  VerifyCodeVC.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/19/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import "VerifyCodeVC.h"
#import "HttpService.h"
#import "DataUtils.h"

@interface VerifyCodeVC ()

@end

@implementation VerifyCodeVC

@synthesize codeTxt;

UserData *userData = nil;


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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.codeTxt resignFirstResponder];
}

#pragma mark IBActions

- (IBAction)activateGuardian:(id)sender {
    NSMutableDictionary *mapData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                             userData.guardianToken,    @"token",
                             codeTxt.text,              @"code", nil];
    HttpService *httpService = [[HttpService alloc] init];
    [httpService postJsonRequest:@"verify_code" postDict:mapData callbackOK:^(NSDictionary *jsonDict) {
        NSLog(@"%@", jsonDict);
        //Run on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
             [self performSelector:@selector(performSegueWithIdentifier:sender:) withObject:@"fromVerifyCodeToActivateElder"];
         });
    } callbackErr:^(NSString* errStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
             [[[UIAlertView alloc] initWithTitle:@"Activation error" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
         });
    }];
}
@end
