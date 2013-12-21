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

@interface GuardianRegistrationVC ()

@end

@implementation GuardianRegistrationVC

@synthesize firstName;
@synthesize lastName;
@synthesize mobilePhone;
@synthesize email;
@synthesize address;
@synthesize dateOfBirth;
@synthesize gender;
@synthesize guardianImageBtn;
@synthesize registerBtn;
@synthesize backBtn;

UserData *userData;
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
	// Do any additional setup after loading the view.
    
    NSInteger count = [self.navigationController.viewControllers count];
    UIViewController *callingVC = [self.navigationController.viewControllers objectAtIndex:count - 2];
    if ( [callingVC isKindOfClass: [ElderStatusVC class]] ) {
        [registerBtn setTitle:@"Back" forState:UIControlStateNormal];
        firstTime = false;
        [backBtn setImage: [UIImage imageNamed:@"back.png"]];
    }
    userData = [DataUtils getUserData];
    if (userData.guardianImage)
        guardianImageBtn.imageView.image = [DataUtils fromBase64:userData.guardianImage];
    firstName.text = userData.guardianFirstName;
    lastName.text = userData.guardianLastName;
    mobilePhone.text = userData.guardianMobilePhone;
    email.text = userData.guardianEmail;
    address.text = userData.guardianHomeAddress;
    dateOfBirth.text = [userData.guardianDateOfBirth description];
    gender.text = userData.guardianGender;
    [firstName becomeFirstResponder];
    //To dismiss the keyboard on done
    firstName.delegate = self;
    lastName.delegate = self;
    mobilePhone.delegate = self;
    email.delegate = self;
    address.delegate = self;
    dateOfBirth.delegate = self;
    gender.delegate = self;

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
    [self.dateOfBirth resignFirstResponder];
    [self.gender resignFirstResponder];
}

- (void)setUserData {
    userData.guardianFirstName = self.firstName.text;
    userData.guardianLastName = self.lastName.text;
    userData.guardianMobilePhone = self.mobilePhone.text;
    userData.guardianEmail = self.email.text;
    userData.guardianHomeAddress = self.address.text;
    //userData.guardianDateOfBirth = self.dateOfBirth.text;
    userData.guardianGender = self.gender.text;
    userData.guardianImage = [DataUtils toBase64:guardianImageBtn.imageView.image];
    [DataUtils saveAllData];
}

#pragma mark IBActions
- (IBAction)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveGuardianDetails:(id)sender {
    //Save changes to core data
    [self setUserData];
    if (firstTime) {
        //Save to server
        NSMutableDictionary *mapData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 userData.guardianFirstName,   @"first_name",
                                 userData.guardianLastName,    @"last_name",
                                 userData.guardianEmail,       @"email",
                                 userData.guardianMobilePhone, @"phone",
                                 userData.guardianHomeAddress, @"address",
                                 userData.guardianGender,      @"gender",
                                 userData.guardianDateOfBirth, @"dob", nil];
        HttpService *httpService = [[HttpService alloc] init];
        [httpService postJsonRequest:@"sign_up" postDict:mapData callbackOK:^(NSDictionary *jsonDict) {
            userData.guardianToken = [jsonDict objectForKey:@"token"];
            //Go to next screen
            [[NSOperationQueue mainQueue] addOperationWithBlock:^
             {
                 if (userData.elderCode) {
                     [self performSelector:@selector(performSegueWithIdentifier:sender:) withObject:@"fromGuardianRegistrationToElderStatus"];
                 } else {
                     [self performSelector:@selector(performSegueWithIdentifier:sender:) withObject:@"fromGuardianRegistrationToVerifyCode"];
                 }
             }];
        } callbackErr:^(NSString * errStr) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^
             {
                 [[[UIAlertView alloc] initWithTitle:@"Signup error" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
             }];
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];

    }
}

- (IBAction)changeGuardianImage:(id)sender {
    UIImagePickerControllerSourceType imageSourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imageSourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = imageSourceType;
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark change image

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //dismiss the pick dialog
    [picker dismissViewControllerAnimated:YES completion:NULL];
    //set the image
    guardianImageBtn.imageView.image = info[UIImagePickerControllerEditedImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
