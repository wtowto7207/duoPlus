                                                                                                                                                                                                                  //
//  WeiuiTabbarComponent.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/5.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "WeiuiTabbarComponent.h"
#import "DeviceUtil.h"
#import "UIImage+TBCityIconFont.h"
#import "TriangleIndicatorView.h"
#import "WXMainViewController.h"
#import "WeiuiTabbarPageComponent.h"
#import "MJRefresh.h"
#import "UIButton+WebCache.h"

#define TabItemBtnTag 1000
#define TabItemMessageTag 2000
#define TabItemDotTag 3000
#define TabBgScrollTag 4000

@interface WeiuiTabbarComponent() <UIScrollViewDelegate>

@property (nonatomic, strong) NSString *ktabType;
@property (nonatomic, strong) NSString *ktabBackgroundColor;
@property (nonatomic, strong) NSString *indicatorColor;
@property (nonatomic, strong) NSString *underlineColor;
@property (nonatomic, strong) NSString *dividerColor;
@property (nonatomic, strong) NSString *textSelectColor;
@property (nonatomic, strong) NSString *textUnselectColor;

@property (nonatomic, assign) NSInteger ktabHeight;
@property (nonatomic, assign) NSInteger tabPadding;
@property (nonatomic, assign) NSInteger tabWidth;
@property (nonatomic, assign) NSInteger indicatorStyle;
@property (nonatomic, assign) NSInteger indicatorGravity;
@property (nonatomic, assign) NSInteger indicatorHeight;
@property (nonatomic, assign) NSInteger indicatorWidth;
@property (nonatomic, assign) NSInteger indicatorCornerRadius;
@property (nonatomic, assign) NSInteger indicatorAnimDuration;
@property (nonatomic, assign) NSInteger underlineGravity;
@property (nonatomic, assign) NSInteger underlineHeight;
@property (nonatomic, assign) NSInteger dividerWidth;
@property (nonatomic, assign) NSInteger dividerPadding;
@property (nonatomic, assign) NSInteger textBold;
@property (nonatomic, assign) NSInteger textSize;
@property (nonatomic, assign) NSInteger fontSize;
@property (nonatomic, assign) NSInteger iconGravity;
@property (nonatomic, assign) NSInteger iconWidth;
@property (nonatomic, assign) NSInteger iconHeight;
@property (nonatomic, assign) NSInteger iconMargin;

#warning ssss 无用参数
@property (nonatomic, assign) NSInteger ksideLine;

@property (nonatomic, assign) BOOL tabSpaceEqual;
@property (nonatomic, assign) BOOL indicatorAnimEnable;
@property (nonatomic, assign) BOOL indicatorBounceEnable;
@property (nonatomic, assign) BOOL iconVisible;
@property (nonatomic, assign) BOOL isExistIconVisible;//辅助初始化

@property (nonatomic, strong) UIScrollView *tabView;
@property (nonatomic, strong) UIScrollView *bodyView;
@property (nonatomic, strong) UIView *underLineView;
@property (nonatomic, strong) UIView *indicatorView;

@property (nonatomic, strong) NSMutableArray *subComps;
@property (nonatomic, strong) NSMutableArray *tabPages;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) NSInteger lastSelectedIndex;//上次被选中的标签
@property (nonatomic, assign) NSInteger reSelectedIndex;//标签被再次点击选择标记

@property (nonatomic, strong) WXSDKInstance *tabInstance;
@property (nonatomic, strong) NSMutableArray *tabNameList;
@property (nonatomic, strong) NSMutableArray *childPageList;
@property (nonatomic, strong) NSMutableArray *childComponentList;
@property (nonatomic, strong) NSMutableDictionary *lifeTabPages;

@property (nonatomic, assign) BOOL isRefreshListener;

@end

@implementation WeiuiTabbarComponent

WX_EXPORT_METHOD_SYNC(@selector(getTabPosition:))
WX_EXPORT_METHOD_SYNC(@selector(getTabName:))
WX_EXPORT_METHOD(@selector(showMsg:num:))
WX_EXPORT_METHOD(@selector(showDot:))
WX_EXPORT_METHOD(@selector(hideMsg:))
WX_EXPORT_METHOD(@selector(removePageAt:))
WX_EXPORT_METHOD(@selector(setCurrentItem:))
WX_EXPORT_METHOD(@selector(setRefreshing:refresh:))
WX_EXPORT_METHOD(@selector(goUrl:url:))
WX_EXPORT_METHOD(@selector(reload:))
WX_EXPORT_METHOD(@selector(setTabType:))
WX_EXPORT_METHOD(@selector(setTabHeight:))
WX_EXPORT_METHOD(@selector(setTabBackgroundColor:))
WX_EXPORT_METHOD(@selector(setTabTextsize:))
WX_EXPORT_METHOD(@selector(setTabTextBold:))
WX_EXPORT_METHOD(@selector(setTabTextUnselectColor:))
WX_EXPORT_METHOD(@selector(setTabTextSelectColor:))
WX_EXPORT_METHOD(@selector(setTabIconVisible:))
WX_EXPORT_METHOD(@selector(setTabIconWidth:))
WX_EXPORT_METHOD(@selector(setTabIconHeight:))
WX_EXPORT_METHOD(@selector(setSideline:))

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    if (self) {
        
        _tabPages = [NSMutableArray arrayWithCapacity:5];
        
        _selectedIndex = 0;
        _lastSelectedIndex = 0;
        _reSelectedIndex = 0;
        
        _tabInstance = weexInstance;
        
        _ktabType = @"bottom";
        _ktabBackgroundColor = @"#FFFFFF";
//        _indicatorColor = @"#FFFFFF";
        _underlineColor = @"#FFFFFF";
        _dividerColor = @"#FFFFFF";
        _textSelectColor = @"#3EB4FF";
        _textUnselectColor = @"#999999";
        _ktabHeight = SCALE(100);
        _tabPadding = SCALE(20);
        _tabWidth = 0;
        _indicatorStyle = 0;
        _indicatorGravity = 0;
        _indicatorHeight = SCALE(4);
        _indicatorWidth = SCALE(60);
        _indicatorCornerRadius = 0;
        _indicatorAnimDuration = 300;
        _underlineGravity = 0;
        _underlineHeight = 0;
        _dividerWidth = 0;
        _dividerPadding = 0;
        _textBold = 1;
        _textSize = FONT(24);
        _iconGravity = 1;
        _iconWidth = 0;
        _iconHeight = 0;
        _iconMargin = SCALE(10);
        _ksideLine = 1;
        _tabSpaceEqual = YES;
        _indicatorAnimEnable = YES;
        _indicatorBounceEnable = YES;
        
        for (NSString *key in styles.allKeys) {
            [self dataKey:key value:styles[key] isUpdate:NO];
        }
        for (NSString *key in attributes.allKeys) {
            [self dataKey:key value:attributes[key] isUpdate:NO];
        }
        
        if (!_indicatorColor) {
            if (_indicatorStyle == 2) {
                _indicatorColor = @"#4B6A87";
            } else {
                _indicatorColor = @"#FFFFFF";
            }
        }
        
        if (!_isExistIconVisible) {
            if ([_ktabType isEqualToString:@"bottom"]) {
                _iconVisible = YES;
            } else {
                _iconVisible = NO;
            }
        }
        
        _isRefreshListener = [events containsObject:@"refreshListener"];
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    self.subComps = [NSMutableArray arrayWithCapacity:5];
    self.childPageList = [NSMutableArray arrayWithCapacity:5];
    self.childComponentList = [NSMutableArray arrayWithCapacity:5];
    self.lifeTabPages = [NSMutableDictionary dictionaryWithCapacity:5];

    self.bodyView = [[UIScrollView alloc] init];
    self.bodyView.pagingEnabled = YES;
    self.bodyView.showsHorizontalScrollIndicator = NO;
    self.bodyView.bounces = NO;
    self.bodyView.delegate = self;
    [self.view addSubview:self.bodyView];
    
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        self.bodyView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
#endif

    //tab
    self.tabView = [[UIScrollView alloc] init];
    [self.view addSubview:self.tabView];
    
    [self loadTabView];

    //indicator
    if (_indicatorStyle == 0) {
        self.indicatorView =  [[UIView alloc] init];
        [self.tabView addSubview:self.indicatorView];
        [self loadIndicatorView];
    } else if (_indicatorStyle == 1) {
        self.indicatorView =  [[TriangleIndicatorView alloc] init];
        [self.tabView addSubview:self.indicatorView];
        [self loadIndicatorView];
    }
    
    //下划线
    self.underLineView = [[UIView alloc] init];
    [self.view addSubview:self.underLineView];
    [self loadUnderLineView];
    
    //添加子视图
    if (_tabPages.count > 0) {
        [self loadTabPagesView];
    }
    
    [self fireEvent:@"ready" params:nil];
}

- (void)updateStyles:(NSDictionary *)styles
{
    for (NSString *key in styles.allKeys) {
        [self dataKey:key value:styles[key] isUpdate:YES];
    }
    
    [self loadTabView];
    
    [self loadSelectedView];
    
    [self loadUnderLineView];
}

- (void)updateAttributes:(NSDictionary *)attributes
{
    for (NSString *key in attributes.allKeys) {
        [self dataKey:key value:attributes[key] isUpdate:YES];
    }
    
    [self loadTabView];
    
    [self loadSelectedView];
    
    [self loadUnderLineView];
}


- (void)insertSubview:(WXComponent *)subcomponent atIndex:(NSInteger)index
{
//    [super insertSubview:subcomponent atIndex:index];
    
    if ([subcomponent isKindOfClass:[WeiuiTabbarPageComponent class]]) {
        if (self.subComps.count == 0) {
            [self.subComps addObject:subcomponent];
//            [self loadComponentView];
            [self performSelector:@selector(loadComponentView) withObject:nil afterDelay:0.1];
        } else {
            [self.subComps insertObject:subcomponent atIndex:index];
        }
    }
    
    [self loadTabView];
}


#pragma mark data
- (void)dataKey:(NSString*)key value:(id)value isUpdate:(BOOL)isUpdate
{
    key = [DeviceUtil convertToCamelCaseFromSnakeCase:key];
    if ([key isEqualToString:@"weiui"] && [value isKindOfClass:[NSDictionary class]]) {
        for (NSString *k in [value allKeys]) {
            [self dataKey:k value:value[k] isUpdate:isUpdate];
        }
    } else if ([key isEqualToString:@"tabPages"]) {
        _tabPages = [NSMutableArray arrayWithArray:value];
    } else if ([key isEqualToString:@"tabType"]) {
        _ktabType = [WXConvert NSString:value];
    } else if ([key isEqualToString:@"tabBackgroundColor"]) {
        _ktabBackgroundColor = [WXConvert NSString:value];
    } else if ([key isEqualToString:@"indicatorColor"]) {
        _indicatorColor = [WXConvert NSString:value];
    } else if ([key isEqualToString:@"underlineColor"]) {
        _underlineColor = [WXConvert NSString:value];
    } else if ([key isEqualToString:@"dividerColor"]) {
        _dividerColor = [WXConvert NSString:value];
    } else if ([key isEqualToString:@"textSelectColor"]) {
        _textSelectColor = [WXConvert NSString:value];
    } else if ([key isEqualToString:@"textUnselectColor"]) {
        _textUnselectColor = [WXConvert NSString:value];
    } else if ([key isEqualToString:@"tabHeight"]) {
        _ktabHeight = SCALE([WXConvert NSInteger:value]);
    } else if ([key isEqualToString:@"tabPadding"]) {
        _tabPadding = SCALE([WXConvert NSInteger:value]);
    } else if ([key isEqualToString:@"tabWidth"]) {
        _tabWidth = SCALE([WXConvert NSInteger:value]);
    } else if ([key isEqualToString:@"indicatorStyle"]) {
        _indicatorStyle = [WXConvert NSInteger:value];
    } else if ([key isEqualToString:@"indicatorGravity"]) {
        _indicatorGravity = [WXConvert NSInteger:value];
    } else if ([key isEqualToString:@"indicatorHeight"]) {
        _indicatorHeight = SCALE([WXConvert NSInteger:value]);
    } else if ([key isEqualToString:@"indicatorWidth"]) {
        _indicatorWidth = SCALE([WXConvert NSInteger:value]);
    } else if ([key isEqualToString:@"indicatorCornerRadius"]) {
        _indicatorCornerRadius = [WXConvert NSInteger:value];
    } else if ([key isEqualToString:@"indicatorAnimDuration"]) {
        _indicatorAnimDuration = [WXConvert NSInteger:value];
    } else if ([key isEqualToString:@"underlineGravity"]) {
        _underlineGravity = [WXConvert NSInteger:value];
    } else if ([key isEqualToString:@"underlineHeight"]) {
        _underlineHeight = SCALE([WXConvert NSInteger:value]);
    } else if ([key isEqualToString:@"dividerWidth"]) {
        _dividerWidth = SCALE([WXConvert NSInteger:value]);
    } else if ([key isEqualToString:@"dividerPadding"]) {
        _dividerPadding = SCALE([WXConvert NSInteger:value]);
    } else if ([key isEqualToString:@"textBold"]) {
        _textBold = [WXConvert NSInteger:value];
    } else if ([key isEqualToString:@"textSize"]) {
        _textSize = FONT([WXConvert NSInteger:value]);
    } else if ([key isEqualToString:@"fontSize"]) {
        _textSize = FONT([WXConvert NSInteger:value]);
    } else if ([key isEqualToString:@"iconGravity"]) {
        _iconGravity = [WXConvert NSInteger:value];
    } else if ([key isEqualToString:@"iconWidth"]) {
        _iconWidth = SCALE([WXConvert NSInteger:value]);
    } else if ([key isEqualToString:@"iconHeight"]) {
        _iconHeight = [WXConvert NSInteger:value];
    } else if ([key isEqualToString:@"iconMargin"]) {
        _iconMargin = [WXConvert NSInteger:value];
    } else if ([key isEqualToString:@"sideLine"]) {
        _ksideLine = [WXConvert NSInteger:value];
    } else if ([key isEqualToString:@"tabSpaceEqual"]) {
        _tabSpaceEqual = [WXConvert BOOL:value];
    } else if ([key isEqualToString:@"indicatorAnimEnable"]) {
        _indicatorAnimEnable = [WXConvert BOOL:value];
    } else if ([key isEqualToString:@"indicatorBounceEnable"]) {
        _indicatorBounceEnable = [WXConvert BOOL:value];
    } else if ([key isEqualToString:@"iconVisible"]) {
        _iconVisible = [WXConvert BOOL:value];
        if (!isUpdate) {
            _isExistIconVisible = YES;
        }
    }
}

#pragma mark view

- (void)loadTabView
{
    NSLog(@"%f, %f", self.view.frame.size.width, self.view.frame.size.height);
    if ([_ktabType isEqualToString:@"bottom"]) {
        self.bodyView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - _ktabHeight);
        self.tabView.frame = CGRectMake(0, self.view.frame.size.height - _ktabHeight, self.view.frame.size.width, _ktabHeight);
    } else {
        self.bodyView.frame = CGRectMake(0, _ktabHeight, self.view.frame.size.width, self.view.frame.size.height - _ktabHeight);
        self.tabView.frame = CGRectMake(0, 0, self.view.frame.size.width, _ktabHeight);
    }
    
    self.tabView.backgroundColor = [WXConvert UIColor:_ktabBackgroundColor];
    
    //判断数据源,优先tabPages
    NSMutableArray *dataList = [NSMutableArray arrayWithCapacity:5];
    
    if (self.tabPages.count > 0) {
        [dataList addObjectsFromArray:self.tabPages];
    }
    
    if (self.subComps.count > 0) {
        [dataList addObjectsFromArray:self.subComps];
    }
    
    if (dataList.count > 0) {
        [self.bodyView setContentSize:CGSizeMake(self.bodyView.frame.size.width * dataList.count, 0)];
        self.tabNameList = [NSMutableArray arrayWithCapacity:5];

        for (UIView *oldView in self.tabView.subviews) {
            [oldView removeFromSuperview];
        }

        CGFloat allWidth = _tabPadding;
        for (int i = 0; i < dataList.count; i++) {
            id data = dataList[i];
            
            NSString *tabName = @"";
            NSString *title = @"";
            NSInteger message = 0;
            NSString *unSelectedIcon =  @"";
            NSString *selectedIcon =  @"";
            BOOL dot = NO;
            
            if ([data isKindOfClass:[WeiuiTabbarPageComponent class]]) {
                WeiuiTabbarPageComponent *cmp = (WeiuiTabbarPageComponent*)data;
                tabName = cmp.tabName;
                title = cmp.title;
                message = cmp.message;
                unSelectedIcon = cmp.unSelectedIcon;
                selectedIcon = cmp.selectedIcon;
            } else if ([data isKindOfClass:[NSDictionary class]]) {
                tabName = data[@"tabName"] ? [WXConvert NSString:data[@"tabName"]] : @"";
                title = data[@"title"] ? [WXConvert NSString:data[@"title"]] : @"";
                message = data[@"message"] ? [WXConvert NSInteger:data[@"message"]] : 0;
                unSelectedIcon = data[@"unSelectedIcon"] ? [WXConvert NSString:data[@"unSelectedIcon"]] : @"home";
                selectedIcon = data[@"selectedIcon"] ? [WXConvert NSString:data[@"selectedIcon"]] : @"home";
                dot = data[@"dot"] ? [WXConvert BOOL:data[@"dot"]] : NO;
            }
           
            NSDictionary *nameData = @{@"tabName":tabName, @"position":@(i)};
            if (self.tabNameList.count == 0) {
                [self.tabNameList addObject:nameData];
            } else {
                [self.tabNameList insertObject:nameData atIndex:i];
            }
            
            CGFloat tabWidth = 0;
            CGFloat iconWidth = 0;
            CGFloat iconHeight = 0;
            CGFloat iconMargin = 0;
            if (_iconVisible) {
                iconWidth = _iconWidth ? _iconWidth : SCALE(40);
                iconHeight = _iconHeight ? _iconHeight : SCALE(40);
                iconMargin = _iconMargin;
            }
            
            if (_tabWidth > 0) {
                tabWidth = _tabWidth;
            } else {
                if ([_ktabType isEqualToString:@"slidingTop"]) {
                    tabWidth = [title boundingRectWithSize:CGSizeMake(1000,30)options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:_textSize]}context:nil].size.width + 8 + _tabPadding*2;
                } else {
                    tabWidth = (self.view.frame.size.width - _tabPadding*2) / dataList.count;
                }
            }
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor = [UIColor clearColor];
            btn.frame = CGRectMake(allWidth, 0, tabWidth, _ktabHeight);
            [btn setTitle:title forState:UIControlStateNormal];
            [btn setTitleColor:[WXConvert UIColor:_textUnselectColor] forState:UIControlStateNormal];
            [btn setTitleColor:[WXConvert UIColor:_textSelectColor] forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(tabbarClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = TabItemBtnTag + i;
            [self.tabView addSubview:btn];

            allWidth += tabWidth;
            
            //图片
            if ([unSelectedIcon hasPrefix:@"http"]) {
                [SDWebImageManager.sharedManager downloadImageWithURL:[NSURL URLWithString:unSelectedIcon] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    if (image) {
                        WXPerformBlockOnMainThread(^{
                            [btn setImage:[self imageResize:image andResizeTo:CGSizeMake(iconWidth, iconHeight)] forState:UIControlStateNormal];
                        });
                    }
                }];
            } else {
                [btn setImage:[self imageResize:[DeviceUtil getIconText:unSelectedIcon font:0 color:@"#242424"] andResizeTo:CGSizeMake(iconWidth, iconHeight)] forState:UIControlStateNormal];
            }
            
            if ([selectedIcon hasPrefix:@"http"]) {
                [SDWebImageManager.sharedManager downloadImageWithURL:[NSURL URLWithString:selectedIcon] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    if (image) {
                        WXPerformBlockOnMainThread(^{
                            [btn setImage:[self imageResize:image andResizeTo:CGSizeMake(iconWidth, iconHeight)] forState:UIControlStateSelected];
                        });
                    }
                }];
            } else {
                [btn setImage:[self imageResize:[DeviceUtil getIconText:selectedIcon font:0 color:_textSelectColor] andResizeTo:CGSizeMake(iconWidth, iconHeight)] forState:UIControlStateSelected];
            }
            
            //字体加粗
            if (_textBold == 2) {
                btn.titleLabel.font = [UIFont boldSystemFontOfSize:_textSize];
            } else {
                btn.titleLabel.font = [UIFont systemFontOfSize:_textSize];
            }
            
            //当前选中item
            if (i == _selectedIndex) {
                btn.selected = YES;
                
                if (_textBold == 1) {
                    btn.titleLabel.font = [UIFont boldSystemFontOfSize:_textSize];
                }
                
                if (_indicatorStyle == 2) {
                    btn.backgroundColor = [WXConvert UIColor:_indicatorColor];
                }
            }
            
            //上下图片文字
            if (_iconGravity) {
                [btn setImageEdgeInsets:UIEdgeInsetsMake(-btn.titleLabel.intrinsicContentSize.height - iconMargin, 0, 0, -btn.titleLabel.intrinsicContentSize.width)];
                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -btn.imageView.frame.size.width ,-btn.imageView.frame.size.height - iconMargin, 0)];
            } else {
                [btn setImageEdgeInsets:UIEdgeInsetsMake(btn.titleLabel.intrinsicContentSize.height + iconMargin, 0, 0, -btn.titleLabel.intrinsicContentSize.width)];
                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -btn.imageView.frame.size.width ,btn.imageView.frame.size.height + iconMargin, 0)];
            }
            
            //分割线
            if (i + 1 != dataList.count) {
                UIView *dividerView = [[UIView alloc] initWithFrame:CGRectMake(btn.frame.origin.x + btn.frame.size.width - _dividerWidth/2, _dividerPadding, _dividerWidth, _ktabHeight - _dividerPadding*2)];
                dividerView.backgroundColor = [WXConvert UIColor:_dividerColor];
                [self.tabView addSubview:dividerView];
            }
            
            //消息数量
            UILabel *msgLab = [[UILabel alloc] initWithFrame:CGRectMake((tabWidth + btn.imageView.frame.size.width)/2 - 5, 5, message >= 10 ? 20 : 15, 15)];
            msgLab.backgroundColor = [UIColor redColor];
            msgLab.font = [UIFont systemFontOfSize:10.f];
            msgLab.textAlignment = NSTextAlignmentCenter;
            msgLab.textColor = [UIColor whiteColor];
            msgLab.adjustsFontSizeToFitWidth = YES;
            msgLab.text = [NSString stringWithFormat:@"%ld", message];
            msgLab.layer.cornerRadius = 7.5f;
            msgLab.layer.masksToBounds = YES;
            msgLab.tag = TabItemMessageTag + i;
            msgLab.hidden = message == 0 ? YES : NO;
            [btn addSubview:msgLab];
            
            //未读红点
            UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake((tabWidth + btn.imageView.frame.size.width)/2 - 5, 5, 6, 6)];
            dotView.backgroundColor = [UIColor redColor];
            dotView.layer.cornerRadius = 3;
            dotView.layer.masksToBounds = YES;
            dotView.tag = TabItemDotTag + i;
            dotView.hidden = !dot;
            [btn addSubview:dotView];
        }
        
        allWidth += _tabPadding;
        [_tabView setContentSize:CGSizeMake(allWidth, 0)];
    }
}

- (void)loadIndicatorView
{
    UIButton *btn = (UIButton*)[self.tabView viewWithTag:TabItemBtnTag + _selectedIndex];

    self.indicatorView.frame = CGRectMake( btn.frame.origin.x + (btn.frame.size.width - _indicatorWidth)/2, _ktabHeight - _indicatorHeight, _indicatorWidth, _indicatorHeight);
    
    self.indicatorView.layer.cornerRadius = _indicatorCornerRadius;
    self.indicatorView.layer.masksToBounds = YES;
    
    if (_indicatorStyle == 1) {
        [(TriangleIndicatorView*)_indicatorView loadColor:[WXConvert UIColor:_indicatorColor]];
        _indicatorView.backgroundColor = [UIColor clearColor];
    } else {
        self.indicatorView.backgroundColor = [WXConvert UIColor:_indicatorColor];
    }
}

- (void)reloadIndicator
{
    NSDictionary *data = @{@"position":@(_selectedIndex)};
    [self fireEvent:@"pageSelected" params:data];
    
#warning ssss
    [self fireEvent:@"pageScrollStateChanged" params:@{@"state":@""}];

    for (int i = 0; i < self.tabPages.count + self.subComps.count; i++) {
        UIButton *btn = [_tabView viewWithTag:TabItemBtnTag + i];
        if (i == _selectedIndex) {
            btn.selected = YES;
            if (_indicatorStyle == 2) {
                btn.backgroundColor = [WXConvert UIColor:_indicatorColor];
            } else {
                [self moveIndicatorView];
            }
            
            //item跟随page滚动
            if (_tabView.contentOffset.x + _tabView.frame.size.width < btn.frame.origin.x + btn.frame.size.width) {
                [_tabView setContentOffset:CGPointMake(btn.frame.origin.x + btn.frame.size.width - _tabView.frame.size.width, 0) animated:YES];
            } else if (_tabView.contentOffset.x > btn.frame.origin.x) {
                [_tabView setContentOffset:CGPointMake(btn.frame.origin.x, 0) animated:YES];
            }
        } else {
            btn.selected = NO;
            if (_indicatorStyle == 2) {
                btn.backgroundColor = [UIColor clearColor];
            }
        }
        
        if (_textBold == 1 && i == _selectedIndex) {
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:_textSize];
        } else {
            btn.titleLabel.font = [UIFont systemFontOfSize:_textSize];
        }
    }
}

- (void)moveIndicatorView
{
    //移动tab显示器
    UIButton *btn = (UIButton*)[self.tabView viewWithTag:TabItemBtnTag + _selectedIndex];
    
    CGRect frame = _indicatorView.frame;
    CGRect oldFrame = _indicatorView.frame;
    frame.origin.x = btn.frame.origin.x + (btn.frame.size.width - _indicatorWidth)/2;
    
    if (_indicatorAnimEnable) {
        __weak typeof(self) ws = self;
        if (_indicatorBounceEnable) {
            //回弹效果
            [UIView animateWithDuration:_indicatorAnimDuration*1.0/1000 animations:^{
                CGRect nFrame = oldFrame;
                if (oldFrame.origin.x > frame.origin.x) {
                    nFrame.origin.x = frame.origin.x - 5;//左回弹
                } else {
                    nFrame.origin.x = frame.origin.x + 5;//右回弹
                }
                ws.indicatorView.frame = nFrame;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 animations:^{
                    ws.indicatorView.frame = frame;
                }];
            }];
        } else {
            [UIView animateWithDuration:_indicatorAnimDuration*1.0/1000 animations:^{
                ws.indicatorView.frame = frame;
            }];
        }
    } else {
        _indicatorView.frame = frame;
    }
}

- (void)loadUnderLineView
{
    CGFloat y = 0;
    CGFloat lineHeight = _underlineHeight ? _underlineHeight : 1;
    if (_underlineGravity == 0) {
        //下方
        y = self.tabView.frame.origin.y + _ktabHeight - lineHeight;
    } else {
        y = self.tabView.frame.origin.y;
    }
    
    self.underLineView.frame = CGRectMake(0, y, _tabView.frame.size.width, lineHeight);
    self.underLineView.backgroundColor = [WXConvert UIColor:_underlineColor];
}

- (UIImage *)imageResize:(UIImage*)img andResizeTo:(CGSize)newSize
{
    CGFloat scale = [[UIScreen mainScreen]scale];
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [img drawInRect:CGRectMake(-newSize.width*scale/30, 0, newSize.width, newSize.height)];//有偏移，自己加了参数
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


- (void)loadTabPagesView
{
    if (_selectedIndex < _tabPages.count) {
        NSDictionary *dic = self.tabPages[_selectedIndex];
        NSString *tabName = dic[@"tabName"] ? [WXConvert NSString:dic[@"tabName"]] : @"";
        NSString *title = dic[@"title"] ? [WXConvert NSString:dic[@"title"]] : @"New Page";
        NSString *url = dic[@"url"] ? [WXConvert NSString:dic[@"url"]] : @"";
        NSInteger cache = dic[@"cache"] ? [WXConvert NSInteger:dic[@"cache"]] : 0;
        NSString *statusBarColor = dic[@"statusBarColor"];
        id params = dic[@"params"];
        
        //添加滚动视图
        UIScrollView *scoView = [[UIScrollView alloc] initWithFrame:CGRectMake(_selectedIndex * self.bodyView.frame.size.width, 0, self.bodyView.frame.size.width, self.bodyView.frame.size.height)];
        scoView.tag = TabBgScrollTag + _selectedIndex;
        [self.bodyView addSubview:scoView];
        
#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
            scoView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
#endif
        
        WXMainViewController *vc = [[WXMainViewController alloc] init];
        vc.url = [DeviceUtil rewriteUrl:url];
        vc.cache = cache;
        vc.params = params;
        vc.isChildSubview = YES;
        vc.pageName = tabName;
        vc.title = title;

        [_tabInstance.viewController addChildViewController:vc];
        [scoView addSubview:vc.view];
                
        CGRect frame = vc.view.frame;
        UIEdgeInsets safeArea = UIEdgeInsetsZero;
#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
            safeArea = self.view.safeAreaInsets;
        }
#endif
        if (statusBarColor) {
            frame = CGRectMake(0, safeArea.top, scoView.frame.size.width, scoView.frame.size.height - safeArea.top - safeArea.bottom);

            UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scoView.frame.size.width, safeArea.top)];
            statusView.backgroundColor = [WXConvert UIColor:statusBarColor];
            [scoView addSubview:statusView];
        } else {
            frame = CGRectMake(0, 0, scoView.frame.size.width, scoView.frame.size.height - safeArea.bottom);
        }
        vc.view.frame = frame;

        //下拉刷新
        if (_isRefreshListener) {
            scoView.contentSize = CGSizeMake(0, scoView.frame.size.height + 0.1);

            __weak typeof(self) ws = self;
            scoView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                NSDictionary *data = @{@"tabName":tabName, @"position":@(ws.selectedIndex)};
                [ws fireEvent:@"refreshListener" params:data];
            }];
        }
        
        //标记已加载过该视图
        [_childPageList addObject:dic];
        
        vc.isTabbarChildSelected = YES;
        vc.isTabbarChildView = YES;
        [_lifeTabPages setObject:vc forKey:[NSString stringWithFormat:@"%ld", _selectedIndex]];
    }
}

- (void)loadComponentView
{
    if (_selectedIndex - _tabPages.count < _subComps.count) {
        //添加滚动视图
        UIScrollView *scoView = [[UIScrollView alloc] initWithFrame:CGRectMake(_selectedIndex * self.bodyView.frame.size.width, 0, self.bodyView.frame.size.width, self.bodyView.frame.size.height)];
        scoView.tag = TabBgScrollTag + _selectedIndex;
        [self.bodyView addSubview:scoView];
        
        WeiuiTabbarPageComponent *com = self.subComps[_selectedIndex - _tabPages.count];
        UIView *view = com.view;
        CGRect frame = view.frame;
        frame.origin = CGPointMake(0, 0);
//        frame.size = scoView.frame.size;
        view.frame = frame;
        [scoView addSubview:view];

        scoView.contentSize = CGSizeMake(0, com.calculatedFrame.size.height);

        //下拉刷新
        if (_isRefreshListener) {
            scoView.contentSize = CGSizeMake(0, scoView.frame.size.height + 0.1);

            __weak typeof(WeiuiTabbarComponent) *ws = self;
            scoView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                NSDictionary *data = @{@"tabName":com.tabName, @"position":@(ws.selectedIndex)};
                [ws fireEvent:@"refreshListener" params:data];
            }];
        }
        
        //标记已加载该组件
        [_childComponentList addObject:com];
    }
}

//处理滚动或点击到当前页面再加载
- (void)loadSelectedView
{
    //先处理生命周期
    [self lifeCycleEvent];
    
    //判断数据源,优先子组件
    NSMutableArray *dataList = [NSMutableArray arrayWithCapacity:5];
    
    if (_tabPages.count > 0) {
        [dataList addObjectsFromArray:_tabPages];
    }
    
    if (_subComps.count > 0) {
        [dataList addObjectsFromArray:_subComps];
    }
    
    if (dataList.count > 0 && _selectedIndex < dataList.count) {
        id data = dataList[_selectedIndex];
        if ([data isKindOfClass:[WeiuiTabbarPageComponent class]]) {
            if (![_childComponentList containsObject:data]) {
                [self loadComponentView];
            }
        } else if ([data isKindOfClass:[NSDictionary class]]) {
            if (![_childPageList containsObject:data]) {
                [self loadTabPagesView];
            }
        }
    }
}

//处理生命周期，只处理tabPages
- (void)lifeCycleEvent
{
    //重现
    if (_selectedIndex < _tabPages.count) {
        NSString *key = [NSString stringWithFormat:@"%ld", _selectedIndex];
        WXMainViewController *vc = _lifeTabPages[key];
        if (vc) {
            vc.isTabbarChildSelected = YES;
            [vc liftCycleEvent:LifeCycleResume];
        }
    }
    
    //消失
    if (_lastSelectedIndex < _tabPages.count) {
        NSString *key = [NSString stringWithFormat:@"%ld", _lastSelectedIndex];
        WXMainViewController *vc = _lifeTabPages[key];
        if (vc) {
            vc.isTabbarChildSelected = NO;
            [vc liftCycleEvent:LifeCyclePause];
        }
    }
}

#pragma mark action
- (void)tabbarClick:(UIButton*)sender
{
    [self fireEvent:@"tabSelect" params:@{@"position":@(_selectedIndex)}];

    _lastSelectedIndex = _selectedIndex;
    _selectedIndex = sender.tag - TabItemBtnTag;
    
    if (_selectedIndex == _reSelectedIndex) {
        [self fireEvent:@"tabReselect" params:@{@"position":@(_selectedIndex)}];
    }

    _reSelectedIndex = _selectedIndex;
    
    [self reloadIndicator];
    
    [self loadSelectedView];
    
    [self.bodyView setContentOffset:CGPointMake(_selectedIndex * self.bodyView.frame.size.width, 0) animated:YES];
}

#pragma mark scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
#warning ssss
    if (scrollView == _bodyView || scrollView == _tabView) {
        NSDictionary *data = @{@"position":@(_selectedIndex), @"positionOffset":@"", @"positionOffsetPixels":@""};
        [self fireEvent:@"pageScrolled" params:data];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.bodyView) {
        _lastSelectedIndex = _selectedIndex;
        _selectedIndex = scrollView.contentOffset.x / scrollView.frame.size.width;

        [self reloadIndicator];

        [self loadSelectedView];
    }
}

#pragma mark methods
- (NSInteger)getTabPosition:(NSString*)name
{
    NSInteger index = 0;
    for (int i = 0; i < _subComps.count + _tabPages.count; i++) {
        UIButton *btn = (UIButton*)[self.tabView viewWithTag:TabItemBtnTag + i];
        if ([btn.titleLabel.text isEqualToString:name]) {
            index = i;
            break;
        }
    }
    return index;
}
- (NSString*)getTabName:(NSInteger)index
{
    if (index < self.tabNameList.count) {
        NSDictionary *dic = self.tabNameList[index];
        if (dic) {
            return dic[@"tabName"];
        }
    }
    return @"";
}
- (void)showMsg:(NSString*)tabName num:(NSInteger)num
{
    for (int i = 0; i < _tabNameList.count; i++) {
        NSDictionary *dic = self.tabNameList[i];
        if (dic) {
            NSString *name = dic[@"tabName"];
            if ([name isEqualToString:tabName]) {
                UILabel *msgLab = (UILabel*)[_tabView viewWithTag:TabItemMessageTag + i];
                msgLab.text = [NSString stringWithFormat:@"%ld", num];
                msgLab.hidden = NO;
                break;
            }
        }
    }
}
- (void)showDot:(NSString*)tabName
{
    for (int i = 0; i < _tabNameList.count; i++) {
        NSDictionary *dic = self.tabNameList[i];
        if (dic) {
            NSString *name = dic[@"tabName"];
            if ([name isEqualToString:tabName]) {
                UIView *view = [_tabView viewWithTag:TabItemDotTag + i];
                view.hidden = NO;
                break;
            }
        }
    }
}

- (void)hideMsg:(NSString*)tabName
{
    for (int i = 0; i < _tabNameList.count; i++) {
        NSDictionary *dic = self.tabNameList[i];
        if (dic) {
            NSString *name = dic[@"tabName"];
            if ([name isEqualToString:tabName]) {
                UIView *view = [_tabView viewWithTag:TabItemDotTag + i];
                UILabel *msgLab = (UILabel*)[_tabView viewWithTag:TabItemMessageTag + i];

                view.hidden = YES;
                msgLab.hidden = YES;
                break;
            }
        }
    }
}

- (void)removePageAt:(NSString*)tabName
{
    for (int i = 0; i < _tabNameList.count; i++) {
        NSDictionary *dic = self.tabNameList[i];
        if (dic) {
            NSString *name = dic[@"tabName"];
            if ([name isEqualToString:tabName]) {
                if (i < _tabPages.count) {
                    [_tabPages removeObjectAtIndex:i];
                    [self loadTabPagesView];
                } else if (i < _tabPages.count + _subComps.count ){
                    [_subComps removeObjectAtIndex:i - _tabPages.count];
                    [self loadComponentView];
                }
                [self loadTabView];
                break;
            }
        }
    }
}

- (void)setCurrentItem:(NSString*)tabName
{
    for (int i = 0; i < _tabNameList.count; i++) {
        NSDictionary *dic = self.tabNameList[i];
        if (dic) {
            NSString *name = dic[@"tabName"];
            if ([name isEqualToString:tabName]) {
                _lastSelectedIndex = _selectedIndex;
                _selectedIndex = i;
                [self.bodyView setContentOffset:CGPointMake(_selectedIndex * self.bodyView.frame.size.width, 0) animated:YES];
                [self reloadIndicator];
                [self loadSelectedView];
                break;
            }
        }
    }
}

- (void)setRefreshing:(NSString*)tabName refresh:(BOOL)refresh
{
    for (int i = 0; i < _tabNameList.count; i++) {
        NSDictionary *dic = self.tabNameList[i];
        if (dic) {
            NSString *name = dic[@"tabName"];
            if ([name isEqualToString:tabName]) {
                UIScrollView *scoView = (UIScrollView*)[self.bodyView viewWithTag:TabBgScrollTag + i];
                if (refresh) {
                    [scoView.mj_header beginRefreshing];
                } else {
                    [scoView.mj_header endRefreshing];
                }
                break;
            }
        }
    }
}

- (void)goUrl:(NSString*)tabName url:(NSString*)url
{
    for (int i = 0; i < _tabNameList.count; i++) {
        NSDictionary *dic = self.tabNameList[i];
        if (dic) {
            NSString *name = dic[@"tabName"];
            if ([name isEqualToString:tabName]) {
                UIScrollView *scoView = (UIScrollView*)[self.bodyView viewWithTag:TabBgScrollTag + i];
                
                NSDictionary *dic = nil;
                for (int j = 0; j < self.tabPages.count; j++) {
                    NSDictionary *data = self.tabPages[j];
                    NSString *tname = data[@"tabName"] ? [WXConvert NSString:data[@"tabName"]] : @"";
                    if ([tabName isEqualToString:tname]) {
                        dic = data;
                        break;
                    }
                }
                
                NSString *title = dic[@"title"] ? [WXConvert NSString:dic[@"title"]] : @"New Page";
                NSInteger cache = dic[@"cache"] ? [WXConvert NSInteger:dic[@"cache"]] : 0;
                NSString *statusBarColor = dic[@"statusBarColor"];
                id params = dic[@"params"];
                
                WXMainViewController *vc = [[WXMainViewController alloc] init];
                vc.url = [DeviceUtil rewriteUrl:url];
                vc.cache = cache;
                vc.params = params;
                vc.isChildSubview = YES;
                vc.pageName = @"";
                vc.title = title;
                
                [_tabInstance.viewController addChildViewController:vc];
                [scoView addSubview:vc.view];
                
                CGRect frame = vc.view.frame;
                UIEdgeInsets safeArea = UIEdgeInsetsZero;
#ifdef __IPHONE_11_0
                if (@available(iOS 11.0, *)) {
                    safeArea = self.view.safeAreaInsets;
                } else {
                    // Fallback on earlier versions
                }
#endif
                if (statusBarColor) {
                    frame = CGRectMake(0, safeArea.top, scoView.frame.size.width, scoView.frame.size.height - safeArea.top - safeArea.bottom);
                    
                    UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scoView.frame.size.width, safeArea.top)];
                    statusView.backgroundColor = [WXConvert UIColor:statusBarColor];
                    [scoView addSubview:statusView];
                } else {
                    frame = CGRectMake(0, 0, scoView.frame.size.width, scoView.frame.size.height - safeArea.bottom);
                }
                vc.view.frame = frame;
                
                //下拉刷新
                if (_isRefreshListener) {
                    scoView.contentSize = CGSizeMake(0, scoView.frame.size.height + 0.1);
                    __weak typeof(WeiuiTabbarComponent) *ws = self;
                    scoView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                        NSDictionary *data = @{@"tabName":tabName, @"position":@(ws.selectedIndex)};
                        [ws fireEvent:@"refreshListener" params:data];
                    }];
                }
            }
            break;
        }
    }
}

- (void)reload:(NSString*)tabName
{
    
}

- (void)setTabType:(NSString*)tabType
{
    _ktabType = tabType;
    [self loadTabView];
}

- (void)setTabHeight:(NSInteger)tabHeight
{
    _ktabHeight = SCALE(tabHeight);
    [self loadTabView];
}

- (void)setTabBackgroundColor:(NSString*)tabBackgroundColor
{
    _ktabBackgroundColor = tabBackgroundColor;
    [self loadTabView];
}

- (void)setTabTextsize:(NSInteger)size
{
    _textSize = FONT(size);
    [self loadTabView];
}

- (void)setTabTextBold:(NSInteger)textBold
{
    _textBold = textBold;
    [self loadTabView];
}

- (void)setTabTextUnselectColor:(NSString*)textUnselectColor
{
    _textUnselectColor = textUnselectColor;
    [self loadTabView];
}

- (void)setTabTextSelectColor:(NSString*)textSelectColor
{
    _textSelectColor = textSelectColor;
    [self loadTabView];
}

- (void)setTabIconVisible:(BOOL)iconVisible
{
    _iconVisible = iconVisible;
    [self loadTabView];
}

- (void)setTabIconWidth:(NSInteger)iconWidth
{
    _iconWidth = SCALE(iconWidth);
    [self loadTabView];
}
- (void)setTabIconHeight:(NSInteger)iconHeight
{
    _iconHeight = SCALE(iconHeight);
    [self loadTabView];
}
- (void)setSideline:(NSInteger)sideLine
{
    _ksideLine = sideLine;
    [self loadTabView];
}



@end
