//
//  AgreementVC.m
//  ViGuard
//
//  Created by Anton Rodick on 22.08.16.
//  Copyright © 2016 Vitalitix. All rights reserved.
//

#import "AgreementVC.h"
#import "GuardianRegistrationVC.h"

@interface AgreementVC ()

@end

@implementation AgreementVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"document" ofType:@"pdf"];
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)agree:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GuardianRegistrationVC *gvc = [storyboard instantiateViewControllerWithIdentifier:@"GuardianRegistrationVC"];
    [(UINavigationController*)self.navigationController pushViewController:gvc animated:NO];
}

@end
