//
//  WeiuiRecylerComponent.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/5.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "WeiuiRecylerComponent.h"
#import "MJRefresh.h"
#import "DeviceUtil.h"

#define kCellTag 1000

static NSString * const cellID = @"cellID";

@interface WeiuiRecylerComponent() <UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSString *pullTipsDefault;
@property (nonatomic, strong) NSString *pullTipsLoad;
@property (nonatomic, strong) NSString *pullTipsNo;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) BOOL refreshAuto;
@property (nonatomic, assign) BOOL pullTips;
@property (nonatomic, assign) BOOL itemDefaultAnimator;
@property (nonatomic, assign) BOOL scrollEnabled;

@property (nonatomic, strong) NSMutableArray *subViews;
@property (nonatomic, strong) WXSDKInstance *tableInstance;

@property (nonatomic, assign) NSInteger lastVisibleItem;//最后显示的数据是第几条

@property (nonatomic, assign) BOOL isRefreshListener;
@property (nonatomic, assign) BOOL isPullLoadListener;

@property (nonatomic, assign) BOOL isTapGestureRecognizer;
@property (nonatomic, assign) BOOL isLongPressGestureRecognizer;

@property (nonatomic, assign) CGFloat scrolledY;
@end

@implementation WeiuiRecylerComponent

WX_EXPORT_METHOD(@selector(setRefreshing:))
WX_EXPORT_METHOD(@selector(refreshed))
WX_EXPORT_METHOD(@selector(refreshEnabled:))
WX_EXPORT_METHOD(@selector(setHasMore:))
WX_EXPORT_METHOD(@selector(pullloaded))
WX_EXPORT_METHOD(@selector(itemDefaultAnimator:))
WX_EXPORT_METHOD(@selector(scrollToPosition:))
WX_EXPORT_METHOD(@selector(smoothScrollToPosition:))

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    if (self) {
        
        _pullTipsDefault =  @"正在加载数据...";
        _pullTipsLoad = @"正在加载更多...";
        _pullTipsNo = @"没有更多数据了";
        _refreshAuto = NO;
        _pullTips = YES;
        _itemDefaultAnimator = NO;
        _scrollEnabled = YES;
        _row = 1;

        for (NSString *key in styles.allKeys) {
            [self dataKey:key value:styles[key] isUpdate:NO];
        }
        for (NSString *key in attributes.allKeys) {
            [self dataKey:key value:attributes[key] isUpdate:NO];
        }
        
        self.subViews = [NSMutableArray arrayWithCapacity:5];
        self.lastVisibleItem = 0;
        self.scrolledY = 0;
        
        _isRefreshListener = [events containsObject:@"refreshListener"];
        _isPullLoadListener = [events containsObject:@"pullLoadListener"];
    }
    
    return self;
}

- (UIView*)loadView
{
    return [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
}

- (void)viewDidLoad
{
    UICollectionView *collectionView = (UICollectionView*)self.view;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.clipsToBounds = YES;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
//    collectionView.bounces = NO;
    collectionView.scrollEnabled = _scrollEnabled;

#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
#endif

    __weak typeof(self) ws = self;
    if (_isRefreshListener) {
        collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            NSDictionary *data = @{@"realLastPosition":@(ws.subViews.count), @"lastVisibleItem":@(ws.lastVisibleItem)};
            [ws fireEvent:@"refreshListener" params:data];
        }];
        if (_refreshAuto) {
            [collectionView.mj_header beginRefreshing];
        }
    }
    
    if (_isRefreshListener) {
        MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
            NSDictionary *data = @{@"realLastPosition":@(ws.subViews.count), @"lastVisibleItem":@(ws.lastVisibleItem)};
            [ws fireEvent:@"pullLoadListener" params:data];
        }];
        [footer setTitle:_pullTipsDefault forState:MJRefreshStatePulling];
        [footer setTitle:_pullTipsLoad forState:MJRefreshStateRefreshing];
        [footer setTitle:_pullTipsNo forState:MJRefreshStateNoMoreData];
        collectionView.mj_footer = footer;
        
        collectionView.mj_footer.hidden = !_pullTips;
    }
   
    [self fireEvent:@"ready" params:nil];
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

//- (void)_insertSubcomponent:(WXComponent *)subcomponent atIndex:(NSInteger)index;
//{
//
//}

- (void)insertSubview:(WXComponent *)subcomponent atIndex:(NSInteger)index
{
    if (![_subViews containsObject:subcomponent]) {
        if (_subViews.count == 0) {
            [_subViews addObject:subcomponent];
        } else {
            [_subViews insertObject:subcomponent atIndex:index];
        }
    }
    
    [self performSelector:@selector(updateCollectionViewIfNeed) withObject:nil afterDelay:0.1];
}

- (void)updateCollectionViewIfNeed
{
    // 取消之前执行的请求
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateCollectionViewIfNeed) object:nil];
    
    UICollectionView *collectionView = (UICollectionView*)self.view;
    [collectionView reloadData];
}

- (void)willRemoveSubview:(WXComponent *)component;
{
    if ([_subViews containsObject:component]) {
        [_subViews removeObject:component];
        
        UICollectionView *collectionView = (UICollectionView*)self.view;
        [collectionView reloadData];
    }
}

- (void)addEvent:(NSString *)eventName
{
    if ([eventName isEqualToString:@"itemClick"]) {
        _isTapGestureRecognizer = YES;
    } else if ([eventName isEqualToString:@"itemLongClick"]) {
        _isLongPressGestureRecognizer = YES;
    }
}

- (void)removeEvent:(NSString *)eventName
{
    if ([eventName isEqualToString:@"itemClick"]) {
        _isTapGestureRecognizer = NO;
    } else if ([eventName isEqualToString:@"itemLongClick"]) {
        _isLongPressGestureRecognizer = NO;
    }
}

#pragma mark data
- (void)dataKey:(NSString*)key value:(id)value isUpdate:(BOOL)isUpdate
{
    key = [DeviceUtil convertToCamelCaseFromSnakeCase:key];
    if ([key isEqualToString:@"weiui"] && [value isKindOfClass:[NSDictionary class]]) {
        if (!isUpdate) {
            for (NSString *k in [value allKeys]) {
                [self dataKey:k value:value[k] isUpdate:isUpdate];
            }
        }
    } else if ([key isEqualToString:@"pullTipsDefault"]) {
        _pullTipsDefault = [WXConvert NSString:value];
        if (isUpdate) {
            UICollectionView *collectionView = (UICollectionView*)self.view;
            MJRefreshAutoStateFooter *footer = (MJRefreshAutoStateFooter*)collectionView.mj_footer;
            [footer setTitle:_pullTipsDefault forState:MJRefreshStatePulling];
        }
    } else if ([key isEqualToString:@"pullTipsLoad"]) {
        _pullTipsLoad = [WXConvert NSString:value];
        if (isUpdate) {
            UICollectionView *collectionView = (UICollectionView*)self.view;
            MJRefreshAutoStateFooter *footer = (MJRefreshAutoStateFooter*)collectionView.mj_footer;
            [footer setTitle:_pullTipsLoad forState:MJRefreshStateRefreshing];
        }
    } else if ([key isEqualToString:@"pullTipsNo"]) {
        _pullTipsNo = [WXConvert NSString:value];
        if (isUpdate) {
            UICollectionView *collectionView = (UICollectionView*)self.view;
            MJRefreshAutoStateFooter *footer = (MJRefreshAutoStateFooter*)collectionView.mj_footer;
            [footer setTitle:_pullTipsNo forState:MJRefreshStateNoMoreData];
        }
    } else if ([key isEqualToString:@"refreshAuto"]) {
        _refreshAuto = [WXConvert BOOL:value];
        if (isUpdate) {
            UICollectionView *collectionView = (UICollectionView*)self.view;
            if (_refreshAuto) {
                [collectionView.mj_header beginRefreshing];
            } else {
                [collectionView.mj_header endRefreshing];
            }
        }
    }  else if ([key isEqualToString:@"itemDefaultAnimator"]) {
        _itemDefaultAnimator = [WXConvert BOOL:value];
    } else if ([key isEqualToString:@"pullTips"]) {
        _pullTips = [WXConvert BOOL:value];
        if (isUpdate) {
            UICollectionView *collectionView = (UICollectionView*)self.view;
            collectionView.mj_footer.hidden = !_pullTips;
        }
    } else if ([key isEqualToString:@"scrollEnabled"]) {
        _scrollEnabled = [WXConvert BOOL:value];
        if (isUpdate) {
            UICollectionView *collectionView = (UICollectionView*)self.view;
            collectionView.scrollEnabled = _scrollEnabled;
        }
    } else if ([key isEqualToString:@"row"]) {
        _row = [WXConvert NSInteger:value];
        if (isUpdate) {
            UICollectionView *collectionView = (UICollectionView*)self.view;
            [collectionView reloadData];
        }
    }
}

#pragma mark collectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    self.lastVisibleItem = _subViews.count;
    return _subViews.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WXComponent *cmp = _subViews[indexPath.row];
    UIView *view = cmp.view;

    CGFloat top = cmp.cssNode->style.margin[CSS_TOP];
    CGFloat bottom = cmp.cssNode->style.margin[CSS_BOTTOM];
    CGFloat width = self.view.frame.size.width / _row;
    return CGSizeMake(width, cmp.calculatedFrame.size.height + top + bottom);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
//    [cell.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
////        if (obj.tag >= kCellTag) {
//            [obj removeFromSuperview];
////        }
//    }];
    
    for (UIView *oldView in cell.contentView.subviews) {
        [oldView removeFromSuperview];
    }
    
    WXComponent *cmp = _subViews[indexPath.row];
    UIView *view = cmp.view;
    CGFloat left = cmp.cssNode->style.margin[CSS_LEFT];
    CGFloat top = cmp.cssNode->style.margin[CSS_TOP];

    CGRect frame = view.frame;
    frame.origin = CGPointMake(left, top);
    frame.size = CGSizeMake(frame.size.width, cmp.calculatedFrame.size.height);
    view.frame = frame;
    view.tag = kCellTag + indexPath.row;
    [cell.contentView addSubview:view];
    
    //添加手势
    UITapGestureRecognizer *tapRecognizer = nil;
    UILongPressGestureRecognizer * longRecognizer = nil;
    
    if (_isTapGestureRecognizer) {
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemPanClick:)];
        tapRecognizer.numberOfTapsRequired = 1;
        [view addGestureRecognizer:tapRecognizer];
    }
    
    //长按
    if (_isLongPressGestureRecognizer) {
        longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(itemLongClick:)];
        longRecognizer.minimumPressDuration = 1.0;
        [view addGestureRecognizer:longRecognizer];
    }
    
    // 如果长按确定偵測失败才會触发单击
    if (_isTapGestureRecognizer && _isLongPressGestureRecognizer) {
        [tapRecognizer requireGestureRecognizerToFail:longRecognizer];
    }
    
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSDictionary *res = @{@"x":@(0), @"y":@(scrollView.contentOffset.y*ScreeScale), @"dx":@(0), @"dy":@(fabs(scrollView.contentOffset.y - _scrolledY)*ScreeScale)};
    [self fireEvent:@"scrolled" params:res];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self fireEvent:@"scrollStateChanged" params:@{@"x":@(0), @"y":@(scrollView.contentOffset.y*ScreeScale), @"newState":@(0)}];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _scrolledY = scrollView.contentOffset.y;

    [self fireEvent:@"scrollStateChanged" params:@{@"x":@(0), @"y":@(scrollView.contentOffset.y*ScreeScale), @"newState":@(1)}];
}


#pragma mark action
- (void)itemPanClick:(UITapGestureRecognizer*)panRecognizer
{
    NSInteger index = panRecognizer.view.tag - kCellTag;
    [self fireEvent:@"itemClick" params:@{@"position":@(index)}];
}

- (void)itemLongClick:(UILongPressGestureRecognizer*)longRecognizer
{
    NSInteger index = longRecognizer.view.tag - kCellTag;
    [self fireEvent:@"itemLongClick" params:@{@"position":@(index)}];
}

#pragma mark methods
- (void)setRefreshing:(BOOL)refreshing
{
    UICollectionView *collectionView = (UICollectionView*)self.view;
    if (refreshing) {
        [collectionView.mj_header beginRefreshing];
    } else {
        [collectionView.mj_header endRefreshing];
    }
}

- (void)refreshed
{
    UICollectionView *collectionView = (UICollectionView*)self.view;
    [collectionView.mj_header endRefreshing];
}

- (void)refreshEnabled:(BOOL)isEnabled
{
    UICollectionView *collectionView = (UICollectionView*)self.view;
    if (isEnabled) {
        collectionView.mj_header.hidden = NO;
    } else {
        collectionView.mj_header.hidden = YES;
    }
}

- (void)setHasMore:(BOOL)hasMore
{
    UICollectionView *collectionView = (UICollectionView*)self.view;
    [collectionView.mj_footer endRefreshing];
    collectionView.mj_footer.hidden = !hasMore;
}

- (void)pullloaded
{
    UICollectionView *collectionView = (UICollectionView*)self.view;
    [collectionView.mj_footer endRefreshing];
}

- (void)itemDefaultAnimator:(BOOL)animator
{
    
}

- (void)scrollToPosition:(NSInteger)position
{
    [self performSelector:@selector(scrollCollectionView:) withObject:@{@"position":@(position), @"animated":@(NO)} afterDelay:0.1];
}

- (void)smoothScrollToPosition:(NSInteger)position
{
    [self performSelector:@selector(scrollCollectionView:) withObject:@{@"position":@(position), @"animated":@(YES)} afterDelay:0.1];
}

- (void)scrollCollectionView:(NSDictionary*)dic
{
    // 取消之前执行的请求
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollCollectionView:) object:nil];
    
    if (dic) {
        NSInteger position = [WXConvert NSInteger:dic[@"position"]];
        BOOL animated = [WXConvert BOOL:dic[@"animated"]];
        
        UICollectionView *collectionView = (UICollectionView*)self.view;
        
        NSIndexPath* indexPat = [NSIndexPath indexPathForRow:0 inSection:0];
        UICollectionViewScrollPosition scrollPostion = UICollectionViewScrollPositionTop;
        if (position == -1) {
            indexPat = [NSIndexPath indexPathForRow:_subViews.count - 1 inSection:0];
            scrollPostion = UICollectionViewScrollPositionBottom;
        } else if (position == 0) {
            scrollPostion = UICollectionViewScrollPositionTop;
        } else {
            if (position < _subViews.count) {
                indexPat = [NSIndexPath indexPathForRow:position inSection:0];
                scrollPostion = UICollectionViewScrollPositionCenteredVertically;
            }
        }
        
        @try{
            [collectionView scrollToItemAtIndexPath:indexPat atScrollPosition:scrollPostion animated:animated];
        }
        
        @catch (NSException *exception) {
            NSLog(@"NSException = %@", exception);
        }
    }
}

@end
