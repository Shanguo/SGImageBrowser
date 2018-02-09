//
//  SGImageBrowser.m
//  WXHelper
//
//  Created by 刘山国 on 16/3/31.
//  Copyright © 2016年 山国. All rights reserved.
//

#import "SGImageBrowser.h"
#import "SGImageBrowserCell.h"
#import "UIAlertController+SG.h"
#import "SDWebImage/SDWebImageManager.h"
#import <Photos/Photos.h>
#import "UIApplication+SG.h"

static CGFloat const kDefaultAlpha = 0.3;
static CGFloat const kCornerRadius = 3;
static CGFloat const kBorderWidth = .5;
static CGFloat const kLineSpacing = 20;
#define kmSCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define kmSCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height
#define kBorderColor [UIColor colorWithRed:1 green:1 blue:1 alpha:.2].CGColor

@interface SGImageBrowser () <UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate>

@property (nonatomic,copy  ) SGImageBrowserDataSourceGetter    dataSourceGetterBlock;
@property (strong, nonatomic) IBOutlet SGImageBrowser               *contentView;
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

- (instancetype)init
{
    self = [super initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    if (self) {
        NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
        self.contentView = [[currentBundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];//(owner:self ，firstObject必要)
        self.contentView.frame = self.bounds;
        [self addSubview:self.contentView];
        [self.contentView setBackgroundColor:[UIColor blackColor]];
        [self.contentView addSubview:self.successView];
        [self.collectionView registerNib:[UINib nibWithNibName:kSGImageBrowserCellID bundle:currentBundle] forCellWithReuseIdentifier:kSGImageBrowserCellID];
        
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
        [self handleDeviceOrientationDidChange];
        
    }
    return self;
}

- (void)handleDeviceOrientationDidChange {
    self.frame = CGRectMake(0, 0, kmSCREEN_WIDTH, kmSCREEN_HEIGHT);
    self.contentView.frame = self.bounds;
    [self.collectionView setFrame:CGRectMake(0, 0, kmSCREEN_WIDTH+kLineSpacing, kmSCREEN_HEIGHT)];
    [self.flowLayout setItemSize:CGSizeMake(kmSCREEN_WIDTH, kmSCREEN_HEIGHT)];
    [self.flowLayout setMinimumLineSpacing:kLineSpacing];
    [self.flowLayout setSectionInset:UIEdgeInsetsMake(0, 0, 0, kLineSpacing)];
    [self.collectionView setContentOffset:CGPointMake(self.currentIndex * self.collectionView.frame.size.width, 0) animated:NO];
}

+ (instancetype)shared {
    static SGImageBrowser *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[SGImageBrowser alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:shared selector:@selector(handleDeviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil ];
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
    [imageBrowser show:startIndex totalCount:totalCount placeHolderImageOrName:placeHolderImageOrName dataSource:dataSourceBlock];
    return imageBrowser;
}

- (void)show:(NSInteger)startIndex {
    self.currentIndex = startIndex;
    [self.collectionView setContentOffset:CGPointMake(startIndex * self.collectionView.frame.size.width, 0) animated:NO];
    [self showAtIndex:startIndex];
}

- (void)show:(NSInteger)startIndex totalCount:(NSInteger)totalCount placeHolderImageOrName:(id)placeHolderImageOrName dataSource:(SGImageBrowserDataSourceGetter)dataSourceBlock {
    self.placeHolderImageOrName = placeHolderImageOrName;
    self.totalCount = totalCount;
    self.dataSourceGetterBlock = dataSourceBlock;
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointMake(startIndex * self.collectionView.frame.size.width, 0) animated:NO];
    [self showAtIndex:startIndex];
}


- (void)showAtIndex:(NSInteger)startIndex{
    self.currentIndex = startIndex;
    __weak typeof(self) weakSelf = self;
    self.dataSourceGetterBlock(startIndex, ^(UIImageView * _Nullable originImageView, id  _Nullable targetImageOrName, id  _Nullable targetAutoLoadImageUrl, id  _Nullable targetOriginImageUrl, NSString * _Nullable targetOriginImageSize) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIViewController *controller = [[UIApplication sharedApplication] topViewController];
        [[controller view] addSubview:weakSelf];
        UIImage *image = originImageView.image;
        UIImageView *imageView = [UIImageView new];
        CGRect lastRect = CGRectMake(window.center.x, window.center.y,0,0);
        if (originImageView) {
            imageView.frame = [originImageView convertRect:originImageView.bounds toView:window];
            imageView.image = image;
        } else {
            imageView.frame = lastRect;
        }
        [weakSelf addSubview:imageView];
        if (image) {
            lastRect = CGRectMake(0,
                                  ([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2,
                                  [UIScreen mainScreen].bounds.size.width,
                                  image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
        }
        [UIView animateWithDuration:0.3 animations:^{
            imageView.frame = lastRect;
            weakSelf.collectionView.alpha=1;
            weakSelf.alpha=1;
        } completion:^(BOOL finished) {
            [imageView removeFromSuperview];
        }];
        if (weakSelf.totalCount>0) [weakSelf.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:startIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        if (targetOriginImageUrl) {
            if ([targetOriginImageUrl isKindOfClass:[NSString class]]) targetOriginImageUrl = [NSURL URLWithString:(NSString*)targetOriginImageUrl];
            [[SDWebImageManager sharedManager] diskImageExistsForURL:targetOriginImageUrl completion:^(BOOL isInCache) {
                [weakSelf.downLoadOriginImageBtn setHidden:isInCache];
                if (!isInCache && targetOriginImageSize) {
                    [weakSelf resetDownLoadBtnTitleWithImageSize:targetOriginImageSize];
                } else {
                    [weakSelf resetDownLoadBtnTitleWithImageSize:nil];
                }
                [weakSelf showHideDownloadBtn:@(isInCache)];
            }];
        } else {
            [weakSelf resetDownLoadBtnTitleWithImageSize:nil];
            [weakSelf showHideDownloadBtn:@(YES)];
        }
    });
    
}

#pragma mark - UICollectionView Delegate and DataSource
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

#pragma action

- (IBAction)downLoadOriginImageBtnClick:(UIButton *)sender {
    SGImageBrowserCell *cell = (SGImageBrowserCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
    [cell downLoadOriginImage:^{
        [self.downLoadOriginImageBtn setHidden:YES];
    }];
}

- (IBAction)saveImageBtnClick:(id)sender {
    SGImageBrowserCell *cell = (SGImageBrowserCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
    UIImageWriteToSavedPhotosAlbum(cell.imageView.image,self,@selector(image:didFinishSavingWithError:contextInfo:),NULL);
}
- (IBAction)allImagesBtnClick:(id)sender {
}


#pragma private


- (void)showHideDownloadBtn:(NSNumber*)hide {
    [self.downLoadOriginImageBtn setHidden:[hide boolValue]];
}

- (void)resetDownLoadBtnTitleWithImageSize:(NSString*)imageSize {
    if (imageSize) {
        [self.downLoadOriginImageBtn setTitle:[NSString stringWithFormat:@"查看原图(%@)",imageSize] forState:UIControlStateNormal];
    } else {
        [self.downLoadOriginImageBtn setTitle:@"查看原图" forState:UIControlStateNormal];
    }
}

- (void(^)(UIView *view,SGImageBrowserGestureType tapTag,NSInteger index))actionBlock{
    __weak typeof(self) weakSelf = self;
    return ^(UIView *view,SGImageBrowserGestureType tapTag,NSInteger index){
        switch (tapTag) {
            case SGImageBrowserSingleTap:{
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                SGImageBrowserCell *cell = (SGImageBrowserCell *)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
                CGRect frame = cell.imageView.frame;
                [UIView animateWithDuration:0.3 animations:^{
                    cell.imageView.frame = cell.originImageViewFrameInWindow;
                    weakSelf.collectionView.alpha = kDefaultAlpha;
                    weakSelf.alpha = 0;
                } completion:^(BOOL finished) {
                    [weakSelf.downLoadOriginImageBtn setHidden:YES];
                    cell.imageView.frame = frame;
                    [weakSelf setAlpha:kDefaultAlpha];
                    [weakSelf removeFromSuperview];
                }];
            }
                break;
            case SGImageBrowserDoubleTap:{
                
            }
                break;
            case SGImageBrowserLongPress:{
                UIImageView *imageView = (UIImageView *)view;
                if (!imageView.image) break;
                [UIAlertController sheet:@"保存照片" onAction:^(NSUInteger buttonIndex, UIAlertController * _Nullable alertController) {
                    if (buttonIndex==1) UIImageWriteToSavedPhotosAlbum(imageView.image,self,@selector(image:didFinishSavingWithError:contextInfo:),NULL);
                }];
            }
                break;
            default:
                break;
        }
    };
}



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

- (void)successViewShow {
    [self.successView setHidden:NO];
    [UIView animateWithDuration:0.1 animations:^{
        self.successView.alpha = 1;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(successViewHide) withObject:nil afterDelay:1.3];
    }];
}

- (void)successViewHide {
    [UIView animateWithDuration:0.2 animations:^{
        self.successView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.successView setHidden:YES];
    }];
}



@end
