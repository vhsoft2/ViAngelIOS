//
//  ElderConfigurationVC.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/20/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import "ElderConfigurationVC.h"
#import "DataUtils.h"
#import "HttpService.h"

@interface ElderConfigurationVC ()

@end

@implementation ElderConfigurationVC

@synthesize firstNameTxt;
@synthesize lastNameTxt;
@synthesize mobilePhoneTxt;
@synthesize emailTxt;
@synthesize addressTxt;
@synthesize dateOfBirthTxt;
@synthesize genderTxt;
@synthesize elderImageBtn;

//picker properties
@synthesize picekerSelectedIndex;
@synthesize actionSheetPicker;

NSArray *genderTypesArr;
UserData *userData;
bool imageChanged = false;

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

- (void)viewDidLoad
{
    [super viewDidLoad];

    genderTypesArr = @[@"Male",@"Female"];

    userData = [DataUtils getUserData];
    if (userData.elderImage)
        elderImageBtn.imageView.image = [DataUtils fromBase64:userData.elderImage];
    firstNameTxt.text = userData.elderFirstName;
    lastNameTxt.text = userData.elderLastName;
    mobilePhoneTxt.text = userData.elderMobilePhone;
    emailTxt.text = userData.elderEmail;
    addressTxt.text = userData.elderHomeAddress;
    dateOfBirthTxt.text = [DataUtils dateStrFromDate:userData.elderDateOfBirth];
    genderTxt.text = userData.elderGender;
    [firstNameTxt becomeFirstResponder];
    //To dismiss the keyboard on done
    firstNameTxt.delegate = self;
    lastNameTxt.delegate = self;
    mobilePhoneTxt.delegate = self;
    emailTxt.delegate = self;
    addressTxt.delegate = self;
    dateOfBirthTxt.delegate = self;
    genderTxt.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//Needed to allow dissmiss of the keyboard when touching outside edit box
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [firstNameTxt resignFirstResponder];
    [lastNameTxt resignFirstResponder];
    [mobilePhoneTxt resignFirstResponder];
    [emailTxt resignFirstResponder];
    [addressTxt resignFirstResponder];
    [dateOfBirthTxt resignFirstResponder];
    [genderTxt resignFirstResponder];
}

- (void)setUserData {
    userData.elderFirstName = firstNameTxt.text;
    userData.elderLastName = lastNameTxt.text;
    userData.elderMobilePhone = mobilePhoneTxt.text;
    userData.elderEmail = emailTxt.text;
    userData.elderHomeAddress = addressTxt.text;
    userData.elderDateOfBirth = [DataUtils dateFromStr:dateOfBirthTxt.text format:@"yyyy-MM-dd"];
    userData.elderGender = genderTxt.text;
    userData.elderImage = [[DataUtils toBase64:elderImageBtn.imageView.image] stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    //NSLog(@"%@:%@", NSStringFromSelector(_cmd), userData.elderImage);
    [DataUtils saveAllData];
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
            date = [DataUtils dateFromStr:@"1930" format:@"yyyy"];
        actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Date Of Birth" datePickerMode:UIDatePickerModeDate selectedDate:date target:self action:@selector(dobWasSelected:element:) origin:textField];
        [self.actionSheetPicker addCustomButtonWithTitle:@"1910" value:[DataUtils dateFromStr:@"1910" format:@"yyyy"]];
        [self.actionSheetPicker addCustomButtonWithTitle:@"1930" value:[DataUtils dateFromStr:@"1930" format:@"yyyy"]];
        [self.actionSheetPicker addCustomButtonWithTitle:@"1950" value:[DataUtils dateFromStr:@"1950" format:@"yyyy"]];
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

- (IBAction)updateElderDetails:(id)sender {
    
    //Save changes to core data
    [self setUserData];
    //Save to server
    NSMutableDictionary *mapData1 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                             userData.guardianToken,    @"token",
                             userData.elderFirstName,   @"first_name",
                             userData.elderLastName,    @"last_name",
                             userData.elderEmail,       @"email",
                             userData.elderMobilePhone, @"phone",
                             userData.elderHomeAddress, @"address",
                             userData.elderGender,      @"gender",
                             [DataUtils dateTimeStrFromDate:userData.elderDateOfBirth], @"dob", nil];
    HttpService *httpService1 = [[HttpService alloc] init];
    [httpService1 postJsonRequest:@"update_elder_details" postDict:mapData1 callbackOK:^(NSDictionary *jsonDict1) {
        if (imageChanged) {
            NSMutableDictionary *mapData2 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                      userData.guardianToken, @"token",
                                      @"elder", @"type",
                                      userData.elderImage, @"image", nil];
            HttpService *httpService2 = [[HttpService alloc] init];
            [httpService2 postJsonRequest:@"load_image" postDict:mapData2 callbackOK:^(NSDictionary *jsonDict2) {
                imageChanged = false;
                //        dispatch_async(dispatch_get_main_queue(), ^{
                 //{
                     //Go to parent screen
                     //[self.navigationController popViewControllerAnimated:YES];
                 //});
            } callbackErr:^(NSString * errStr) {
                dispatch_async(dispatch_get_main_queue(), ^{
                     [[[UIAlertView alloc] initWithTitle:@"Update Elder Image" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                 });
            }];
        } else {
            //dispatch_async(dispatch_get_main_queue(), ^{

                 //Go to parent screen
                 //[self.navigationController popViewControllerAnimated:YES];
             //});
        }
    } callbackErr:^(NSString * errStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
             [[[UIAlertView alloc] initWithTitle:@"Update Elder Detail" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
         });
    }];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backToElderStatus:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)changeElderImage:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Choose Picture Source" message:@"" delegate:self cancelButtonTitle:@"Camera" otherButtonTitles:@"Library", nil];
    [alert show];
}

#pragma mark change image

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //dismiss the pick dialog
    [picker dismissViewControllerAnimated:YES completion:NULL];
    //set the image
    elderImageBtn.imageView.image = info[UIImagePickerControllerEditedImage];
    imageChanged = true;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


@end
