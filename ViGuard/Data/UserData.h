//
//  User.h
//  ViGuard
//
//  Created by Ronen Shraga on 12/18/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserData : NSManagedObject

@property (nonatomic, retain) NSString * elderCode;
@property (nonatomic, retain) NSDate * elderDateOfBirth;
@property (nonatomic, retain) NSString * elderEmail;
@property (nonatomic, retain) NSString * elderFirstName;
@property (nonatomic, retain) NSString * elderGender;
@property (nonatomic, retain) NSString * elderHomeAddress;
@property (nonatomic, retain) NSString * elderImage;
@property (nonatomic, retain) NSDate * elderImageUpdated;
@property (nonatomic, retain) NSString * elderLastName;
@property (nonatomic, retain) NSString * elderMobilePhone;
@property (nonatomic, retain) NSString * guardianCode;
@property (nonatomic, retain) NSDate * guardianDateOfBirth;
@property (nonatomic, retain) NSString * guardianEmail;
@property (nonatomic, retain) NSString * guardianFirstName;
@property (nonatomic, retain) NSString * guardianGender;
@property (nonatomic, retain) NSString * guardianHomeAddress;
@property (nonatomic, retain) NSString * guardianImage;
@property (nonatomic, retain) NSDate * guardianImageUpdated;
@property (nonatomic, retain) NSString * guardianLastName;
@property (nonatomic, retain) NSString * guardianMobilePhone;
@property (nonatomic, retain) NSString * guardianToken;

@end
