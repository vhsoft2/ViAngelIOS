//
//  VerifyCodeVC.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/19/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import "VerifyCodeVC.h"

@interface VerifyCodeVC ()

@end

@implementation VerifyCodeVC

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
   /* NSString *vitalitixServerUrl = @"http://109.226.62.3/sign_up";
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:vitalitixServerUrl]
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (error) {
                    NSLog(@"%@:%@", NSStringFromSelector(_cmd), error.domain);
                } else {
                    
                }
            }] resume];
    */
    NSError *error;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURL *url = [NSURL URLWithString:@"http://109.226.62.3/sign_up"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPMethod:@"POST"];
    NSDictionary *mapData = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @"David",              @"first_name",
                             @"Stern",              @"last_name",
                             @"dstern@calc.com",    @"email",
                             @"0503334444",         @"phone",
                             @"19922 Half Moon",    @"address",
                             @"Male",               @"gender",
                             @"1955-04-25",         @"dob", nil];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&error];
    [request setHTTPBody:postData];
    
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

        NSLog(@"%@:\n%@\n%@\n%@", NSStringFromSelector(_cmd), response, error,jsonArray);
    }];
    
    [postDataTask resume];
    
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
