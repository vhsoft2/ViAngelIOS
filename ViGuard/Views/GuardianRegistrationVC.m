//
//  RegistrationViewController.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/17/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import "GuardianRegistrationVC.h"
#import "NSDataAdditions.h"
#import "DataUtils.h"
#import "HttpService.h"
#import "ElderStatusVC.h"
#import "ActionSheetPicker.h"
#import "UIAlertView+WithBlock.h"

@interface GuardianRegistrationVC ()

@end

@implementation GuardianRegistrationVC

@synthesize firstName;
@synthesize lastName;
@synthesize mobilePhone;
@synthesize email;
@synthesize address;
@synthesize dateOfBirthTxt;
@synthesize genderTxt;
@synthesize guardianImageBtn;
@synthesize registerBtn;
@synthesize backBtn;
//picker properties
@synthesize picekerSelectedIndex;
@synthesize actionSheetPicker;
NSArray *genderTypesArr;

UserData *userData;
bool guardianImageChanged = false;
bool firstTime = true;

//This is needed to allow dismiss of the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.screenName = @"Guardian Registration";
    
    genderTypesArr = @[@"Male",@"Female"];
    
    NSInteger count = [self.navigationController.viewControllers count];
    UIViewController *callingVC = [self.navigationController.viewControllers objectAtIndex:count - 2];
    if ( [callingVC isKindOfClass: [ElderStatusVC class]] ) {
        firstTime = false;
        [registerBtn setTitle:@"Save" forState:UIControlStateNormal];
        [backBtn setImage: [UIImage imageNamed:@"back-30.png"]];
    }
    userData = [DataUtils getUserData];
    if (userData.guardianImage)
        guardianImageBtn.imageView.image = [DataUtils fromBase64:userData.guardianImage];
    firstName.text = userData.guardianFirstName;
    lastName.text = userData.guardianLastName;
    mobilePhone.text = userData.guardianMobilePhone;
    email.text = userData.guardianEmail;
    address.text = userData.guardianHomeAddress;
    dateOfBirthTxt.text = [DataUtils dateStrFromDate:userData.guardianDateOfBirth];
    genderTxt.text = userData.guardianGender;
    [firstName becomeFirstResponder];
    //To dismiss the keyboard on done
    firstName.delegate = self;
    lastName.delegate = self;
    mobilePhone.delegate = self;
    email.delegate = self;
    address.delegate = self;
    dateOfBirthTxt.delegate = self;
    genderTxt.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.firstName resignFirstResponder];
    [self.lastName resignFirstResponder];
    [self.mobilePhone resignFirstResponder];
    [self.email resignFirstResponder];
    [self.address resignFirstResponder];
    [self.dateOfBirthTxt resignFirstResponder];
    [self.genderTxt resignFirstResponder];
}

- (void)setUserData {//:(void (^)())callback {
    userData.guardianFirstName = self.firstName.text;
    userData.guardianLastName = self.lastName.text;
    userData.guardianMobilePhone = self.mobilePhone.text;
    userData.guardianEmail = self.email.text;
    userData.guardianHomeAddress = self.address.text;
    userData.guardianDateOfBirth = [DataUtils dateFromStr:self.dateOfBirthTxt.text format:@"yyyy-MM-dd"];
    userData.guardianGender = self.genderTxt.text;
    userData.guardianImage = [[DataUtils toBase64:guardianImageBtn.imageView.image] stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    [DataUtils saveAllData];
    //callback();
}

#pragma mark UITextViewDelegate

- (void)dobWasSelected:(NSDate *)selectedDate element:(id)element {
    dateOfBirthTxt.text = [DataUtils dateStrFromDate:selectedDate];
}

- (void)genderWasSelected:(NSNumber *)selectedIndex element:(id)element {
    genderTxt.text = genderTypesArr[[selectedIndex intValue]];
}

// Delegate function
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL ret = YES;
    // We are now showing the UIPickerViewer instead
    if ([textField isEqual:self.genderTxt]) {
        [ActionSheetStringPicker showPickerWithTitle:@"Select Gender" rows:genderTypesArr initialSelection:picekerSelectedIndex target:self successAction:@selector(genderWasSelected:element:) cancelAction:nil origin:textField];
        ret = NO;
    } else if ([textField isEqual:self.dateOfBirthTxt]) {
        NSDate *date;
        if (![dateOfBirthTxt.text isEqualToString:@""]) {
            date = [DataUtils dateFromStr:dateOfBirthTxt.text format:@"yyyy-MM-dd"];
        }
        if (!date)
            date = [DataUtils dateFromStr:@"1990" format:@"yyyy"];
        actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Date Of Birth" datePickerMode:UIDatePickerModeDate selectedDate:date target:self action:@selector(dobWasSelected:element:) origin:textField];
        [self.actionSheetPicker addCustomButtonWithTitle:@"1950" value:[DataUtils dateFromStr:@"1950" format:@"yyyy"]];
        [self.actionSheetPicker addCustomButtonWithTitle:@"1970" value:[DataUtils dateFromStr:@"1970" format:@"yyyy"]];
        [self.actionSheetPicker addCustomButtonWithTitle:@"1990" value:[DataUtils dateFromStr:@"1990" format:@"yyyy"]];
        self.actionSheetPicker.hideCancel = YES;
        [self.actionSheetPicker showActionSheetPicker];
        ret = NO;
    }
    if (ret == NO) {
        // Close the keypad if it is showing
        [self.view.superview endEditing:YES];
    }
    // Return NO if picker so that there won't be a cursor in the box
    return ret;
}

#pragma mark IBActions
- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveGuardianDetails:(id)sender {
    //Save changes to core data
    UIViewController *selfId = self;
    [self setUserData];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    usleep(100000); //This is solving an issue with userData.elderImage beeing null
    //Save to server
    NSMutableDictionary *mapData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                    userData.guardianFirstName,   @"first_name",
                                    userData.guardianLastName,    @"last_name",
                                    userData.guardianEmail,       @"email",
                                    userData.guardianMobilePhone, @"phone",
                                    userData.guardianHomeAddress, @"address",
                                    userData.guardianGender,      @"gender",
                                    [DataUtils milliSecondsFromDate:userData.guardianDateOfBirth], @"dob", nil];
    [[[HttpService alloc] init] postJsonRequest:@"sign_up" postDict:mapData callbackOK:^(NSDictionary *jsonDict) {
        userData.guardianToken = [jsonDict objectForKey:@"token"];
        if (guardianImageChanged) {
            [[[HttpService alloc] init] postJsonRequest:@"load_image" postDict:[[NSMutableDictionary alloc] initWithDictionary:@{@"token": userData.guardianToken, @"type":@"guardian", @"image":userData.guardianImage}] callbackOK:^(NSDictionary *jsonDict2) {
                guardianImageChanged = false;
            } callbackErr:^(NSString * errStr) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Update Guardian Image" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                });
            }];
        }
        //Go to next screen
        if (firstTime) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (userData.elderCode) {
                    [selfId performSegueWithIdentifier:@"fromGuardianRegistrationToElderStatus" sender:selfId];
                } else {
                    [selfId performSegueWithIdentifier:@"fromGuardianRegistrationToVerifyCode" sender:selfId];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [selfId.navigationController popViewControllerAnimated:YES];
            });
        }
    } callbackErr:^(NSString * errStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Signup error" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            [spinner stopAnimating];
        });
    }];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIImagePickerControllerSourceType imageSourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (buttonIndex == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imageSourceType = UIImagePickerControllerSourceTypeCamera;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = imageSourceType;
    [picker setVideoQuality:UIImagePickerControllerQualityType640x480];
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)changeGuardianImage:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Choose Picture Source" message:@"" delegate:self cancelButtonTitle:@"Camera" otherButtonTitles:@"Library", nil];
    [alert show];
}

- (IBAction)caregiverHelpClicked:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"Caregiver code" message:@"This code is given to caregivers who monitor and provide assistance to a specific elder. Please contact Vitalitix if you wish to become a caregiver." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}
#pragma mark change image

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //dismiss the pick dialog
    [picker dismissViewControllerAnimated:YES completion:NULL];
    //set the image
    guardianImageBtn.imageView.image = info[UIImagePickerControllerEditedImage];
    guardianImageChanged = true;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
