//
//  HttpService.h
//  ViGuard
//
//  Created by Ronen Shraga on 12/19/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpService : NSObject <NSURLSessionDelegate>

typedef void(^PostJsonCallbackOK)(NSDictionary*);
typedef void(^PostDataCallbackOK)(NSString*);
typedef void(^PostCallbackErr)(NSString*);

-(void)postJsonRequest:(NSString*)serviceName postDict:(NSMutableDictionary*)postDict callbackOK:(PostJsonCallbackOK)callbackOK callbackErr:(PostCallbackErr)callbackErr;

-(void)postDataRequest:(NSString*)serviceName postDict:(NSMutableDictionary*)postDict callbackOK:(PostDataCallbackOK)callbackOK callbackErr:(PostCallbackErr)callbackErr;

@end
