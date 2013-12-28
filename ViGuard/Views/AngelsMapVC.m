//
//  AngelsMapVC.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/21/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//
#import "AngelsMapVC.h"
#import "CaregiverTVC.h"
#import "DataUtils.h"
#import "HttpService.h"

@interface AngelsMapVC ()

@end

@implementation AngelsMapVC

@synthesize angelsMap;
@synthesize caregiversTV;

UserData *userData;
NSArray *caregiversArr;
NSArray *angelsArr;
NSString *elderName;
double elderLat;
double elderLon;

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
    [angelsMap setDelegate:self];
    userData = [DataUtils getUserData];
    [self getAngels];
    [self getCaregivers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setElderDetails:(NSString*)name lat:(double)lat lon:(double)lon {
    elderName = name;
    elderLat = lat;
    elderLon = lon;
}

#pragma mark http requests

-(void)getCaregivers {
    NSMutableDictionary *mapData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:userData.guardianToken, @"token", nil];
    HttpService *httpService = [[HttpService alloc] init];
    [httpService postJsonRequest:@"get_elder_guardians" postDict:mapData callbackOK:^(NSDictionary *jsonDict) {
        caregiversArr = (NSArray*)jsonDict;
        dispatch_async(dispatch_get_main_queue(), ^{
             [caregiversTV reloadData];
         });
    } callbackErr:^(NSString* errStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
             [[[UIAlertView alloc] initWithTitle:@"Get Elder Guardians" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
         });
    }];
}

-(void)getAngels {
    NSMutableDictionary *mapData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:userData.guardianToken, @"token", nil];
    HttpService *httpService = [[HttpService alloc] init];
    [httpService postJsonRequest:@"get_angel_list" postDict:mapData callbackOK:^(NSDictionary *jsonDict) {
        angelsArr = (NSArray*)jsonDict;
        dispatch_async(dispatch_get_main_queue(), ^{
             [self refreshAngelMap];
         });
    } callbackErr:^(NSString* errStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
             [[[UIAlertView alloc] initWithTitle:@"Get Angel List" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
         });
    }];
}

-(void)refreshAngelMap {
    double minLat = elderLat;
    double minLon = elderLon;
    double maxLat = elderLat;
    double maxLon = elderLon;
    //{ "lat": 32.1041901, "lon": 34.8338095, "distance": 6.0786574448036195, "time": 1384072736000 }
    //Setup elder icon
    MKPointAnnotation *elderAnn = [[MKPointAnnotation alloc]init];
    elderAnn.coordinate = CLLocationCoordinate2DMake(elderLat,elderLon);
    elderAnn.title = elderName;
    elderAnn.subtitle = @"";
    [angelsMap addAnnotation:elderAnn];
    //Setup angels icons
    if (angelsArr.count) {
        for (NSDictionary * d in angelsArr) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[d objectForKey:@"lat"] doubleValue], [[d objectForKey:@"lon"] doubleValue]);
            minLat = coord.latitude < minLat ? coord.latitude:minLat;
            minLon = coord.longitude< minLon ? coord.longitude:minLon;
            maxLat = coord.latitude > maxLat ? coord.latitude:maxLat;
            maxLon = coord.longitude> maxLon ? coord.longitude:maxLon;
            //Setup angel icon
            MKPointAnnotation *angelAnn = [[MKPointAnnotation alloc]init];
            angelAnn.coordinate = coord;
            angelAnn.title = @"Angel";
            double dist = [[d objectForKey:@"distance"] doubleValue];
            angelAnn.subtitle = [NSString stringWithFormat:@"Distance: %.1f%@, Time: %@",(dist>1000.0) ? dist/1000.0:dist, (dist>1000.0) ? @"km":@"m", [DataUtils strFromDate:[DataUtils dateFromMilliSeconds:[d objectForKey:@"time"]] format:@"dd-MM HH:mm"]];
            [angelsMap addAnnotation:angelAnn];
        }
    }
    //Set map to show all annonations
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(elderLat, elderLon);
    MKCoordinateSpan span = MKCoordinateSpanMake((maxLat-minLat)*3, (maxLon-minLon)*3);
    MKCoordinateRegion region = MKCoordinateRegionMake (center, span);
    [angelsMap setRegion:region animated:NO];
}

#pragma mark MKMapkitDelegate

-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    NSString *pinIdStr = @"pinView";
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinIdStr];
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinIdStr];
        if ([annotation.subtitle isEqualToString:@""])
            pinView.image = [UIImage imageNamed:@"logo-30.png"];
        else
            pinView.image = [UIImage imageNamed:@"angel-20.png"];
        pinView.canShowCallout = YES;
    }
    return pinView;
}

#pragma mark UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
	//int idx=indexPath.row;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return caregiversArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"caregiverCell";
    
    CaregiverTVC *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CaregiverTVC alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:CellIdentifier];
    }
    //{ "first_name": "Caregiver", "last_name": "Two", "phone": "0587792921", "email": "undefined", "address": "ggggdghgf", "gender": "Male", "age": null, "guardian_id": 29, "last_status_tm": null }
    long idx = indexPath.row;
    cell.caregiverNameLbl.text = [NSString stringWithFormat:@"%@ %@", [caregiversArr[idx] objectForKey:@"first_name"], [caregiversArr[idx] objectForKey:@"last_name"]];
    //double dist = [[caregiversArr[idx] objectForKey:@"distance"] doubleValue];
    //cell.caregiverDistanceLbl.text = [NSString stringWithFormat:@"%.1f%@",(dist>1000.0) ? dist/1000.0:dist, (dist>1000.0) ? @"km":@"m"];
    return cell;
}

#pragma mark IBActions

- (IBAction)backToParent:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
