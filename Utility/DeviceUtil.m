//
//  DeviceUtil.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/5.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "DeviceUtil.h"
#import "WeexSDKManager.h"
#import "WeexSDK.h"
#import "TBCityIconInfo.h"
#import "TBCityIconFont.h"
#import "WXMainViewController.h"

@implementation DeviceUtil


//设计尺寸转开发尺寸 px -> pt
+ (CGFloat)scale:(NSInteger)value
{
    //weex以750宽为设计尺寸
    return [UIScreen mainScreen].bounds.size.width * 1.0f/750 * value;
}

//字体尺寸转换
+ (NSInteger)font:(NSInteger)font
{
    return font/2;
}

//获取当前控制器
+ (UIViewController *)getTopviewControler {
    UIViewController *rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;
    
    UIViewController *parent = rootVC;
    
    while ((parent = rootVC.presentedViewController) != nil && [(parent = rootVC.presentedViewController) isKindOfClass:[WXMainViewController class]]) {
        rootVC = parent;
    }
    
    while ([rootVC isKindOfClass:[UINavigationController class]]) {
        rootVC = [(UINavigationController *)rootVC topViewController];
    }
    
    return rootVC;
}

//重写url
+ (NSString*)rewriteUrl:(NSString*)url
{
    //和安卓同步，处理本地图片file重复问题
    if ([url hasPrefix:@"file://file://"]) {
        return [url stringByReplacingOccurrencesOfString:@"file://file://" withString:@"file://"];
    }
    
    if (url == nil || [url hasPrefix:@"http"] || [url hasPrefix:@"ftp://"] || [url hasPrefix:@"file://"]) {
        return url;
    }
    
    NSURL *URL = [NSURL URLWithString:[[WeexSDKManager sharedIntstance] weexUrl]];
    NSString *scheme = [URL scheme];
    NSString *host = [URL host];
    NSInteger port = [[URL port] integerValue];
    NSString *path = [URL path];
    
    NSString *newUrl = [NSString stringWithFormat:@"%@://%@%@", scheme, host, port > 0 && port != 80 ? [NSString stringWithFormat:@":%ld", port] : @""];
    if ([url isAbsolutePath]) {
        newUrl = [newUrl stringByAppendingString:url];
    } else {
        if ([path isEqualToString:@"/"]) {
            path = @"";
        } else {
            path = [path stringByDeletingLastPathComponent];
        }
        newUrl = [NSString stringWithFormat:@"%@%@/%@", newUrl, path, url];
    }
    
    return newUrl;
}

//根据文本属性获取图片
+ (UIImage*)getIconText:(NSString*)text font:(NSInteger)font color:(NSString*)icolor
{
    NSString *key = @"";
    NSInteger fontSize = font > 0 ? font : 12;
    NSString *color = icolor.length > 0 ? icolor : @"#242424";
    NSArray *list = [text componentsSeparatedByString:@" "];
    if (list.count == 2) {
        key = [WXConvert NSString:list.firstObject];
        NSString *other = [WXConvert NSString:list.lastObject];
        if ([other hasSuffix:@"px"] || [other hasSuffix:@"dp"] || [other hasSuffix:@"sp"] || [other hasSuffix:@"%"]) {
            fontSize = FONT([other integerValue]);
        } else if ([other isEqualToString:@"#"]) {
            color = other;
        }
    } else {
        key = text;
    }
    //Ionicons
    if ([key hasPrefix:@"tb-"]) {
        [TBCityIconFont setFontName:@"iconfont"];
    } else {
        [TBCityIconFont setFontName:@"Ionicons"];
    }
    
    NSString *imgName = [IconFontUtil iconFont:key];
    
    return [UIImage iconWithInfo:TBCityIconInfoMake(imgName, fontSize, [WXConvert UIColor:color])];
}

//字符串中划线转驼峰写法
+ (NSString *)convertToCamelCaseFromSnakeCase:(NSString *)key
{
    NSMutableString *str = [NSMutableString stringWithString:key];
    while ([str containsString:@"-"]) {
        NSRange range = [str rangeOfString:@"-"];
        if (range.location + 1 < [str length]) {
            char c = [str characterAtIndex:range.location+1];
            [str replaceCharactersInRange:NSMakeRange(range.location, range.length+1) withString:[[NSString stringWithFormat:@"%c",c] uppercaseString]];
        }
    }
    return str;
}

@end
