//
//  ImagePreviewViewController.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/10.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "ImagePreviewViewController.h"
#import "UIImage+TBCityIconFont.h"
#import "DeviceUtil.h"
#import "UIImageView+WebCache.h"

@interface ImagePreviewViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIColor *barColor;
@end

@implementation ImagePreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    if (_isAddDelete) {
        [self loadBarItemView];
    }
    
    [self loadPreviewView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];

//    self.barColor = self.navigationController.navigationBar.barTintColor;
//
    UIColor *barTintColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];

    self.navigationController.navigationBar.barTintColor = barTintColor;
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    self.barColor = statusBar.backgroundColor;
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = [barTintColor colorWithAlphaComponent:1];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = self.barColor;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = [self.barColor colorWithAlphaComponent:1];
    }
}

- (void)loadBarItemView
{
    UIImage *deleteImg = [DeviceUtil getIconText:@"android-delete" font:19 color:@"#ffffff"];

    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 44, 44);
    [rightBtn setImage:deleteImg forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 20, 0, -20);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
}

- (void)loadPreviewView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.paths.count, 0);
    [self.scrollView setContentOffset:CGPointMake(self.index * self.scrollView.frame.size.width, 0)];
    
    [self loadContentView];
}

- (void)loadContentView;
{
    self.title = [NSString stringWithFormat:@"%ld/%ld", self.index + 1, self.paths.count];
    
    for (int i = 0; i < self.paths.count; i++) {
        NSString *path = self.paths[i];
        if (path) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(i * self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
            imgView.backgroundColor = [UIColor clearColor];
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            [self.scrollView addSubview:imgView];
            
            if ([path hasPrefix:@"http"]) {
                [imgView sd_setImageWithURL:[NSURL URLWithString:path]];
            } else {
                UIImage *img = [UIImage imageWithContentsOfFile:path];
                if (img) {
                    imgView.image = img;
                } else {
                    //缓存
                    [imgView sd_setImageWithURL:[NSURL URLWithString:path]];
                }
            }
        }
    }
}


#pragma mark delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.index = scrollView.contentOffset.x / scrollView.frame.size.width + 1;
    
    self.title = [NSString stringWithFormat:@"%ld/%ld", self.index, self.paths.count];
}


#pragma mark action
- (void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteClick
{
    if (self.deleteBlock) {
        self.deleteBlock(self.index);
    }
    
    NSMutableArray *list = [NSMutableArray arrayWithArray:self.paths];
    [list removeObjectAtIndex:self.index];
    self.paths = list;
    
    if (list.count == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if (self.index == 0) {
            self.index = 0;
        } else {
            self.index = self.index - 1;
        }
        
        for (UIView *oldView in self.scrollView.subviews) {
            [oldView removeFromSuperview];
        }
        
        [self loadContentView];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
