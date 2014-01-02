//
//  AngelRequestVC.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/30/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import "AngelRequestVC.h"
#import "UIAlertView+WithBlock.h"
#import "HttpService.h"
#import "DataUtils.h"

@interface AngelRequestVC ()

@end

@implementation AngelRequestVC

@synthesize elderDistanceLbl;
@synthesize yesBtn;
@synthesize noBtn;

double elderDistance = 0;
NSNumber *elderId;
NSNumber *elderPanicId;
NSString *angelStatus;
NSString *guardianToken;

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

    //Beautify the yes button
    [[yesBtn layer] setBorderWidth:2.0f];
    [[yesBtn layer] setBorderColor:[UIColor colorWithRed:66.0/255 green:152.0/255 blue:252.0/255 alpha:1].CGColor];
    yesBtn.layer.cornerRadius = 8.0f;
    
    [[noBtn layer] setBorderWidth:2.0f];
    [[noBtn layer] setBorderColor:[UIColor redColor].CGColor];
    noBtn.layer.cornerRadius = 8.0f;
    
    guardianToken = [DataUtils getUserData].guardianToken;
    [self showData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showData {
    elderDistanceLbl.text = [NSString stringWithFormat:@"%.1f%@",(elderDistance>1000.0) ? elderDistance/1000.0:elderDistance, (elderDistance>1000.0) ? @"km":@"m"];
}

-(void)setData:(NSNumber*)distance elder_id:(NSNumber*)elder_id panic_id:(NSNumber*)panic_id status:(NSString*)status {
    elderDistance = [distance doubleValue];
    elderId = elder_id;
    angelStatus = status;
    elderPanicId= panic_id;
    if ([self isViewLoaded])
        [self showData];
}

#pragma mark HTTP

-(void)doPanicAction:(NSString*)action act_str:(NSString*)act_str panic_id:(NSNumber*)panic_id angel_id:(NSNumber*)angel_id comments:(NSString*)comments {
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"OK to %@?", act_str] message:@"" delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [[[HttpService alloc] init] postJsonRequest:@"add_panic_action" postDict:[[NSMutableDictionary alloc] initWithDictionary: @{@"token":guardianToken, @"panic_id":panic_id, @"action":action, @"angel_id":angel_id?angel_id:@0, @"comments":comments}] callbackOK:^(NSDictionary *jsonDict) {
                if ([action isEqualToString:@"willing_to_help"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self performSegueWithIdentifier:@"fromAngelRequestToAngelWait"sender:self];
                    });
                } else if ([action isEqualToString:@"cancel"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark IBActions
- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)yesClicked:(id)sender {
    if ([angelStatus isEqualToString:@"assigned"] || [angelStatus isEqualToString:@"willing"])
        [self performSegueWithIdentifier:@"fromAngelRequestToAngelWait"sender:self];
    else
        [self doPanicAction:@"willing_to_help" act_str:@"HELP" panic_id:elderPanicId angel_id:nil comments:@"willing from iPhone app"];
}

- (IBAction)noClicked:(id)sender {
    [self doPanicAction:@"cancel" act_str:@"Cancel" panic_id:elderPanicId angel_id:nil comments:@"cancel from iPhone app"];
}

@end
