//
//  ImagePreviewViewController.h
//  WeexTestDemo
//
//  Created by apple on 2018/6/10.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePreviewViewController : UIViewController

@property (nonatomic, strong) NSArray *paths;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL isAddDelete;

@property (nonatomic, copy) void (^deleteBlock)(NSInteger);

@end
