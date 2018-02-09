//
//  SGImageBrowser.m
//  SGImageBrowser
//
//  Created by 刘山国 on 2018/2/9.
//  Copyright © 2018年 山国. All rights reserved.
//

#import "SGImageBrowser.h"
#import "SGImageBrowserCell.h"
#import "UIApplication+SG.h"
#import "UIAlertController+SG.h"
#import <Photos/Photos.h>
#import "SDWebImage/SDWebImageManager.h"

//static CGFloat const kDefaultAlpha = 0.3;
static CGFloat const kCornerRadius = 3;
static CGFloat const kBorderWidth = .5;
static CGFloat const kLineSpacing = 20;
#define kmSCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define kmSCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height
#define kBorderColor [UIColor colorWithRed:1 green:1 blue:1 alpha:.2].CGColor

@interface SGImageBrowser ()

@property (nonatomic,copy  ) SGImageBrowserDataSourceGetter         dataSourceGetterBlock;
@property (weak, nonatomic) IBOutlet UICollectionView               *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout     *flowLayout;
@property (weak, nonatomic) IBOutlet UIButton                       *allImagesBtn;
@property (weak, nonatomic) IBOutlet UIButton                       *saveImageBtn;
@property (weak, nonatomic) IBOutlet UIView                         *successView;
@property (weak, nonatomic) IBOutlet UIButton                       *downLoadOriginImageBtn;
@property (nonatomic,assign) id                                     placeHolderImageOrName;
@property (nonatomic,assign) NSInteger                              currentIndex;
@property (nonatomic,assign) NSInteger                              totalCount;


@end

@implementation SGImageBrowser

// 发布版与本地运行版 Bundle 不一样，Pod打包的Bundle不是MainBundle
- (NSBundle *)loadBoundle {
//    NSBundle *currentBundle = [NSBundle mainBundle];
    NSBundle *podBundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [podBundle URLForResource:NSStringFromClass([self class]) withExtension:@"bundle"];
    NSBundle *currentBundle = [NSBundle bundleWithURL:url];
    return currentBundle;
}

#pragma mark - public

+ (instancetype)shared {
    static SGImageBrowser *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[SGImageBrowser alloc] initWithNibName:NSStringFromClass([self class]) bundle:[shared loadBoundle]];
    });
    return shared;
}

+ (instancetype)show:(UIImageView *)imageView {
    return [SGImageBrowser show:imageView autoLoadImageUrl:nil];
}

+ (instancetype)show:(UIImageView *)imageView autoLoadImageUrl:(id)autoLoadImageUrl {
    return [SGImageBrowser show:imageView autoLoadImageUrl:autoLoadImageUrl originImageUrl:nil];
}

+ (instancetype)show:(UIImageView *)imageView autoLoadImageUrl:(id)autoLoadImageUrl originImageUrl:(id)originImageUrl {
    return [SGImageBrowser show:imageView autoLoadImageUrl:autoLoadImageUrl originImageUrl:originImageUrl originImageSize:nil];
}

+ (instancetype)show:(UIImageView *)imageView autoLoadImageUrl:(id)autoLoadImageUrl originImageUrl:(id)originImageUrl originImageSize:(NSString*)originImageSize {
    return [SGImageBrowser show:0 totalCount:1 dataSource:^(NSInteger index, SGImageBrowserDataSourceBlock dataSourceBlock) {
        dataSourceBlock(imageView,nil,autoLoadImageUrl,originImageUrl,originImageSize);
    }];
}

+ (instancetype)show:(NSInteger)startIndex
          totalCount:(NSInteger)totalCount
          dataSource:(SGImageBrowserDataSourceGetter)dataSourceBlock {
    return [SGImageBrowser show:startIndex totalCount:totalCount placeHolderImageOrName:nil dataSource:dataSourceBlock];
}

+ (instancetype)show:(NSInteger)startIndex totalCount:(NSInteger)totalCount placeHolderImageOrName:(id)placeHolderImageOrName dataSource:(SGImageBrowserDataSourceGetter)dataSourceBlock {
    SGImageBrowser *imageBrowser = [SGImageBrowser shared];
    imageBrowser.placeHolderImageOrName = placeHolderImageOrName;
    imageBrowser.totalCount = totalCount;
    imageBrowser.dataSourceGetterBlock = dataSourceBlock;
    [imageBrowser.collectionView reloadData];
    [imageBrowser.collectionView setContentOffset:CGPointMake(startIndex * imageBrowser.collectionView.frame.size.width, 0) animated:NO];
    [imageBrowser showAtIndex:startIndex];
    return imageBrowser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.saveImageBtn.layer.cornerRadius = kCornerRadius;
    self.saveImageBtn.layer.masksToBounds = YES;
    self.saveImageBtn.layer.borderWidth = kBorderWidth;
    self.saveImageBtn.layer.borderColor = kBorderColor;
    self.allImagesBtn.layer.cornerRadius = kCornerRadius;
    self.allImagesBtn.layer.masksToBounds = YES;
    self.allImagesBtn.layer.borderWidth = kBorderWidth;
    self.allImagesBtn.layer.borderColor = kBorderColor;
    self.downLoadOriginImageBtn.layer.cornerRadius = kCornerRadius;
    self.downLoadOriginImageBtn.layer.masksToBounds = YES;
    self.downLoadOriginImageBtn.layer.borderWidth = kBorderWidth;
    self.downLoadOriginImageBtn.layer.borderColor = kBorderColor;
    [self.downLoadOriginImageBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    self.successView.layer.cornerRadius = 5;
    self.successView.layer.masksToBounds = YES;
    [self.collectionView registerNib:[UINib nibWithNibName:kSGImageBrowserCellID bundle:[self loadBoundle]] forCellWithReuseIdentifier:kSGImageBrowserCellID];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil ];
    [self handleDeviceOrientationDidChange];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - Delegate
#pragma mark UICollectionView Delegate and DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.totalCount;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SGImageBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSGImageBrowserCellID forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    self.dataSourceGetterBlock(indexPath.row, ^(UIImageView * _Nullable targetImageView, id  _Nullable targetImageOrName, id  _Nullable targetAutoLoadImageUrl, id  _Nullable targetOriginImageUrl, NSString * _Nullable targetOriginImageSize) {
        [cell setTargetImageView:targetImageView
                     imageOrName:targetImageOrName
                     autoLoadUrl:targetAutoLoadImageUrl
                       originUrl:targetOriginImageUrl
          placeHolderImageOrName:weakSelf.placeHolderImageOrName
                       imageSize:targetOriginImageSize];
    });
    cell.tag = indexPath.row;
    if (!cell.actionBlock) cell.actionBlock = [self actionBlock];
    return cell;
}

#pragma mark UIScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.downLoadOriginImageBtn setEnabled:NO];
    [self.downLoadOriginImageBtn setHidden:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.downLoadOriginImageBtn setEnabled:YES];
    NSInteger index = scrollView.contentOffset.x/kmSCREEN_WIDTH;
    self.currentIndex = index;
    SGImageBrowserCell *cell = (SGImageBrowserCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    if (!cell.downLoadedImageOrHaveNo && cell.imageSize) {
        [self resetDownLoadBtnTitleWithImageSize:cell.imageSize];
    } else {
        [self resetDownLoadBtnTitleWithImageSize:nil];
    }
    [self performSelector:@selector(showHideDownloadBtn:) withObject:@(cell.downLoadedImageOrHaveNo) afterDelay:.2];
}


#pragma actions

- (IBAction)tapCollectionView:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self hide];
}
- (IBAction)downLoadOriginImageBtnClick:(UIButton *)sender {
    SGImageBrowserCell *cell = (SGImageBrowserCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
    [cell downLoadOriginImage:^{
        [self.downLoadOriginImageBtn setHidden:YES];
    }];
}

- (IBAction)saveImageBtnClick:(id)sender {
    SGImageBrowserCell *cell = (SGImageBrowserCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
    [self saveImage:cell.imageView.image];
}
- (IBAction)allImagesBtnClick:(id)sender {
}

// cell 点击手势响应block
- (void(^)(UIView *view,SGImageBrowserGestureType tapTag,NSInteger index))actionBlock{
    __weak typeof(self) weakSelf = self;
    return ^(UIView *view,SGImageBrowserGestureType tapTag,NSInteger index){
        switch (tapTag) {
            case SGImageBrowserSingleTap:{
                [weakSelf hide];
            }
                break;
            case SGImageBrowserDoubleTap:{
                
            }
                break;
            case SGImageBrowserLongPress:{
                UIImageView *imageView = (UIImageView *)view;
                if (!imageView.image) break;
                [UIAlertController sheet:@"保存照片" onAction:^(NSUInteger buttonIndex, UIAlertController * _Nullable alertController) {
                    if (buttonIndex==1) [weakSelf saveImage:imageView.image];
                }];
            }
                break;
            default:
                break;
        }
    };
}

#pragma private

// 屏幕旋转后 更新 collectionView flowLayout
- (void)handleDeviceOrientationDidChange {
    [self.collectionView setFrame:CGRectMake(0, 0, kmSCREEN_WIDTH+kLineSpacing, kmSCREEN_HEIGHT)];
    [self.flowLayout setItemSize:CGSizeMake(kmSCREEN_WIDTH, kmSCREEN_HEIGHT)];
    [self.flowLayout setMinimumLineSpacing:kLineSpacing];
    [self.flowLayout setSectionInset:UIEdgeInsetsMake(0, 0, 0, kLineSpacing)];
    [self.collectionView setContentOffset:CGPointMake(self.currentIndex * self.collectionView.frame.size.width, 0) animated:NO];
}

// 第一次加载
- (void)showAtIndex:(NSInteger)startIndex{
    self.currentIndex = startIndex;
    __weak typeof(self) weakSelf = self;
    self.dataSourceGetterBlock(startIndex, ^(UIImageView * _Nullable originImageView, id  _Nullable targetImageOrName, id  _Nullable targetAutoLoadImageUrl, id  _Nullable targetOriginImageUrl, NSString * _Nullable targetOriginImageSize) {
        // 显示
        UIImage *image = nil;
        if (targetImageOrName) {
            if ([targetImageOrName isKindOfClass:[NSString class]]) {
                image = [UIImage imageNamed:targetImageOrName];
            } else {
                image = targetImageOrName;
            }
        } else {
            image = originImageView.image;
        }
        if (image == nil) image = self.placeHolderImageOrName;
        
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setBackgroundColor:[UIColor blackColor]];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [window addSubview:imageView];
        if (originImageView) {
            imageView.frame = [originImageView convertRect:originImageView.bounds toView:window];
        } else {
            imageView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2, 0, 0);
        }
        [imageView setImage:image];
        if ([targetOriginImageUrl isKindOfClass:[NSString class]]) targetOriginImageUrl = [NSURL URLWithString:(NSString*)targetOriginImageUrl];
        [UIView animateWithDuration:0.3 animations:^{
            imageView.frame = window.bounds;
        } completion:^(BOOL finished) {
            UIViewController *controller = [[UIApplication sharedApplication] topViewController];
            [controller presentViewController:self animated:NO completion:^{
                // 加载图片是否"查看原图"的btn
                if (targetOriginImageUrl) {
                    [[SDWebImageManager sharedManager] diskImageExistsForURL:targetOriginImageUrl completion:^(BOOL isInCache) {
                        [weakSelf.downLoadOriginImageBtn setHidden:isInCache];
                        if (!isInCache && targetOriginImageSize) {
                            [weakSelf resetDownLoadBtnTitleWithImageSize:targetOriginImageSize];
                        } else {
                            [weakSelf resetDownLoadBtnTitleWithImageSize:nil];
                        }
                        [weakSelf showHideDownloadBtn:@(isInCache)];
                        if (weakSelf.totalCount == 0) [weakSelf.downLoadOriginImageBtn setHidden:YES];;
                    }];
                } else {
                    [weakSelf resetDownLoadBtnTitleWithImageSize:nil];
                    [weakSelf showHideDownloadBtn:@(YES)];
                }
                if (weakSelf.totalCount == 0) {
                    [weakSelf.downLoadOriginImageBtn setHidden:YES];
                    [weakSelf.saveImageBtn setHidden:YES];
                    [weakSelf.allImagesBtn setHidden:YES];
                }
            }];
            [UIView animateWithDuration:.5 animations:^{
                imageView.alpha = 0;
            } completion:^(BOOL finished) {
                [imageView removeFromSuperview];
            }];
        }];
        
    });
    
}

// 隐藏
- (void)hide {
    SGImageBrowserCell *cell = nil;
    if (self.totalCount>0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
        cell = (SGImageBrowserCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    }
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setBackgroundColor:[UIColor blackColor]];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setFrame:window.bounds];
    [imageView setImage:cell.imageView.image];
    [window addSubview:imageView];
    [self dismissViewControllerAnimated:NO completion:nil];
    [UIView animateWithDuration:0.3 animations:^{
        if (cell) {
            imageView.frame = cell.originImageViewFrameInWindow;
        } else {
            imageView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2, 0, 0);
        }
        imageView.alpha = 0;
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
    }];
}

// 显示保存成功的View
- (void)successViewShow {
    [self.successView setHidden:NO];
    [UIView animateWithDuration:0.1 animations:^{
        self.successView.alpha = 1;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(successViewHide) withObject:nil afterDelay:1.3];
    }];
}

// 隐藏保存成功的View
- (void)successViewHide {
    [UIView animateWithDuration:0.2 animations:^{
        self.successView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.successView setHidden:YES];
    }];
}

// 设置查看原图是否隐藏
- (void)showHideDownloadBtn:(NSNumber*)hide {
    [self.downLoadOriginImageBtn setHidden:[hide boolValue]];
}

// 重设查看原图button title
- (void)resetDownLoadBtnTitleWithImageSize:(NSString*)imageSize {
    if (imageSize) {
        [self.downLoadOriginImageBtn setTitle:[NSString stringWithFormat:@"查看原图(%@)",imageSize] forState:UIControlStateNormal];
    } else {
        [self.downLoadOriginImageBtn setTitle:@"查看原图" forState:UIControlStateNormal];
    }
}

// 保存照片
- (void)saveImage:(UIImage *)image {
    if (image) {
         UIImageWriteToSavedPhotosAlbum(image,self,@selector(image:didFinishSavingWithError:contextInfo:),NULL);
    } else {
        [UIAlertController alert:@"图片不存在！"];
    }
}

// 保存照片结果
- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    if (error) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
                [UIAlertController alert:nil message:@"App没有把图片保存到相册的权限，需要您去设置！" cancelBtn:@"不保存了" otherBtns:@"去设置" onAction:^(NSUInteger buttonIndex, UIAlertController * _Nullable alertController) {
                    if (buttonIndex) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }];
            } else {
                [UIAlertController alert:@"图片保存失败！"];
            }
        }];
        
    } else {
        [self successViewShow];
    }
}

#pragma mark - Setter

- (void)setPlaceHolderImageOrName:(id)placeHolderImageOrName {
    if ([placeHolderImageOrName isKindOfClass:[NSString class]]) {
        _placeHolderImageOrName = [UIImage imageNamed:placeHolderImageOrName];
    } else {
        _placeHolderImageOrName = placeHolderImageOrName;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
