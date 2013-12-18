//
//  RegistrationViewController.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/17/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import "GuardianRegistrationVC.h"
#import "UserData.h"
#import "AppDelegate.h"
#import "NSDataAdditions.h"

@interface GuardianRegistrationVC ()

@end

@implementation GuardianRegistrationVC

@synthesize changeGuardianImage;

UserData *userData;
NSManagedObjectContext *managedObjectContext = nil;


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
    //changeGuardianImage.imageView.image = ;

    
    managedObjectContext = ((AppDelegate*)([[UIApplication sharedApplication] delegate])).managedObjectContext;

    userData = [self getUserData];
    if (userData.guardianImage)
        changeGuardianImage.imageView.image = [self fromBase64:userData.guardianImage];
    self.firstName.text = userData.guardianFirstName;
    self.lastName.text = userData.guardianLastName;
    self.mobilePhone.text = userData.guardianMobilePhone;
    self.email.text = userData.guardianEmail;
    self.address.text = userData.guardianHomeAddress;
    self.dateOfBirth.text = [userData.guardianDateOfBirth description];
    self.gender.text = userData.guardianGender;
    [self.firstName becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveGuardianDetails:(id)sender {
    //Save changes to core data
    [self setUserData];
    //Go to next screen
    if (userData.elderCode) {
        [self performSelector:@selector(performSegueWithIdentifier:sender:) withObject:@"fromGuardianRegistrationToElderStatus"];
    } else {
        [self performSelector:@selector(performSegueWithIdentifier:sender:) withObject:@"fromGuardianRegistrationToVerifyCode"];
    }
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

- (NSString *)toBase64:(UIImage*)img {
    NSData * data = [UIImagePNGRepresentation(img) base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return [NSString stringWithUTF8String:[data bytes]];
}

- (UIImage *)fromBase64:(NSString*)str {
    return [UIImage imageWithData:[NSData dataWithBase64EncodedString:str]];
}

- (NSArray*)fetchData {
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"UserData" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    [request setPredicate:nil];
    return [managedObjectContext executeFetchRequest:request error:nil];
}

- (void)setUserData {
    NSArray *objects = [self fetchData];
    if (objects) {
        UserData *uData = (UserData*)objects[0];
        uData.guardianFirstName = self.firstName.text;
        userData.guardianLastName = self.lastName.text;
        userData.guardianMobilePhone = self.mobilePhone.text;
        userData.guardianEmail = self.email.text;
        userData.guardianHomeAddress = self.address.text;
        //userData.guardianDateOfBirth = self.dateOfBirth.text;
        userData.guardianGender = self.gender.text;

        uData.guardianImage = [self toBase64:changeGuardianImage.imageView.image];
        [managedObjectContext save:nil];
    }
}

- (UserData*)getUserData {
    UserData *uData = nil;
    NSArray *objects = [self fetchData];
    if (objects) {
        uData = (UserData*)objects[0];
    }
    return uData;
}

#pragma mark change image

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //dismiss the pick dialog
    [picker dismissViewControllerAnimated:YES completion:NULL];
    //set the image
    changeGuardianImage.imageView.image = info[UIImagePickerControllerEditedImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

@end
