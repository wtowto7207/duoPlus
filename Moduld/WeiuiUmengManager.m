
//
//  WeiuiUmengManager.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/20.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "WeiuiUmengManager.h"
#import <UMCommon/UMCommon.h>
//#import <UMAnalytics/MobClick.h>
#import <UMCommonLog/UMCommonLogHeaders.h>

@implementation WeiuiUmengManager

+ (WeiuiUmengManager *)sharedIntstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)init:(NSString*)key secret:(NSString*)secret channel:(NSString*)channel launchOptions:(NSDictionary*)launchOptions
{
    //开发者需要显式的调用此函数，日志系统才能工作
    [UMCommonLogManager setUpUMCommonLogManager];
    [UMConfigure setLogEnabled:YES];
    
    [UMConfigure initWithAppkey:key channel:channel];
    
    //    [MobClick setScenarioType:E_UM_GAME|E_UM_DPLUS];
    // Push's basic setting
    UMessageRegisterEntity * entity = [[UMessageRegisterEntity alloc] init];
    //type是对推送的几个参数的选择，可以选择一个或者多个。默认是三个全部打开，即：声音，弹窗，角标
    entity.types = UMessageAuthorizationOptionBadge|UMessageAuthorizationOptionAlert|UMessageAuthorizationOptionSound;
    [UMessage registerForRemoteNotificationsWithLaunchOptions:launchOptions Entity:entity completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            // 用户选择了接收Push消息
            NSLog(@"===granted=YES===");
        }else{
            // 用户拒绝接收Push消息
            NSLog(@"===granted==NO==");
        }
    }];
}

- (void)setNotificationClickHandler:(WXModuleKeepAliveCallback)callback
{
    self.callback = callback;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationClick:) name:kUmengNotification object:nil];
}

- (void)notificationClick:(NSNotification *)notification
{
    NSDictionary *data = notification.userInfo;
    NSDictionary *alert = data[@"aps"][@"alert"];
    if ([alert isKindOfClass:[NSDictionary class]]) {
        NSDictionary *result = @{@"status":@"click",
                                 @"display_type":data[@"type"]?data[@"type"]:@"",@"msg_id":data[@"d"]?data[@"d"]:@"", @"body":@{@"after_open":@"",@"play_lights":@"",@"ticker":alert[@"subtitle"]?alert[@"subtitle"]:@"",@"play_vibrate":@"", @"text":alert[@"body"]?alert[@"body"]:@"",@"title":alert[@"title"]?alert[@"title"]:@"",@"play_sound":@""},@"random_min":@"",
                                 };
        
        
        self.callback(result, YES);
    }
    
}

@end
