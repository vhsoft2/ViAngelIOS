//
//  UIAlertView+WithBlock.h
//  ViGuard
//
//  Created by Ronen Shraga on 12/25/13.
//  Copyright (c) 2013 Vitalitix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (WithBlock)

- (void)showWithCompletion:(void(^)(UIAlertView *alertView, NSInteger buttonIndex))completion;

@end
