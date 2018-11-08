//
//  WeiuiUmengManager.h
//  WeexTestDemo
//
//  Created by apple on 2018/6/20.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeexSDK.h"
#import <UMPush/UMessage.h>

#define kUmengNotification @"kUmengNotification"

@interface WeiuiUmengManager : NSObject

@property (nonatomic, strong) NSString *token;
@property (nonatomic, copy) WXModuleKeepAliveCallback callback;

+ (WeiuiUmengManager *)sharedIntstance;

- (void)init:(NSString*)key secret:(NSString*)secret channel:(NSString*)channel launchOptions:(NSDictionary*)launchOptions;

- (void)setNotificationClickHandler:(WXModuleKeepAliveCallback)callback;

@end
