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

+(NSString *)toBase64:(UIImage*)img {
    NSData * data = [UIImagePNGRepresentation(img) base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return [NSString stringWithUTF8String:[data bytes]];
}

+(UIImage *)fromBase64:(NSString*)str {
    return [UIImage imageWithData:[NSData dataWithBase64EncodedString:str]];
}

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

+(NSDate*)dateFromMilliSecondStr:(NSString*)msStr {
    return [NSDate dateWithTimeIntervalSince1970:[msStr integerValue]/1000];
}

@end
