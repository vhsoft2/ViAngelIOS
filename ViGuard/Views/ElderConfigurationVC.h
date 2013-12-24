//
//  ElderConfigurationVC.h
//  ViGuard
//
//  Created by Ronen Shraga on 12/20/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionSheetPicker.h"

@interface ElderConfigurationVC : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstNameTxt;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTxt;
@property (weak, nonatomic) IBOutlet UITextField *mobilePhoneTxt;
@property (weak, nonatomic) IBOutlet UITextField *emailTxt;
@property (weak, nonatomic) IBOutlet UITextField *addressTxt;
@property (weak, nonatomic) IBOutlet UITextField *dateOfBirthTxt;
@property (weak, nonatomic) IBOutlet UITextField *genderTxt;
@property (weak, nonatomic) IBOutlet UIButton *elderImageBtn;

//Picker properties
@property (nonatomic, assign) NSInteger picekerSelectedIndex;
@property (nonatomic, strong) AbstractActionSheetPicker *actionSheetPicker;

@end
