//
//  ShareContactsVC.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/21/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>
#import "ShareContactsVC.h"
#import "HttpService.h"
#import "DataUtils.h"

@interface ShareContactsVC ()

@end

@implementation ShareContactsVC

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            dispatch_async(dispatch_get_main_queue(), ^{
                 [[[UIAlertView alloc] initWithTitle:@"Load address book" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
             });
        }];
    }
}

#pragma mark IBActions
- (IBAction)shareContacts:(id)sender {
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
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"fromShareContactsToElderStatus" sender:self];
            });
        });
    } else if (authorizationStatus == kABAuthorizationStatusAuthorized) {
        [self loadPhoneBook:addressBookRef];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"fromShareContactsToElderStatus" sender:self];
         });
    }
}

- (IBAction)noThanks:(id)sender {
    [self performSegueWithIdentifier:@"fromShareContactsToElderStatus" sender:self];
}

@end
