//
//  DataUtils.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/19/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//
#import "AppDelegate.h"
#import "DataUtils.h"
#import "NSDataAdditions.h"

@implementation DataUtils

static UserData *userData = nil;
static NSManagedObjectContext *managedObjectContext = nil;
//
//UserData helpers
//
+(NSArray*)fetchData {
    if (!managedObjectContext)
        managedObjectContext = ((AppDelegate*)([[UIApplication sharedApplication] delegate])).managedObjectContext;
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"UserData" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    [request setPredicate:nil];
    return [managedObjectContext executeFetchRequest:request error:nil];
}

+(UserData*)getUserData {
    if (!userData) {
        userData = [[self fetchData] firstObject];
    }
    return userData;
}

+(void)saveAllData {
    [managedObjectContext save:nil];
}
//
//Base64 helpers
//
+(NSString *)toBase64:(UIImage*)img {
    NSData * data = [UIImageJPEGRepresentation(img,0.25) base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return [NSString stringWithUTF8String:[data bytes]];
}

+(NSString *)dataToBase64:(NSData*)data {
    NSData * b64Data = [data base64EncodedDataWithOptions:0];
    return [NSString stringWithUTF8String:[b64Data bytes]];
}

+(UIImage *)fromBase64:(NSString*)str {
    return [UIImage imageWithData:[NSData dataWithBase64EncodedString:str]];
}

+(NSData*)dataFromBase64:(NSString*)str {
    return [NSData dataWithBase64EncodedString:str];
}
//
//Date and time functions
//
+(NSDate*)dateFromStr:(NSString *)str format:(NSString*)format {
    NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
    [inFormat setDateFormat:format];
    return [inFormat dateFromString:str];
}

+(NSString*)strFromDate:(NSDate*)date format:(NSString*)format {
    NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
    [inFormat setDateFormat:format];
    return [inFormat stringFromDate:date];
}

+(NSDate*)dateFromStr:(NSString*)str {
    return [self dateFromStr:str format:@"yyyy-MM-dd HH:mm:ss"];
}

+(NSString*)dateTimeStrFromDate:(NSDate*)date {
    return [self strFromDate:date format:@"yyyy-MM-dd HH:mm:ss"];
}

+(NSString*)dateStrFromDate:(NSDate*)date {
    return [self strFromDate:date format:@"yyyy-MM-dd"];
}

+(NSString*)timeStrFromDate:(NSDate*)date {
    return [self strFromDate:date format:@"HH:mm:ss"];
}

+(NSDate*)dateFromMilliSeconds:(NSNumber*)ms {
    return [NSDate dateWithTimeIntervalSince1970:[ms longLongValue]/1000];
}

+(NSNumber*)milliSecondsFromDate:(NSDate*)date {
    return [NSNumber numberWithDouble:[date timeIntervalSince1970]*1000];
}
@end
