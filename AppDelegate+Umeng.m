//
//  AppDelegate+Umeng.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/24.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "AppDelegate+Umeng.h"

#import "WeiuiUmengManager.h"
#import <UserNotifications/UserNotifications.h>

@implementation AppDelegate (Umeng)

#pragma mark push


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [[[[deviceToken description ] stringByReplacingOccurrencesOfString: @"<" withString:@"" ]
                        stringByReplacingOccurrencesOfString: @">" withString:@""]
                       stringByReplacingOccurrencesOfString: @" " withString:@""
                       ];
    NSLog(@"DeviceToken==%@", token);
    
    [WeiuiUmengManager sharedIntstance].token = token;
}


//iOS10以下使用这两个方法接收通知，
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [UMessage setAutoAlert:NO];
    if([[[UIDevice currentDevice] systemVersion]intValue] < 10){
        [UMessage didReceiveRemoteNotification:userInfo];
        
        if(application.applicationState == UIApplicationStateBackground){
            [self pushInfo:userInfo];
        }
        
        completionHandler(UIBackgroundFetchResultNewData);
    }
}

//iOS10新增：处理前台收到通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于前台时的远程推送接受
        //关闭U-Push自带的弹出框
        [UMessage setAutoAlert:NO];
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        
    }else{
        //应用处于前台时的本地推送接受
    }
    //当应用处于前台时提示设置，需要哪个可以设置哪一个
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}

//iOS10新增：处理后台点击通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接受
        [self pushInfo:userInfo];
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        
    }else{
        //应用处于后台时的本地推送接受
    }
}

- (void)pushInfo:(NSDictionary*)info
{
    NSNotification *notification =[NSNotification notificationWithName:kUmengNotification object:nil userInfo:info];
    
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

@end
