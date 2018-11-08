//
//  WeiuiPictureSelectorModule.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/8.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "WeiuiPictureSelectorModule.h"
#import "TZImagePickerController.h"
#import "DeviceUtil.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "ZLShowMultimedia.h"
#import "ImagePreviewViewController.h"

@interface WeiuiPictureSelectorModule ()<TZImagePickerControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (strong, nonatomic) CLLocation *location;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, copy) WXModuleKeepAliveCallback callback;
@property (nonatomic, strong) NSMutableArray *selectedPhotos;
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, strong) NSString *pageName;

@end

@implementation WeiuiPictureSelectorModule

WX_EXPORT_METHOD(@selector(create:callback:))
WX_EXPORT_METHOD(@selector(compressImage:callback:))
WX_EXPORT_METHOD(@selector(picturePreview:paths:callback:))
WX_EXPORT_METHOD(@selector(videoPreview:))
WX_EXPORT_METHOD(@selector(deleteCache))

- (void)create:(NSDictionary*)params callback:(WXModuleKeepAliveCallback)callback
{
    self.params = params;
    self.callback = callback;
    
    int tag =(arc4random() % 100) + 1000;//返回随机数
    self.pageName = [NSString stringWithFormat:@"picture-%d", tag];
    
    NSString *type = params[@"type"] ? [WXConvert NSString:params[@"type"]] : @"gallery";
    
    NSInteger gallery = params[@"gallery"] ? [WXConvert NSInteger:params[@"gallery"]] : 0;
    NSInteger maxNum = params[@"maxNum"] ? [WXConvert NSInteger:params[@"maxNum"]] : 9;
    NSInteger minNum = params[@"minNum"] ? [WXConvert NSInteger:params[@"minNum"]] : 0;
    
    NSInteger spanCount = params[@"spanCount"] ? [WXConvert NSInteger:params[@"spanCount"]] : 4;
    NSInteger recordVideoSecond = params[@"recordVideoSecond"] ? [WXConvert NSInteger:params[@"recordVideoSecond"]] : 60;

    BOOL camera = params[@"camera"] ? [WXConvert BOOL:params[@"camera"]] : YES;
    BOOL gif = params[@"gif"] ? [WXConvert BOOL:params[@"gif"]] : NO;
    BOOL crop = params[@"crop"] ? [WXConvert BOOL:params[@"crop"]] : NO;
    BOOL circle = params[@"circle"] ? [WXConvert BOOL:params[@"circle"]] : NO;
    BOOL compress = params[@"compress"] ? [WXConvert BOOL:params[@"compress"]] : NO;
    
    NSDictionary *result = @{@"pageName":self.pageName, @"status":@"create", @"lists":@[]};
    self.callback(result, YES);
    
    if ([type isEqualToString:@"camera"]) {
        [self takePhoto];
        return;
    }
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:maxNum columnNumber:spanCount delegate:self pushPhotoPickerVc:YES];
    // imagePickerVc.navigationBar.translucent = NO;
    
#pragma mark - 五类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = YES;
//
//    if (self.maxCountTF.text.integerValue > 1) {
//        // 1.设置目前已经选中的图片数组
//        imagePickerVc.selectedAssets = _selectedAssets; // 目前已经选中的图片数组
//    }
    imagePickerVc.allowTakePicture = camera; // 在内部显示拍照按钮
//    imagePickerVc.allowTakeVideo = self.showTakeVideoBtnSwitch.isOn;   // 在内部显示拍视频按
    imagePickerVc.videoMaximumDuration = recordVideoSecond; // 视频最大拍摄时间
    [imagePickerVc setUiImagePickerControllerSettingBlock:^(UIImagePickerController *imagePickerController) {
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    }];
    
    // imagePickerVc.photoWidth = 1000;
    
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
    // if (iOS7Later) {
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // }
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    // imagePickerVc.navigationBar.translucent = NO;
    imagePickerVc.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
    imagePickerVc.showPhotoCannotSelectLayer = YES;
    imagePickerVc.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [imagePickerVc setPhotoPickerPageUIConfigBlock:^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) {
        [doneButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }];
    /*
     [imagePickerVc setAssetCellDidSetModelBlock:^(TZAssetCell *cell, UIImageView *imageView, UIImageView *selectImageView, UILabel *indexLabel, UIView *bottomView, UILabel *timeLength, UIImageView *videoImgView) {
     cell.contentView.clipsToBounds = YES;
     cell.contentView.layer.cornerRadius = cell.contentView.tz_width * 0.5;
     }];
     */
    
    // 3. Set allow picking video & photo & originalPhoto or not
    // 3. 设置是否可以选择视频/图片/原图
    switch (gallery) {
        case 0:
            imagePickerVc.allowPickingVideo = YES;
            imagePickerVc.allowPickingImage = YES;
            break;
        case 1:
            imagePickerVc.allowPickingVideo = NO;
            imagePickerVc.allowPickingImage = YES;
            break;
        case 2:
            imagePickerVc.allowPickingVideo = YES;
            imagePickerVc.allowPickingImage = NO;
            break;
        case 3:
            imagePickerVc.allowPickingVideo = YES;
            imagePickerVc.allowPickingImage = NO;
            break;
            
        default:
            break;
    }
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.allowPickingGif = gif;
//    imagePickerVc.allowPickingMultipleVideo = self.allowPickingMuitlpleVideoSwitch.isOn; // 是否可以多选视频
    
    // 4. 照片排列按修改时间升序
//    imagePickerVc.sortAscendingByModificationDate = self.sortAscendingSwitch.isOn;
    
     imagePickerVc.minImagesCount = minNum;
    // imagePickerVc.alwaysEnableDoneBtn = YES;
    
    // imagePickerVc.minPhotoWidthSelectable = 3000;
    // imagePickerVc.minPhotoHeightSelectable = 2000;
    
    /// 5. Single selection mode, valid when maxImagesCount = 1
    /// 5. 单选模式,maxImagesCount为1时才生效
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.allowCrop = crop;
    imagePickerVc.needCircleCrop = circle;
    // 设置竖屏下的裁剪尺寸
//    NSInteger left = 30;
//    NSInteger widthHeight = self.view.tz_width - 2 * left;
//    NSInteger top = (self.view.tz_height - widthHeight) / 2;
//    imagePickerVc.cropRect = CGRectMake(left, top, widthHeight, widthHeight);
    // 设置横屏下的裁剪尺寸
    // imagePickerVc.cropRectLandscape = CGRectMake((self.view.tz_height - widthHeight) / 2, left, widthHeight, widthHeight);
    /*
     [imagePickerVc setCropViewSettingBlock:^(UIView *cropView) {
     cropView.layer.borderColor = [UIColor redColor].CGColor;
     cropView.layer.borderWidth = 2.0;
     }];*/
    
    //imagePickerVc.allowPreview = NO;
    // 自定义导航栏上的返回按钮
    /*
     [imagePickerVc setNavLeftBarButtonSettingBlock:^(UIButton *leftButton){
     [leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
     [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 20)];
     }];
     imagePickerVc.delegate = self;
     */
    
    // Deprecated, Use statusBarStyle
    // imagePickerVc.isStatusBarDefault = NO;
    imagePickerVc.statusBarStyle = UIStatusBarStyleLightContent;
    
    // 设置是否显示图片序号
//    imagePickerVc.showSelectedIndex = self.showSelectedIndexSwitch.isOn;
    
    // 设置首选语言 / Set preferred language
    // imagePickerVc.preferredLanguage = @"zh-Hans";
    
    // 设置languageBundle以使用其它语言 / Set languageBundle to use other language
    // imagePickerVc.languageBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"tz-ru" ofType:@"lproj"]];
    
#pragma mark - 到这里为止

    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    
    __weak typeof(self) ws = self;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {

        ws.selectedAssets = [NSMutableArray arrayWithArray:assets];
        ws.selectedPhotos = [NSMutableArray arrayWithArray:photos];
        
        NSMutableArray *list = [NSMutableArray arrayWithCapacity:assets.count];
        for (int i = 0; i < assets.count; i++) {
            PHAsset *asset = assets[i];
            UIImage *img = photos[i];
            
            NSString *filename = [asset valueForKey:@"filename"];
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
            NSString *imgPath = [NSString stringWithFormat:@"%@/%@", path, filename];
            
            //压缩
            if (compress) {
                NSData *data = UIImageJPEGRepresentation(img, 1);
                NSInteger imgSize = data.length/1024;
                
                NSInteger compressSize = ws.params[@"compressSize"] ? [WXConvert NSInteger:ws.params[@"compressSize"]] : 100;
                if (compressSize < imgSize) {
                    [UIImageJPEGRepresentation(img, 0.5) writeToFile:imgPath atomically:YES];
                }
            } else {
               [UIImageJPEGRepresentation(img, 1.0) writeToFile:imgPath atomically:YES];
            }
            
            NSString *type = ws.params[@"type"] ? [WXConvert NSString:ws.params[@"type"]] : @"gallery";
            BOOL crop = ws.params[@"crop"] ? [WXConvert BOOL:ws.params[@"crop"]] : NO;

            NSDictionary *dic = @{@"path":imgPath, @"cutPath":imgPath, @"compressPath":imgPath, @"isCut":@(crop), @"compressed":@(compress), @"mimeType":type};
            [list addObject:dic];
        }
        
        if (self.callback) {
            NSDictionary *result = @{@"pageName":ws.pageName, @"status":@"success", @"lists":list};
            ws.callback(result, YES);

            NSDictionary *result2 = @{@"pageName":ws.pageName, @"status":@"destroy", @"lists":@[]};
            ws.callback(result2, NO);
        }
    }];
    
    [[DeviceUtil getTopviewControler] presentViewController:imagePickerVc animated:YES completion:nil];
}

- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        if (iOS7Later) {
            _imagePickerVc.navigationBar.barTintColor = [DeviceUtil getTopviewControler].navigationController.navigationBar.barTintColor;
        }
        _imagePickerVc.navigationBar.tintColor = [DeviceUtil getTopviewControler].navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (iOS9Later) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
        
    }
    return _imagePickerVc;
}

#pragma mark - UIImagePickerController

- (void)takePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) && iOS7Later) {
        // 无相机权限 做一个友好的提示
        if (iOS8Later) {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
            [alert show];
        } else {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        if (iOS7Later) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self takePhoto];
                    });
                }
            }];
        } else {
            [self takePhoto];
        }
        // 拍照之前还需要检查相册权限
    } else if ([TZImageManager authorizationStatus] == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
        if (iOS8Later) {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
            [alert show];
        } else {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
    } else if ([TZImageManager authorizationStatus] == 0) { // 未请求过相册权限
        [[TZImageManager manager] requestAuthorizationWithCompletion:^{
            [self takePhoto];
        }];
    } else {
        [self pushImagePickerController];
    }
}

// 调用相机
- (void)pushImagePickerController {
    // 提前定位
    __weak typeof(self) weakSelf = self;
    [[TZLocationManager manager] startLocationWithSuccessBlock:^(NSArray<CLLocation *> *locations) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.location = [locations firstObject];
    } failureBlock:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.location = nil;
    }];
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerVc.sourceType = sourceType;
        NSMutableArray *mediaTypes = [NSMutableArray array];
//        if (self.showTakeVideoBtnSwitch.isOn) {
//            [mediaTypes addObject:(NSString *)kUTTypeMovie];
//        }
        if ([WXConvert BOOL:self.params[@"camera"]]) {
            [mediaTypes addObject:(NSString *)kUTTypeImage];
        }
        if (mediaTypes.count) {
            _imagePickerVc.mediaTypes = mediaTypes;
        }
        if (iOS8Later) {
            _imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        [[DeviceUtil getTopviewControler] presentViewController:_imagePickerVc animated:YES completion:nil];
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //callback
    UIImage *img = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    NSString *filename = @"picture.jpg";
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *imgPath = [NSString stringWithFormat:@"%@/%@", path, filename];

    //压缩
    BOOL compress = self.params[@"compress"] ? [WXConvert BOOL:self.params[@"compress"]] : NO;
    if (compress) {
        NSData *data = UIImageJPEGRepresentation(img, 1);
        NSInteger imgSize = data.length/1024;
        
        NSInteger compressSize = self.params[@"compressSize"] ? [WXConvert NSInteger:self.params[@"compressSize"]] : 100;
        if (compressSize < imgSize) {
            [UIImageJPEGRepresentation(img, 0.5) writeToFile:imgPath atomically:YES];
        }
    } else {
        [UIImageJPEGRepresentation(img, 1.0) writeToFile:imgPath atomically:YES];
    }
    
    NSString *types = self.params[@"type"] ? [WXConvert NSString:self.params[@"type"]] : @"gallery";
    BOOL crop = self.params[@"crop"] ? [WXConvert BOOL:self.params[@"crop"]] : NO;
    
    NSDictionary *dic = @{@"path":path, @"cutPath":path, @"compressPath":path, @"isCut":@(crop), @"compressed":@(compress), @"mimeType":types};
    
    NSDictionary *result = @{@"pageName":self.pageName, @"status":@"success", @"lists":@[dic]};
    self.callback(result, YES);
    

    TZImagePickerController *tzImagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
//    tzImagePickerVc.sortAscendingByModificationDate = self.sortAscendingSwitch.isOn;
    [tzImagePickerVc showProgressHUD];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        // save photo and get asset / 保存图片，获取到asset
        [[TZImageManager manager] savePhotoWithImage:image location:self.location completion:^(NSError *error){
            if (error) {
                [tzImagePickerVc hideProgressHUD];
                NSLog(@"图片保存失败 %@",error);
            } else {
                [[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES needFetchAssets:NO completion:^(TZAlbumModel *model) {
                    [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
                        [tzImagePickerVc hideProgressHUD];
                        TZAssetModel *assetModel = [models firstObject];
                        if (tzImagePickerVc.sortAscendingByModificationDate) {
                            assetModel = [models lastObject];
                        }
                        if ([WXConvert BOOL:self.params[@"crop"]]) { // 允许裁剪,去裁剪
                            TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initCropTypeWithAsset:assetModel.asset photo:image completion:^(UIImage *cropImage, id asset) {
                                [self refreshCollectionViewWithAddedAsset:asset image:cropImage];
                            }];
                            imagePicker.needCircleCrop = [WXConvert BOOL:self.params[@"circle"]];
                            imagePicker.circleCropRadius = 100;
                            [[DeviceUtil getTopviewControler] presentViewController:imagePicker animated:YES completion:nil];
                        } else {
                            [self refreshCollectionViewWithAddedAsset:assetModel.asset image:image];
                        }
                    }];
                }];
            }
        }];
    } else if ([type isEqualToString:@"public.movie"]) {
        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        if (videoUrl) {
            [[TZImageManager manager] saveVideoWithUrl:videoUrl location:self.location completion:^(NSError *error) {
                if (!error) {
                    [[TZImageManager manager] getCameraRollAlbum:YES allowPickingImage:NO needFetchAssets:NO completion:^(TZAlbumModel *model) {
                        [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:YES allowPickingImage:NO completion:^(NSArray<TZAssetModel *> *models) {
                            [tzImagePickerVc hideProgressHUD];
                            TZAssetModel *assetModel = [models firstObject];
                            if (tzImagePickerVc.sortAscendingByModificationDate) {
                                assetModel = [models lastObject];
                            }
                            [[TZImageManager manager] getPhotoWithAsset:assetModel.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                                if (!isDegraded && photo) {
                                    [self refreshCollectionViewWithAddedAsset:assetModel.asset image:photo];
                                }
                            }];
                        }];
                    }];
                } else {
                    [tzImagePickerVc hideProgressHUD];
                }
            }];
        }
    }
}

- (void)refreshCollectionViewWithAddedAsset:(id)asset image:(UIImage *)image {
    [_selectedAssets addObject:asset];
    [_selectedPhotos addObject:image];
//    [_collectionView reloadData];

    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = asset;
        NSLog(@"location:%@",phAsset.location);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        if (self.callback) {
            NSDictionary *result = @{@"pageName":self.pageName, @"status":@"destroy", @"lists":@[]};
            self.callback(result, YES);
        }
    }
}


#pragma mark - TZImagePickerControllerDelegate

/// User click cancel button
/// 用户点击了取消
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    // NSLog(@"cancel");
}

// The picker should dismiss itself; when it dismissed these handle will be called.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[TZImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
//    _isSelectOriginalPhoto = isSelectOriginalPhoto;
//    [_collectionView reloadData];
    // _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
    
    // 1.打印图片名字
//    [self printAssetsName:assets];
    // 2.图片位置信息
    if (iOS8Later) {
        for (PHAsset *phAsset in assets) {
            NSLog(@"location:%@",phAsset.location);
        }
    }
    
    /*
     // 3. 获取原图的示例，这样一次性获取很可能会导致内存飙升，建议获取1-2张，消费和释放掉，再获取剩下的
     __block NSMutableArray *originalPhotos = [NSMutableArray array];
     __block NSInteger finishCount = 0;
     for (NSInteger i = 0; i < assets.count; i++) {
     [originalPhotos addObject:@1];
     }
     for (NSInteger i = 0; i < assets.count; i++) {
     PHAsset *asset = assets[i];
     [[TZImageManager manager] getOriginalPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info) {
     finishCount += 1;
     [originalPhotos replaceObjectAtIndex:i withObject:photo];
     if (finishCount >= assets.count) {
     NSLog(@"All finished.");
     }
     }];
     }
     */
}

// If user picking a video, this callback will be called.
// If system version > iOS8,asset is kind of PHAsset class, else is ALAsset class.
// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    _selectedPhotos = [NSMutableArray arrayWithArray:@[coverImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
    // open this code to send video / 打开这段代码发送视频
    [[TZImageManager manager] getVideoOutputPathWithAsset:asset presetName:AVAssetExportPreset640x480 success:^(NSString *outputPath) {
        NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
        // Export completed, send video here, send by outputPath or NSData
        // 导出完成，在这里写上传代码，通过路径或者通过NSData上传
        
        //callback
        NSString *types = self.params[@"type"] ? [WXConvert NSString:self.params[@"type"]] : @"gallery";
        BOOL crop = self.params[@"crop"] ? [WXConvert BOOL:self.params[@"crop"]] : NO;
        BOOL compress = self.params[@"compress"] ? [WXConvert BOOL:self.params[@"compress"]] : NO;

        NSDictionary *dic = @{@"path":outputPath, @"cutPath":outputPath, @"compressPath":outputPath, @"isCut":@(crop), @"compressed":@(compress), @"mimeType":types};
        
        NSDictionary *result = @{@"pageName":self.pageName, @"status":@"success", @"lists":@[dic]};
        if (self.callback) {
            self.callback(result, YES);
        }
    } failure:^(NSString *errorMessage, NSError *error) {
        NSLog(@"视频导出失败:%@,error:%@",errorMessage, error);
    }];
//    [_collectionView reloadData];
    // _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
}

// If user picking a gif image, this callback will be called.
// 如果用户选择了一个gif图片，下面的handle会被执行
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset {
    _selectedPhotos = [NSMutableArray arrayWithArray:@[animatedImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
//    [_collectionView reloadData];
}

// Decide album show or not't
// 决定相册显示与否
- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(id)result {
    /*
     if ([albumName isEqualToString:@"个人收藏"]) {
     return NO;
     }
     if ([albumName isEqualToString:@"视频"]) {
     return NO;
     }*/
    return YES;
}

// Decide asset show or not't
// 决定asset显示与否
- (BOOL)isAssetCanSelect:(id)asset {
    /*
     if (iOS8Later) {
     PHAsset *phAsset = asset;
     switch (phAsset.mediaType) {
     case PHAssetMediaTypeVideo: {
     // 视频时长
     // NSTimeInterval duration = phAsset.duration;
     return NO;
     } break;
     case PHAssetMediaTypeImage: {
     // 图片尺寸
     if (phAsset.pixelWidth > 3000 || phAsset.pixelHeight > 3000) {
     // return NO;
     }
     return YES;
     } break;
     case PHAssetMediaTypeAudio:
     return NO;
     break;
     case PHAssetMediaTypeUnknown:
     return NO;
     break;
     default: break;
     }
     } else {
     ALAsset *alAsset = asset;
     NSString *alAssetType = [[alAsset valueForProperty:ALAssetPropertyType] stringValue];
     if ([alAssetType isEqualToString:ALAssetTypeVideo]) {
     // 视频时长
     // NSTimeInterval duration = [[alAsset valueForProperty:ALAssetPropertyDuration] doubleValue];
     return NO;
     } else if ([alAssetType isEqualToString:ALAssetTypePhoto]) {
     // 图片尺寸
     CGSize imageSize = alAsset.defaultRepresentation.dimensions;
     if (imageSize.width > 3000) {
     // return NO;
     }
     return YES;
     } else if ([alAssetType isEqualToString:ALAssetTypeUnknown]) {
     return NO;
     }
     }*/
    return YES;
}

#pragma mark
- (void)compressImage:(NSDictionary*)params callback:(WXModuleKeepAliveCallback)callback
{
    BOOL isSave = NO;
    NSInteger compressSize = params[@"compressSize"] ? [WXConvert NSInteger:params[@"compressSize"]] : 100;
    NSMutableArray *list = [NSMutableArray arrayWithArray: params[@"lists"]];
    for (NSInteger i = 0; i < list.count; i++) {
        NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:list[i]];
        
        [mDic setObject:@(1) forKey:@"compressed"];
        
        NSString *path = [mDic objectForKey:@"path"];
        UIImage *img = [UIImage imageWithContentsOfFile:path];
       
        NSData *data = UIImageJPEGRepresentation(img, 1);
        NSInteger imgSize = data.length/1024;
        if (imgSize > compressSize) {
            isSave = [UIImageJPEGRepresentation(img, 0.5) writeToFile:path atomically:YES];
        }
        
        [list replaceObjectAtIndex:i withObject:mDic];
    }

    if (callback && list) {
        NSDictionary *res = @{@"status":isSave?@"success":@"error", @"lists":list};
        NSLog(@"%@", res);
        callback(res, YES);
    }
}

- (void)picturePreview:(NSInteger)index paths:(NSArray*)paths callback:(WXModuleKeepAliveCallback)callback
{
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:5];
    for (id dic in paths) {
        if ([dic isKindOfClass:[NSDictionary class]]) {
            if (dic[@"path"]) {
                [list addObject:dic[@"path"]];
            }
        } else if ([dic isKindOfClass:[NSString class]]) {
            [list addObject:dic];
        }
    }
    
    ImagePreviewViewController *vc = [[ImagePreviewViewController alloc] init];
    vc.index = index;
    vc.paths = list;
    vc.isAddDelete = callback ? YES : NO;
    vc.deleteBlock = ^(NSInteger dix) {
        if (callback) {
            callback(@{@"position":@(dix)}, YES);
        }
    };
    [[[DeviceUtil getTopviewControler] navigationController] pushViewController:vc
                                                                    animated:YES];
}

- (void)videoPreview:(NSString*)path
{
    if (path.length > 0) {
        ZLMediaInfo *info=[[ZLMediaInfo alloc]init];
        info.isLocal = YES;
        info.type = ZLMediaInfoTypeVideo;
        info.url = path;
        
        ZLShowMultimedia *zlShow = [[ZLShowMultimedia alloc]init];
        zlShow.infos = @[info];
        zlShow.currentIndex = 0;
        [zlShow show];
    }
}

- (void)deleteCache
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];

}

@end
