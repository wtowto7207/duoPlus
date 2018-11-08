//
//  WeiuiUmengModule.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/19.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "WeiuiUmengModule.h"
#import "WeiuiUmengManager.h"

@implementation WeiuiUmengModule

//WX_EXPORT_METHOD(@selector(init:secret:channel:))
WX_EXPORT_METHOD_SYNC(@selector(getToken))
WX_EXPORT_METHOD(@selector(setNotificationClickHandler:))

//- (void)init:(NSString*)key secret:(NSString*)secret channel:(NSString*)channel
//{
//    [[WeiuiUmengManager sharedIntstance] init:key secret:secret channel:channel];
//}

- (NSString*)getToken
{
    return [[WeiuiUmengManager sharedIntstance] token];
}

- (void)setNotificationClickHandler:(WXModuleKeepAliveCallback)callback
{
    [[WeiuiUmengManager sharedIntstance] setNotificationClickHandler:callback];
}

@end
