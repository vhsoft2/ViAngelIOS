//
//  DataUtils.h
//  ViGuard
//
//  Created by Ronen Shraga on 12/19/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserData.h"

@interface DataUtils : NSObject

+(UserData*)getUserData;
+(void)saveAllData;

+(NSString *)toBase64:(UIImage*)img;

+(UIImage *)fromBase64:(NSString*)str;

+(NSDate*)dateFromStr:(NSString*)str;
+(NSString*)dateTimeStrFromDate:(NSDate*)date;
+(NSString*)dateStrFromDate:(NSDate*)date;
+(NSString*)timeStrFromDate:(NSDate*)date;
+(NSDate*)dateFromMilliSecondStr:(NSString*)msStr;
+(NSString*)strFromDate:(NSDate*)date format:(NSString*)format;
+(NSDate*)dateFromStr:(NSString *)str format:(NSString*)format;
+(NSData*)dataFromBase64:(NSString*)str;

@end
