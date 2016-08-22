//
//  RegistrationViewController.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/17/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>
#import "GuardianRegistrationVC.h"
#import "NSDataAdditions.h"
#import "DataUtils.h"
#import "HttpService.h"
#import "ElderStatusVC.h"
#import "ActionSheetPicker.h"
#import "UIAlertView+WithBlock.h"

@interface GuardianRegistrationVC ()

@property BOOL currentGender;

@end

@implementation GuardianRegistrationVC

@synthesize firstName;
@synthesize lastName;
@synthesize mobilePhone;
@synthesize email;
@synthesize address;
@synthesize dateOfBirthTxt;
@synthesize guardianImageBtn;
@synthesize registerBtn;
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

    genderTypesArr = @[@"Male",@"Female"];

    userData = [DataUtils getUserData];
    if (userData.guardianImage)
        [guardianImageBtn setImage:[DataUtils fromBase64:userData.guardianImage] forState:UIControlStateNormal];
    firstName.text = userData.guardianFirstName;
    lastName.text = userData.guardianLastName;
    mobilePhone.text = userData.guardianMobilePhone;
    email.text = userData.guardianEmail;
    address.text = userData.guardianHomeAddress;
    dateOfBirthTxt.text = [DataUtils dateStrFromDate:userData.guardianDateOfBirth];
    self.currentGender = [userData.guardianGender isEqualToString:genderTypesArr[1]] ? NO : YES;
    if (self.currentGender) {
        self.maleBtn.selected = YES;
        self.femaleBtn.selected = NO;
    } else {
        self.maleBtn.selected = NO;
        self.femaleBtn.selected = YES;
    }
    [firstName becomeFirstResponder];
    //To dismiss the keyboard on done
    firstName.delegate = self;
    lastName.delegate = self;
    mobilePhone.delegate = self;
    email.delegate = self;
    address.delegate = self;
    dateOfBirthTxt.delegate = self;
    [self shareContacts];
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
}

- (void)setUserData {//:(void (^)())callback {
    userData.guardianFirstName = self.firstName.text;
    userData.guardianLastName = self.lastName.text;
    userData.guardianMobilePhone = self.mobilePhone.text;
    userData.guardianEmail = self.email.text;
    userData.guardianHomeAddress = self.address.text;
    userData.guardianDateOfBirth = [DataUtils dateFromStr:self.dateOfBirthTxt.text format:@"yyyy-MM-dd"];
    userData.guardianGender = self.currentGender ? genderTypesArr[0] : genderTypesArr[1];
    userData.guardianImage = [[DataUtils toBase64:guardianImageBtn.imageView.image] stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    [DataUtils saveAllData];
    //callback();
}

#pragma mark UITextViewDelegate

- (void)dobWasSelected:(NSDate *)selectedDate element:(id)element {
    dateOfBirthTxt.text = [DataUtils dateStrFromDate:selectedDate];
}

- (void)initActionSheetPickerForTextField:(UITextField *)textField
{
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

}
// Delegate function
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL ret = YES;
    // We are now showing the UIPickerViewer instead
    if ([textField isEqual:self.dateOfBirthTxt]) {
        [self initActionSheetPickerForTextField:textField];
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

-(void)loadPhoneBook:(ABAddressBookRef) addressBookRef {
    //Get the address book
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    CFIndex allPeopleCount = CFArrayGetCount(allPeople);
    NSMutableArray *phoneBook = [[NSMutableArray alloc] init];
    for (CFIndex i=0;i<allPeopleCount;i++) {
        ABRecordRef record = CFArrayGetValueAtIndex(allPeople,i);
        NSString *name = (__bridge NSString*)ABRecordCopyValue(record, kABPersonFirstNameProperty);
        if(name.length>0)
            name = [name stringByAppendingString:@" "];
        NSString *lName = (__bridge NSString*)ABRecordCopyValue(record, kABPersonLastNameProperty);
        if([lName length]>0)
        {
            if([name length]>0)
                name = [name stringByAppendingString:lName];
            else
                name = (__bridge NSString*)ABRecordCopyValue(record, kABPersonLastNameProperty);
        }
        if([name length]==0)
            name = @"noName";
        //get Phone Numbers
        ABMultiValueRef multiPhones = ABRecordCopyValue(record, kABPersonPhoneProperty);
        for(CFIndex j=0;j<ABMultiValueGetCount(multiPhones);j++) {
            CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, j);
            NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
            CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(multiPhones, j);
            NSString *phoneLabel =(__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
            //[phoneBook setObject:phoneNumber forKey:[NSString stringWithFormat:@"%@ (phone,%@)", name, phoneLabel]];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setValue:[NSString stringWithFormat:@"%@ (phone,%@,%ld)", name, phoneLabel, j] forKey:@"name"];
            [dict setValue:phoneNumber forKey:@"phone"];
            [phoneBook addObject:dict];
        }
        //get Contact email
        ABMultiValueRef multiEmails = ABRecordCopyValue(record, kABPersonEmailProperty);
        for (CFIndex k=0; k<ABMultiValueGetCount(multiEmails); k++) {
            CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, k);
            NSString *contactEmail = (__bridge NSString *)contactEmailRef;
            CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(multiEmails, k);
            NSString *emailLabel =(__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
            //[phoneBook setObject:contactEmail forKey:[NSString stringWithFormat:@"%@ (email,%@)", name, emailLabel]];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setValue:[NSString stringWithFormat:@"%@ (email,%@,%ld)", name, emailLabel, k] forKey:@"name"];
            [dict setValue:contactEmail forKey:@"phone"];
            [phoneBook addObject:dict];
        }
    }
    //Send it to the database
    if (phoneBook.count > 0) {
        NSMutableDictionary *mapData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [DataUtils getUserData].guardianToken, @"token",
                                        phoneBook,@"book",nil];
        HttpService *httpService = [[HttpService alloc] init];
        [httpService postJsonRequest:@"load_address_book" postDict:mapData callbackOK:^(NSDictionary *jsonDict) {
        } callbackErr:^(NSString* errStr) {
            //dispatch_async(dispatch_get_main_queue(), ^{
            //    [[[UIAlertView alloc] initWithTitle:@"Load address book" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            //});
        }];
    }
}

- (void)shareContacts {
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAuthorizationStatus authorizationStatus = ABAddressBookGetAuthorizationStatus();
    if (authorizationStatus == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error)     {
            if (granted) {
                [self loadPhoneBook:addressBookRef];
            } else {
                // User denied access
                // Display an alert telling user the contact could not be added
            }
        });
    } else if (authorizationStatus == kABAuthorizationStatusAuthorized) {
        [self loadPhoneBook:addressBookRef];
    }
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
    [guardianImageBtn setImage:info[UIImagePickerControllerEditedImage] forState:UIControlStateNormal];
    guardianImageChanged = true;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)maleGender:(UIButton *)sender {
    sender.selected = YES;
    self.femaleBtn.selected = NO;
    self.currentGender = YES;
}


- (IBAction)femaleGender:(UIButton *)sender {
    sender.selected = YES;
    self.maleBtn.selected = NO;
    self.currentGender = NO;
}

- (IBAction)calendClick:(id)sender {
    [self initActionSheetPickerForTextField:self.dateOfBirthTxt];
}

@end
