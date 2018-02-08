//
//  SGImageBrowserCell.m
//  E_Zhan
//
//  Created by 刘山国 on 2016/10/28.
//  Copyright © 2016年 山国. All rights reserved.
//

#import "SGImageBrowserCell.h"
#import "MBProgressHUD/MBProgressHUD.h"
#import "SDWebImage/SDWebImageDownloader.h"
#import "SDWebImage/UIImageView+WebCache.h"

static CGFloat const kMaximumZoomScale = 3.;
static CGFloat const kMiddleZoomScale  = 2.;
static CGFloat const kMinimumZoomScale = 1.;

@interface SGImageBrowserCell()<UIScrollViewDelegate>

@property (weak, nonatomic ) IBOutlet UIScrollView  *scrollView;
@property (nonatomic,assign) BOOL                   isScaleBigger;
@property (nonatomic,assign) CGFloat                doubleTapScale;
@property (nonatomic,copy  ) id                     originImageUrl; // String or URL

@end

@implementation SGImageBrowserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    [self.imageView addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.imageView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [self.imageView addGestureRecognizer:singleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
//    UISwipeGestureRecognizer * swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
//    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionDown];
//    [self.imageView addGestureRecognizer:swipeGesture];
    
    self.doubleTapScale = kMiddleZoomScale;
    //添加监听者
    [self.imageView addObserver:self forKeyPath: @"image" options:NSKeyValueObservingOptionNew context: nil];

    
    self.scrollView.showsHorizontalScrollIndicator = NO; //水平
    self.scrollView.showsVerticalScrollIndicator = NO; // 竖直
    self.scrollView.scrollEnabled=YES;
    self.scrollView.directionalLockEnabled = NO;
    self.scrollView.alwaysBounceVertical=NO;
    self.scrollView.alwaysBounceHorizontal= NO;
    self.scrollView.delegate=self;
    self.scrollView.autoresizesSubviews=YES;
    self.scrollView.maximumZoomScale=kMaximumZoomScale;
    self.scrollView.minimumZoomScale=kMinimumZoomScale;
    
}

/**
 *  监听属性值发生改变时回调
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    UIImageView *imageView = object;
    if (!imageView.image) return;
    CGFloat imageW = imageView.image.size.width;
    CGFloat imageH = imageView.image.size.height;
    
    CGFloat ratio ;
    CGFloat minus =imageW/imageH - [UIScreen mainScreen].bounds.size.width/[UIScreen mainScreen].bounds.size.height;
    if (fabs(minus) > 0.01 ) {//非屏幕等比图
        if (minus>0) {//宽图
            ratio = [UIScreen mainScreen].bounds.size.height/(imageH*([UIScreen mainScreen].bounds.size.width/imageW));
            if (ratio>kMiddleZoomScale) {
                self.doubleTapScale = ratio;
                if (ratio>kMaximumZoomScale) self.scrollView.maximumZoomScale = ratio;;
            }
        } else {//竖长图
            ratio = [UIScreen mainScreen].bounds.size.width/(imageW*([UIScreen mainScreen].bounds.size.height/imageH));
            if (ratio>kMiddleZoomScale) {
                self.doubleTapScale = ratio;
                if (ratio>kMaximumZoomScale) self.scrollView.maximumZoomScale = ratio;;
            }
        }
    }
    
}

- (void)downLoadOriginImage:(void (^)(void))finish {
    self.downLoadedImageOrHaveNo = YES;
    [self animotionDownloadImage:self.originImageUrl onFinish:finish];
}

- (void)animotionDownloadImage:(id)url {
    [self animotionDownloadImage:url onFinish:nil];
}

- (void)animotionDownloadImage:(id)url onFinish:(void (^)(void))finish{
    if (!url) return;
    if ([url isKindOfClass:[NSString class]]) url = [NSURL URLWithString:(NSString*)url];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeDeterminate;
    [self.imageView sd_setImageWithURL:url placeholderImage:self.imageView.image options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.progress = ((CGFloat)receivedSize)/((CGFloat)expectedSize);
        });
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [hud hideAnimated:YES];
        if (finish) finish();
    }];
}

- (void)setTargetImageView:(UIImageView *)targetImageView
               imageOrName:(id)imageOrName
               autoLoadUrl:(id)autoLoadUrl
                 originUrl:(id)originUrl
    placeHolderImageOrName:(id)placeHolderImageOrName
                 imageSize:(NSString*)imageSize {
    self.imageSize = imageSize;
    if ([autoLoadUrl isKindOfClass:[NSString class]]) autoLoadUrl = [NSURL URLWithString:(NSString*)autoLoadUrl];
    if ([originUrl isKindOfClass:[NSString class]]) originUrl = [NSURL URLWithString:(NSString*)originUrl];
    if ([placeHolderImageOrName isKindOfClass:[NSString class]]) placeHolderImageOrName = [UIImage imageNamed:placeHolderImageOrName];
    if ([imageOrName isKindOfClass:[NSString class]]) imageOrName = [UIImage imageNamed:imageOrName];
    UIImage *image = imageOrName;
    UIImage *placeHolderImage = placeHolderImageOrName;
    NSURL *url = autoLoadUrl;
    self.originImageUrl = originUrl;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (targetImageView) {
        self.originImageViewFrameInWindow = [targetImageView convertRect:targetImageView.bounds toView:window];
    } else {
        self.originImageViewFrameInWindow = CGRectMake(window.center.x, window.center.y, 0, 0);
    }
    if (!image && targetImageView.image) image = targetImageView.image;
    if (image) {
        self.imageView.image = image;
        placeHolderImage = image;
    } else {
        self.imageView.image = placeHolderImage;
    }
    self.downLoadedImageOrHaveNo = NO;
    if (originUrl) {
        __weak typeof(self) weakSelf = self;
        [[SDWebImageManager sharedManager] diskImageExistsForURL:originUrl completion:^(BOOL isInCache) {
            if (isInCache) {
                weakSelf.downLoadedImageOrHaveNo = YES;
                [weakSelf.imageView sd_setImageWithURL:originUrl placeholderImage:placeHolderImage];
            } else {
                if (url) {
                    if (image) {
                        [weakSelf.imageView sd_setImageWithURL:url placeholderImage:placeHolderImage];
                    } else {
                        [weakSelf animotionDownloadImage:url];
                    }
                } else {
                    weakSelf.downLoadedImageOrHaveNo = YES;
                    if (image) {
                        [weakSelf.imageView sd_setImageWithURL:originUrl placeholderImage:placeHolderImage];
                    } else {
                        [weakSelf animotionDownloadImage:originUrl];
                    }
                }
            }
        }];
    } else {
        self.downLoadedImageOrHaveNo = YES;
        if (image) {
            if (url) [self.imageView sd_setImageWithURL:url placeholderImage:placeHolderImage];
        } else {
            [self animotionDownloadImage:url];
        }
    }
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                        scrollView.contentSize.height * 0.5 + offsetY);
    
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (self.imageView.image) {
        return self.imageView;
    } else {
        return nil;
    }
    
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    
    if (!self.imageView.image) return;
    CGFloat imageW = self.imageView.image.size.width;
    CGFloat imageH = self.imageView.image.size.height;
    
    if (fabs(imageW/imageH - [UIScreen mainScreen].bounds.size.width/[UIScreen mainScreen].bounds.size.height) >0.001 && scale-1>0.001) {//非等比，并且放大倍数大于1
        
        CGFloat gap =0;
//        DLog(@"imageView--==%@",self.imageView);
        if (imageW/imageH > [UIScreen mainScreen].bounds.size.width/[UIScreen mainScreen].bounds.size.height) {
            CGFloat height = imageH*([UIScreen mainScreen].bounds.size.width/imageW);
            CGFloat tb = [UIScreen mainScreen].bounds.size.height - height;
            if (height*scale<[UIScreen mainScreen].bounds.size.height)  gap = ([UIScreen mainScreen].bounds.size.height-height*scale)/2;
            scrollView.contentInset = UIEdgeInsetsMake(-tb*scale/2+gap, 0, -tb*scale/2+gap, 0);
            
        } else {
            CGFloat width = imageW*([UIScreen mainScreen].bounds.size.height/imageH);
            CGFloat lr = [UIScreen mainScreen].bounds.size.width - width;
            if (width*scale<[UIScreen mainScreen].bounds.size.width) gap = ([UIScreen mainScreen].bounds.size.width-width*scale)/2;
            scrollView.contentInset = UIEdgeInsetsMake(0, -lr*scale/2+gap, 0, -lr*scale/2+gap);
        }
        
    }
    self.isScaleBigger = !self.isScaleBigger;
}

- (void)longPress:(UILongPressGestureRecognizer*)sender{
    if (sender.state == UIGestureRecognizerStateBegan && self.imageView.image) {
        if (self.actionBlock) self.actionBlock(self.imageView,SGImageBrowserLongPress,self.tag);
    }
}

- (void)singleTap:(UITapGestureRecognizer *)sender{
    if (self.actionBlock) self.actionBlock(self.imageView,SGImageBrowserSingleTap,self.tag);
}

- (void)doubleTap:(UITapGestureRecognizer *)sender{
    if (self.isScaleBigger) {
        [self.scrollView setZoomScale:1 animated:YES];
    } else {
        [self.scrollView setZoomScale:self.doubleTapScale animated:YES];
    }
    
}

- (void)swipeGesture:(UISwipeGestureRecognizer *)sender {
    if (self.actionBlock) self.actionBlock(self.imageView,SGImageBrowserSwipeDown,self.tag);
}


@end




