//
//  HelpAssistVC.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/30/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import "HelpAssistVC.h"
#import "DataUtils.h"
#import "HttpService.h"
#import "LocationSingleton.h"
#import "UIAlertView+WithBlock.h"
#import "ElderStatusVC.h"

@interface HelpAssistVC ()

@property NSNumber *elderId;
@property NSNumber *elderPanicId;
@property NSString *angelStatus;
@property NSString *guardianToken;
@property NSString *elderAddress;
@property NSString *elderName;
@property NSString *elderPhone;
@property double elderLat;
@property double elderLon;

@end

@implementation HelpAssistVC

@synthesize elderCurrentAddrBtn;
@synthesize elderHomeAddrBtn;
@synthesize elderImg;
@synthesize elderNameLbl;
@synthesize elderPhoneBtn;
@synthesize helpMap;

MKPointAnnotation *elderAnn;
MKPointAnnotation *angelAnn;

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
    
    elderImg.layer.cornerRadius = 20.0f;
    elderImg.layer.masksToBounds = YES;
    
    [self showData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showData {
    [elderHomeAddrBtn setTitle:_elderAddress forState:UIControlStateNormal];
    elderNameLbl.text = _elderName;
    [elderPhoneBtn setTitle:_elderPhone forState:UIControlStateNormal];
    [self refreshMap];
    //Reverse geocode location
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:_elderLat longitude:_elderLon];
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
            [elderCurrentAddrBtn setTitle:addrStr forState:UIControlStateNormal];
            double distance = [loc distanceFromLocation:[LocationSingleton sharedSingleton].locationManager.location];
            _distanceLbl.text = [NSString stringWithFormat:@"%.1f%@",(distance>1000.0) ? distance/1000.0:distance, (distance>1000.0) ? @"km":@"m"];
        }
    }];
}

-(void)setData:(NSString*)token elder_id:(NSNumber*)elder_id panic_id:(NSNumber*)panic_id status:(NSString*)status {
    _guardianToken = token;
    _elderId = elder_id;
    _angelStatus = status;
    _elderPanicId= panic_id;
    [self getHelpData];
    [self getElderImage];
}

-(void)refreshMap {
    double minLat = _elderLat;
    double minLon = _elderLon;
    double maxLat = _elderLat;
    double maxLon = _elderLon;
    CLLocationCoordinate2D coord = [LocationSingleton sharedSingleton].locationManager.location.coordinate;
    minLat = coord.latitude < minLat ? coord.latitude:minLat;
    minLon = coord.longitude< minLon ? coord.longitude:minLon;
    maxLat = coord.latitude > maxLat ? coord.latitude:maxLat;
    maxLon = coord.longitude> maxLon ? coord.longitude:maxLon;
    [helpMap removeAnnotation:angelAnn];
    [helpMap removeAnnotation:elderAnn];
    //Setup elder icon
    elderAnn = [[MKPointAnnotation alloc]init];
    elderAnn.coordinate = CLLocationCoordinate2DMake(_elderLat,_elderLon);
    elderAnn.title = _elderName;
    [helpMap addAnnotation:elderAnn];
    //Setup self icon
    angelAnn = [[MKPointAnnotation alloc]init];
    angelAnn.coordinate = coord;
    angelAnn.title = @"Me";
    [helpMap addAnnotation:angelAnn];
    //Set map to show all annonations
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(_elderLat, _elderLon);
    MKCoordinateSpan span = MKCoordinateSpanMake((maxLat-minLat)*3, (maxLon-minLon)*3);
    MKCoordinateRegion region = MKCoordinateRegionMake (center, span);
    [helpMap setRegion:region animated:NO];
}

#pragma mark MKMapkitDelegate

-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    NSString *pinIdStr = @"pinView";
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinIdStr];
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinIdStr];
        if (![annotation.title isEqualToString:@"Me"])
            pinView.image = [UIImage imageNamed:@"logo-30.png"];
        else
            pinView.image = [UIImage imageNamed:@"angel-20.png"];
        pinView.canShowCallout = YES;
    }
    return pinView;
}


#pragma mark HTTP Request

-(void)getHelpData {
    //[ { "name": "Stenley, Yelnets", "phone": "0586055422", "address": "some home location", "lat": 32.57908248901367, "lon": 35.3979377746582 } ]
    [[[HttpService alloc] init] postJsonRequest:@"get_help_data" postDict:[[NSMutableDictionary alloc] initWithDictionary: @{@"token":_guardianToken, @"elder_id":_elderId}] callbackOK:^(NSDictionary* jsonDict) {
        NSDictionary *helpDict = [(NSArray*)jsonDict firstObject];
        if (helpDict) {
            _elderAddress = [helpDict objectForKey:@"address"];
            _elderName = [helpDict objectForKey:@"name"];
            _elderLat = [[helpDict objectForKey:@"lat"] doubleValue];
            _elderLon = [[helpDict objectForKey:@"lon"] doubleValue];
            _elderPhone = [helpDict objectForKey:@"phone"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showData];
            });
        }
    } callbackErr:^(NSString * errStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Help Data" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        });
    }];
}

-(void)getElderImage {
    [[[HttpService alloc] init] postDataRequest:@"get_image" postDict:[[NSMutableDictionary alloc] initWithDictionary:@{@"token": _guardianToken, @"image_type":@"other_elder", @"other_id":_elderId}] callbackOK:^(NSString *imageStr) {
        if (imageStr) {
            dispatch_async(dispatch_get_main_queue(), ^{
                elderImg.image = [DataUtils fromBase64:imageStr];
            });
        }
    } callbackErr:^(NSString * errStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Get Elder Image" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        });
    }];
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
- (IBAction)backToElderStatusClicked:(id)sender {
    ElderStatusVC *evc = (ElderStatusVC*)[self getViewControler:[ElderStatusVC class]];
    [self.navigationController popToViewController:evc animated:YES];
}

- (IBAction)elderPhoneClicked:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"OK to Call?" message:@"" delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [[[HttpService alloc] init] postJsonRequest:@"add_update_elder_task" postDict:[[NSMutableDictionary alloc] initWithDictionary:@{@"token":_guardianToken,@"schedule_type":@"conf",@"to":@"both",@"title":@"App call"}] callbackOK:^(NSDictionary *jsonDict) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Call request accepted" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                });
            } callbackErr:^(NSString* errStr) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Call Elder" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                });
            }];
        }
    }];

}

- (IBAction)elderHomeAddrClicked:(id)sender {
}

- (IBAction)elderCurrentAddrClicked:(id)sender {
    [helpMap selectAnnotation:elderAnn animated:YES];
}

@end
