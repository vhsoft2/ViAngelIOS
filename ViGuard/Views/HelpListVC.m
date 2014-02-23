//
//  HelpListVC.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/26/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import "HelpListVC.h"
#import "HelpListTVC.h"
#import "HttpService.h"
#import "OGActionChooser.h"
#import "DataUtils.h"

@interface HelpListVC ()

@end

@implementation HelpListVC

@synthesize helpListTV;
@synthesize helpMap;

//
NSMutableArray *angelsArr;
NSTimer *refreshListTimer;
NSString *guardianToken;
NSNumber *panicId = nil;
double elderLat;
double elderLon;
NSString *elderName;
NSIndexPath *previousIndex = nil;
NSMutableDictionary *helpImages = nil;

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
    self.screenName = @"Help List";
    
    previousIndex = nil;
    if (!helpImages)
        helpImages = [[NSMutableDictionary alloc] init];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [refreshListTimer invalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)timerAction:(NSTimer*)timer {
    [self getHelpList];
    refreshListTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(timerAction:) userInfo:nil repeats:NO];
}

-(void)getHelpList {
    if (panicId) {
        [[[HttpService alloc] init] postJsonRequest:@"get_help_list" postDict:[[NSMutableDictionary alloc] initWithDictionary:@{@"token":guardianToken,@"panic_id":panicId}] callbackOK:^(NSDictionary *jsonDict) {
            angelsArr = [[NSMutableArray alloc] init];//(NSArray*)jsonDict;
            NSArray *angAr = (NSArray*)jsonDict;
            for (int i=0;i<angAr.count;i++) {
                [angelsArr addObject:[[NSMutableDictionary alloc] initWithDictionary:angAr[i]]];
                NSString *si = [angelsArr[i] objectForKey:@"id"];
                if (![helpImages objectForKey:si]) {
                    NSDictionary *d = angelsArr[i];
                    NSNumber *angel_id = [d objectForKey:@"id"];
                    [[[HttpService alloc] init] postDataRequest:@"get_image" postDict:[[NSMutableDictionary alloc] initWithDictionary:@{@"token":guardianToken,@"image_type":@"other_guardian", @"other_id":angel_id}] callbackOK:^(NSString *angelImgStr) {
                        UIImage *img = [DataUtils fromBase64:angelImgStr];
                        [helpImages setValue:img forKey:si];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            previousIndex = nil;
                            [helpListTV reloadData];
                            [self refreshHelpMap];
                        });
                    } callbackErr:^(NSString *errStr) {
                        [helpImages setValue:[UIImage imageNamed:@"angel-20.png"] forKey:si];
                    }];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                previousIndex = nil;
                [helpListTV reloadData];
                [self refreshHelpMap];
            });
        } callbackErr:^(NSString* errStr) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Get Help List" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            });
        }];
    }
}

//Called from segue
-(void)setData:(NSString*)token panicid:(NSNumber*)panicid elderName:(NSString*)name elderLat:(double)lat elderLon:(double)lon {
    panicId = panicid;
    guardianToken = token;
    elderName = name;
    elderLat = lat;
    elderLon = lon;
    //Set timer to report location
    [self timerAction:nil];
}

-(void)doPanicAction:(NSString*)action panic_id:(NSNumber*)panic_id angel_id:(NSNumber*)angel_id comments:(NSString*)comments {
    [[[HttpService alloc] init] postJsonRequest:@"add_panic_action" postDict:[[NSMutableDictionary alloc] initWithDictionary: @{@"token":guardianToken, @"panic_id":panic_id, @"action":action, @"angel_id":angel_id?angel_id:@0, @"comments":comments}] callbackOK:^(NSDictionary *jsonDict) {
    } callbackErr:^(NSString* errStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:[@"Panic action: " stringByAppendingString:action] message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        });
    }];
}

#pragma mark MKMapkitDelegate

-(void)refreshHelpMap {
    double minLat = elderLat;
    double minLon = elderLon;
    double maxLat = elderLat;
    double maxLon = elderLon;
    //{ "first_name": "?", "last_name": "?", "phone": "0555555555", "gender": "Male", "distance": 74822.5434303393, "time": 1386326265000, "comments": "this is testing", "id": 42, "going": "willing" }
    //remove all annonations
    [helpMap removeAnnotations:[helpMap annotations]];
    //Setup angels icons
    for (int i=0;i<angelsArr.count;i++) {
        NSMutableDictionary *d = angelsArr[i];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[d objectForKey:@"lat"] doubleValue], [[d objectForKey:@"lon"] doubleValue]);
        minLat = coord.latitude < minLat ? coord.latitude:minLat;
        minLon = coord.longitude< minLon ? coord.longitude:minLon;
        maxLat = coord.latitude > maxLat ? coord.latitude:maxLat;
        maxLon = coord.longitude> maxLon ? coord.longitude:maxLon;
        //Setup angel icon
        MKPointAnnotation *angelAnn = [[MKPointAnnotation alloc]init];
        angelAnn.coordinate = coord;
        double dist = [[d objectForKey:@"distance"] doubleValue];
        angelAnn.title = [NSString stringWithFormat:@"%@, %@ (%.1f%@)", [d objectForKey:@"first_name"], [d objectForKey:@"last_name"],(dist>1000.0) ? dist/1000.0:dist, (dist>1000.0) ? @"km":@"m"];
        angelAnn.subtitle = [NSString stringWithFormat:@"Time: %@ Gender:%@", [DataUtils strFromDate:[DataUtils dateFromMilliSeconds:[d objectForKey:@"time"]] format:@"dd-MM HH:mm"], [d objectForKey:@"gender"]];
        [helpMap addAnnotation:angelAnn];
        [d setObject:angelAnn forKey:@"annotation"];
    }
    //Setup elder icon
    MKPointAnnotation *elderAnn = [[MKPointAnnotation alloc]init];
    elderAnn.coordinate = CLLocationCoordinate2DMake(elderLat,elderLon);
    elderAnn.title = elderName;
    elderAnn.subtitle = @"";
    [helpMap addAnnotation:elderAnn];
    //Set map to show all annonations
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(elderLat, elderLon);
    MKCoordinateSpan span = MKCoordinateSpanMake((maxLat-minLat)*3, (maxLon-minLon)*3);
    MKCoordinateRegion region = MKCoordinateRegionMake (center, span);
    [helpMap setRegion:region animated:NO];
}

-(UIImage *)imageWithRoundedCornersSize:(float)cornerRadius usingImage:(UIImage *)original
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:original];
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 1.0);
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds cornerRadius:cornerRadius] addClip];
    // Draw your image
    [original drawInRect:imageView.bounds];
    // Get the image, here setting the UIImageView image
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    return imageView.image;
}

-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    //Find the annotation
    long annIdx = -1;
    for (int i=0;i<helpMap.annotations.count;i++) {
        if (annotation==helpMap.annotations[i]) {
            annIdx = i;
            break;
        }
    }
    //Find the angel
    UIImage *angelImg = nil;
    for (int i=0;i<angelsArr.count;i++) {
        if ([angelsArr[i] objectForKey:@"annotation"] == annotation) {
            angelImg = [helpImages objectForKey:[angelsArr[i] objectForKey:@"id"]];
            break;
        }
    }
    if (annIdx >= 0) {
        NSString *pinIdStr = @"pinView";
        MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinIdStr];
        if ([annotation.subtitle isEqualToString:@""])
            pinView.image = [UIImage imageNamed:@"logo-30.png"];
        else if (annotation.subtitle.length>0) {
            if (annIdx < angelsArr.count) {
                if (angelImg) {
                    UIImage *img = [DataUtils imageWithImage:angelImg scaledToSize:CGSizeMake(30,30)];
                    pinView.image = [self imageWithRoundedCornersSize:10.0 usingImage:img];
                } else
                    pinView.image = [UIImage imageNamed:@"angel-20.png"];
            } else
                pinView.image = [UIImage imageNamed:@"angel-20.png"];
        }
        pinView.canShowCallout = YES;
        return pinView;
    } else
        return nil;
}


#pragma mark UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    //First time show annonation, Second time ask to call or help
    if (previousIndex && previousIndex.row == indexPath.row) {
        NSNumber *angelId = [angelsArr[indexPath.row] objectForKey:@"id"];
        //Call or request angel to go
        [OGActionChooser showWithTitle:@"Please choose?" buttons:@[[OGActionButton buttonWithTitle:@"Send Angel" imageName:@"send-angel-50.png" enabled:YES block:^(NSString *title, BOOL *dismiss) {
            [self doPanicAction:@"assign_angel" panic_id:panicId angel_id:angelId comments:@"Asked from iPhone app"];
            *dismiss = YES;
        }],@"",[OGActionButton buttonWithTitle:@"Call Angel" imageName:@"call-angel-50.png" enabled:YES block:^(NSString *title, BOOL *dismiss) {
            [self doPanicAction:@"call_angel" panic_id:panicId angel_id:angelId comments:@"Asked from iPhone app"];
            *dismiss = YES;
        }],@"",[OGActionButton buttonWithTitle:@"Back" imageName:nil enabled:YES block:^(NSString *title, BOOL *dismiss) {
            *dismiss = YES;
        }],@""] view:self.view];
    } else {
    }
    if (indexPath.row>=0) {
        id<MKAnnotation> annonation = [angelsArr[indexPath.row] objectForKey:@"annotation"];
        [helpMap selectAnnotation:annonation animated:YES];
    }
    previousIndex = indexPath;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return angelsArr?angelsArr.count:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{//{ "first_name": "?", "last_name": "?", "phone": "0555555555", "gender": "Male", "distance": 74822.5434303393, "time": 1386326265000, "comments": "this is testing", "id": 42, "going": "willing" }
    static NSString *CellIdentifier = @"helpListCell";
    
    HelpListTVC *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[HelpListTVC alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:CellIdentifier];
    }
    NSDictionary *angelDict = [angelsArr objectAtIndex:indexPath.row];
    //The name
    cell.angelNameLbl.text = [NSString stringWithFormat:@"%@, %@", [angelDict objectForKey:@"first_name"], [angelDict objectForKey:@"last_name"]];
    //The distance
    double angelProximity = [[angelDict objectForKey:@"distance"] doubleValue];
    cell.angelDistanceLbl.text = [NSString stringWithFormat:@"%.1f%@",(angelProximity>1000.0) ? angelProximity/1000.0:angelProximity, (angelProximity>1000.0) ? @"km":@"m"];
    //Image
    UIImage *img = [helpImages objectForKey:[angelDict objectForKey:@"id"]];
    if (img)
        cell.angelImg.image = [DataUtils imageWithImage:img scaledToSize:CGSizeMake(17,17)];
    NSString *status = [angelDict objectForKey:@"going"];
    if ([status isEqualToString:@"willing"]) {
        cell.angelStatusImg.hidden = YES;;
    } else {//if ([status isEqualToString:@"willing"])
        cell.angelStatusImg.hidden = NO;;
    }
    return cell;
}

#pragma mark - IBActions

- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
