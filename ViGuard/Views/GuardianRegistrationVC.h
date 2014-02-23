//
//  RegistrationViewController.h
//  ViGuard
//
//  Created by Ronen Shraga on 12/17/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionSheetPicker.h"
#import "GAITrackedViewController.h"

@interface GuardianRegistrationVC : GAITrackedViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate,UITextFieldDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *guardianImageBtn;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *mobilePhone;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UITextField *dateOfBirthTxt;
@property (weak, nonatomic) IBOutlet UITextField *genderTxt;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBtn;

//Picker properties
@property (nonatomic, assign) NSInteger picekerSelectedIndex;
@property (nonatomic, strong) AbstractActionSheetPicker *actionSheetPicker;

@end
