//
//  ElderMapVC.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/20/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//
#import <MapKit/MapKit.h>
#import "ElderMapVC.h"
#import "HttpService.h"
//#import "DataUtils.h"

@interface ElderMapVC ()

@end

@implementation ElderMapVC

@synthesize elderMapView;
@synthesize addressTxt;

//UserData *userData;
NSString *elderAddress;
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
	// Do any additional setup after loading the view.
//    userData = [DataUtils getUserData];
    [self getElderRoute];
    elderMapView.delegate = self;
    addressTxt.text = elderAddress;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setAddress:(NSString*)address token:(NSString*)token {
    elderAddress = address;
    guardianToken = token;
}


-(void)getElderRoute {
    NSMutableDictionary *mapData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                             guardianToken, @"token",
                             @0,@"time",nil];
    HttpService *httpService = [[HttpService alloc] init];
    [httpService postJsonRequest:@"get_elder_route" postDict:mapData callbackOK:^(NSDictionary *jsonDict) {
        NSLog(@"%@:Number of positions:%d", NSStringFromSelector(_cmd), jsonDict.count);
        [self showRoute:jsonDict];
    } callbackErr:^(NSString* errStr) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             [[[UIAlertView alloc] initWithTitle:@"Get Elder Route" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
         }];
    }];
}

-(void)showRoute:(NSDictionary*)dict {
    //make the line
    if (dict.count) {
        //Setup polyline
        CLLocationCoordinate2D coord[dict.count];
        int i = 0;
        for (NSDictionary * d in dict) {
            coord[i++] = CLLocationCoordinate2DMake([[d objectForKey:@"lat"] floatValue], [[d objectForKey:@"lon"] floatValue]);
        }
        MKPolyline *routeLine = [MKPolyline polylineWithCoordinates:coord count:dict.count];
        //Setup icon
        MKPointAnnotation *toAdd = [[MKPointAnnotation alloc]init];
        toAdd.coordinate = coord[dict.count-1];
        toAdd.subtitle = @"Last Location";
        toAdd.title = @"Elder";
        //Put it on the map
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             [elderMapView addOverlay:routeLine];
             //Set map to show route
             [elderMapView setVisibleMapRect:[routeLine boundingMapRect] edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:NO];
             //Add last location icon
             [elderMapView addAnnotation:toAdd];
         }];
    }
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pinView"];
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinView"];
        pinView.image = [UIImage imageNamed:@"logo-30.png"];
        pinView.canShowCallout = YES;
    }
    return pinView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineView *mapOverlayView = [[MKPolylineView alloc] initWithPolyline:overlay];
        mapOverlayView.strokeColor = [UIColor blueColor];
        mapOverlayView.lineWidth = 4;
        return mapOverlayView;
    } else
        return nil;
}

#pragma mark IBActions

- (IBAction)elderStatus:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
