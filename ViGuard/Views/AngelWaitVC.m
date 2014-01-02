//
//  AngelWaitVC.m
//  ViGuard
//
//  Created by Ronen Shraga on 1/2/14.
//  Copyright (c) 2014 Vitalitix. All rights reserved.
//

#import "AngelWaitVC.h"
#import "ElderStatusVC.h"
#import "HelpAssistVC.h"

@interface AngelWaitVC ()

@property NSNumber *elderId;
@property NSNumber *elderPanicId;
@property NSString *angelStatus;
@property NSString *guardianToken;

@end

@implementation AngelWaitVC

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

-(void)setData:(NSString*)token elder_id:(NSNumber*)elder_id panic_id:(NSNumber*)panic_id status:(NSString*)status {
    _guardianToken = token;
    _elderId = elder_id;
    _angelStatus = status;
    _elderPanicId= panic_id;
}

//Pass parameters to children view controllers
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"fromAngelWaitToHelpAssist"])
    {
        HelpAssistVC *hvc = [segue destinationViewController];
        [hvc setData:_guardianToken elder_id:_elderId panic_id:_elderPanicId status:_angelStatus];
    }
}

-(UIViewController*)getViewControler:(Class)class {
    UIViewController *vc = nil;
    UINavigationController *navigationController = (UINavigationController *)self.view.window.rootViewController;
    if (navigationController.viewControllers)
        //look for the nav controller in tab bar views
        for (UINavigationController *view in navigationController.viewControllers) {
            if ([view isKindOfClass:class])
                vc = view;
        }
    return vc;
}

#pragma mark IBActions

- (IBAction)toElderStatusBtn:(id)sender {
    ElderStatusVC *evc = (ElderStatusVC*)[self getViewControler:[ElderStatusVC class]];
    [self.navigationController popToViewController:evc animated:YES];
}
@end
