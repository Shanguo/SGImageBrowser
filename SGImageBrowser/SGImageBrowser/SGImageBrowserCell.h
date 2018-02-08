//
//  SGImageBrowserCell.h
//  E_Zhan
//
//  Created by 刘山国 on 2016/10/28.
//  Copyright © 2016年 山国. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SGImageBrowserGestureType) {
    SGImageBrowserSingleTap           = 1,
    SGImageBrowserDoubleTap,
    SGImageBrowserLongPress,
    SGImageBrowserSwipeDown,
};

static NSString * const kSGImageBrowserCellID = @"SGImageBrowserCell";


@interface SGImageBrowserCell : UICollectionViewCell

@property (nonatomic,assign) BOOL downLoadedImageOrHaveNo;// 已下载origin或者没有originUrl
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic,assign) CGRect originImageViewFrameInWindow;
@property (nonatomic,copy  ) void(^actionBlock)( UIView *view, SGImageBrowserGestureType tapTag, NSInteger index);
@property (nonatomic,copy  ) NSString *imageSize;

- (void)downLoadOriginImage:(void(^)(void))finish;

- (void)setTargetImageView:(UIImageView *)targetImageView
               imageOrName:(id)imageOrName
               autoLoadUrl:(id)autoLoadUrl
                 originUrl:(id)originUrl
    placeHolderImageOrName:(id)placeHolderImageOrName
                 imageSize:(NSString*)imageSize;
@end
