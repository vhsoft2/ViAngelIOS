//
//  HttpService.m
//  ViGuard
//
//  Created by Ronen Shraga on 12/19/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import "HttpService.h"

@implementation HttpService

NSString *serverAddress = @"http://109.226.62.3/";

-(void)postJsonRequest:(NSString*)serviceName postDict:(NSMutableDictionary*)postDict callbackOK:(PostJsonCallbackOK)callbackOK callbackErr:(PostCallbackErr)callbackErr {
    NSError *error;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURL *url = [NSURL URLWithString:[serverAddress stringByAppendingString:serviceName]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    //Set request headers
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    //Set request body
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDict options:0 error:&error];
    [request setHTTPBody:postData];
    //Run the request
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
            if (httpResp.statusCode == 200) {
                NSDictionary* jsonDict = nil;
                if (data.length>8) {
                    jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                    if (error)
                        NSLog(@"%@ NSJSONSerialization:%@", NSStringFromSelector(_cmd), error);
                }
                callbackOK(jsonDict);
            } else {
                NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                callbackErr([NSString stringWithFormat:@"Server returned status %ld\n%@", (long)httpResp.statusCode, dataStr]);
                NSLog(@"%@ Server returned status %ld, message:%@", NSStringFromSelector(_cmd), (long)httpResp.statusCode, dataStr);
            }
        } else {
            callbackErr(@"Error calling server");
            NSLog(@"%@ dataTaskWithRequest:%@", NSStringFromSelector(_cmd), error);
        }
    }] resume];
}

-(void)postDataRequest:(NSString*)serviceName postDict:(NSMutableDictionary*)postDict callbackOK:(PostDataCallbackOK)callbackOK callbackErr:(PostCallbackErr)callbackErr {
    NSError *error;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURL *url = [NSURL URLWithString:[serverAddress stringByAppendingString:serviceName]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    //Set request headers
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    //Set request body
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDict options:0 error:&error];
    [request setHTTPBody:postData];
    //Run the request
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
            if (httpResp.statusCode == 200) {
                if (data.length)
                    callbackOK([NSString stringWithUTF8String:[data bytes]]);
                else
                    callbackOK(@"");
            } else {
                NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                callbackErr([NSString stringWithFormat:@"Server returned status %ld\n%@", (long)httpResp.statusCode, dataStr]);
                NSLog(@"%@ Server returned status %ld, message:%@", NSStringFromSelector(_cmd), (long)httpResp.statusCode, dataStr);
            }
        } else {
            callbackErr(@"Error calling server");
            NSLog(@"%@ dataTaskWithRequest:%@", NSStringFromSelector(_cmd), error);
        }
    }];
    [postDataTask resume];
}

@end
