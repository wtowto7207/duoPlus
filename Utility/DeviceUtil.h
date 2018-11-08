//
//  DeviceUtil.h
//  WeexTestDemo
//
//  Created by apple on 2018/6/5.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

#define SCALE(value) [DeviceUtil scale:value]
#define FONT(value) [DeviceUtil font:value]

#define ScreeScale [[UIScreen mainScreen]scale]

@interface DeviceUtil : NSObject

+ (CGFloat)scale:(NSInteger)value;

+ (NSInteger)font:(NSInteger)font;

+ (UIViewController *)getTopviewControler;

+ (NSString*)rewriteUrl:(NSString*)url;

+ (UIImage*)getIconText:(NSString*)text font:(NSInteger)font color:(NSString*)icolor;

+ (NSString *)convertToCamelCaseFromSnakeCase:(NSString *)key;

@end
