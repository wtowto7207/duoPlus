//
//  WeiuiNavbarItemComponent.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/2.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "WeiuiNavbarItemComponent.h"
#import "DeviceUtil.h"

@implementation WeiuiNavbarItemComponent

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    if (self) {
        
        _barType = @"";
        
        for (NSString *key in styles.allKeys) {
            [self dataKey:key value:styles[key] isUpdate:NO];
        }
        for (NSString *key in attributes.allKeys) {
            [self dataKey:key value:attributes[key] isUpdate:NO];
        }
        
        self.cssNode->style.justify_content = CSS_JUSTIFY_CENTER;
        self.cssNode->style.align_items = CSS_ALIGN_CENTER;
        
        
//#warning ssss 没有设置宽度，则在v-if刷新的时候会出现布局失效的bug
//        bool isNan = isnan(self.cssNode->style.dimensions[CSS_WIDTH]);
//        if (isNan) {
//            if ([_barType isEqualToString:@"title"]) {
//                self.cssNode->style.dimensions[CSS_WIDTH] = SCALE(600);
//                self.cssNode->style.dimensions[CSS_HEIGHT] = SCALE(100);
//            } else {
//                self.cssNode->style.dimensions[CSS_WIDTH] = SCALE(100);
//            }
//        }
    }
    
    return self;
}


- (void)updateStyles:(NSDictionary *)styles
{
    for (NSString *key in styles.allKeys) {
        [self dataKey:key value:styles[key] isUpdate:YES];
    }
}

- (void)updateAttributes:(NSDictionary *)attributes
{
    for (NSString *key in attributes.allKeys) {
        [self dataKey:key value:attributes[key] isUpdate:YES];
    }
}

- (void)insertSubview:(WXComponent *)subcomponent atIndex:(NSInteger)index
{
#warning ssss 没有设置宽度，则在v-if刷新的时候会出现布局失效的bug
    self.cssNode->style.dimensions[CSS_WIDTH] =  subcomponent.calculatedFrame.size.width;
   
    [super insertSubview:subcomponent atIndex:index];
}

#pragma mark data
- (void)dataKey:(NSString*)key value:(id)value isUpdate:(BOOL)isUpdate
{
    key = [DeviceUtil convertToCamelCaseFromSnakeCase:key];
    if ([key isEqualToString:@"weiui"] && [value isKindOfClass:[NSDictionary class]]) {
        for (NSString *k in [value allKeys]) {
            [self dataKey:k value:value[k] isUpdate:isUpdate];
        }
    } else if ([key isEqualToString:@"type"]) {
        _barType = [WXConvert NSString:value];
    }
}

@end
