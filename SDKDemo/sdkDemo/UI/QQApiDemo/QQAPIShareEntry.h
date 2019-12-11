//
//  QQApiShareEntryControllerViewController.h
//  sdkDemo
//
//  Created by JeaminW on 13-7-28.
//  Copyright (c) 2013年 xiaolongzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sdkCall.h"
#import "TencentOpenAPI/QQApiInterfaceObject.h"

@interface QQApiShareEntry : NSObject

+ (UIViewController *)EntryController;

+ (UIViewController *)QQqunEntryController;

+ (void)handleSendResult:(QQApiSendResultCode)sendResult;

@end

@interface QQApiExtraServiceEntry : NSObject

+ (void)StartCallApiExtraService:(NSDictionary *)userInfo;

@end
