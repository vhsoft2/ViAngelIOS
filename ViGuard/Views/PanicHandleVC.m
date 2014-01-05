//
//  PanicHandleVC.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/26/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import "PanicHandleVC.h"
#import "HttpService.h"
#import "UIAlertView+WithBlock.h"
#import "HelpListVC.h"

@interface PanicHandleVC ()

@end

@implementation PanicHandleVC

NSString *guardianToken;
NSNumber *panicId;
NSNumber *angelId;
double elderLat;
double elderLon;
NSString *elderName;
bool helpRequestSubmitted = false;

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
//
//Called from sague
//
-(void)setData:(NSString*)token panic_id:(NSNumber*)panic_id angel_id:(NSNumber*)angel_id elderName:(NSString*)name elderLat:(double)lat elderLon:(double)lon {
    guardianToken = token;
    panicId = panic_id;
    angelId = angel_id;
    elderName = name;
    elderLat = lat;
    elderLon = lon;
}

-(void)doPanicAction:(NSString*)action panic_id:(NSNumber*)panic_id angel_id:(NSNumber*)angel_id comments:(NSString*)comments {
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"OK to %@?", action] message:@"" delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [[[HttpService alloc] init] postJsonRequest:@"add_panic_action" postDict:[[NSMutableDictionary alloc] initWithDictionary: @{@"token":guardianToken, @"panic_id":panic_id, @"action":action, @"angel_id":angel_id?angel_id:@0, @"comments":comments}] callbackOK:^(NSDictionary *jsonDict) {
                if ([action isEqualToString:@"close"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                } else if ([action isEqualToString:@"ask_for_help"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self performSegueWithIdentifier:@"fromPanicHandleToHelpList" sender:self];
                    });
                }
            } callbackErr:^(NSString* errStr) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:[@"Panic action: " stringByAppendingString:action] message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                });
            }];
        }
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"fromPanicHandleToHelpList"])
    {
        HelpListVC *hvc = [segue destinationViewController];
        [hvc setData:guardianToken panicid:panicId elderName:elderName elderLat:elderLat elderLon:elderLon ];
    }
}

#pragma mark - IBActions

- (IBAction)backToElderStatusClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)askForHelpClicked:(id)sender {
    if (!helpRequestSubmitted) {
        [self doPanicAction:@"ask_for_help" panic_id:panicId angel_id:angelId comments:@"iPhone is a mess"];
        helpRequestSubmitted = YES;
    } else {
        [self performSegueWithIdentifier:@"fromPanicHandleToHelpList" sender:self];
    }
}

- (IBAction)callEmsClicked:(id)sender {
    [self doPanicAction:@"call_ems" panic_id:panicId angel_id:angelId comments:@"iPhone is a mess"];
}

- (IBAction)closeEventClicked:(id)sender {
    [self doPanicAction:@"close" panic_id:panicId angel_id:angelId comments:@"iPhone is a mess"];
}

@end
