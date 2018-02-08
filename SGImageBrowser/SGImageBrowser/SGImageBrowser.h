//
//  SGImageBrowser.h
//  WXHelper
//
//  Created by 刘山国 on 16/3/31.
//  Copyright © 2016年 山国. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 数据源回调block.

 @param targetImageView 第index个 imageView _Nullable
 @param targetImageOrName 第index个 image
 @param targetAutoLoadImageUrl  第index个 自动下载更清晰的图片url String or URL nullable
 @param targetOriginImageUrl 第index个 高清图片url可用于显示原图的按钮，当autoLoadUrl不存在时使用这个url String or URL nullable
 @param targetOriginImageSize 第index个 高清图片大小 NSString，设置好NSString直接填充
 */
typedef void (^SGImageBrowserDataSourceBlock)(UIImageView * _Nullable targetImageView, id _Nullable targetImageOrName, id _Nullable targetAutoLoadImageUrl, id _Nullable targetOriginImageUrl, NSString * _Nullable targetOriginImageSize);
typedef void (^SGImageBrowserDataSourceGetter)(NSInteger index, SGImageBrowserDataSourceBlock _Nonnull dataSourceBlock);

@interface SGImageBrowser : UIView

/**
 单例
 
 @return SGImageBrowser
 */
+ (instancetype _Nonnull )shared;

/**
 * 全屏浏览一张图片
 
 * @param imageView 展示的imageView
 * @param autoLoadImageUrl 自动下载更清晰的图片url String or URL nullable
 * @param originImageUrl 原图url
 * @param originImageSize 原图图片大小 NSString，设置好NSString直接填充
 * @return SGImageBrowser
 */
+ (instancetype _Nonnull)show:(UIImageView * _Nullable)imageView autoLoadImageUrl:(id _Nullable)autoLoadImageUrl originImageUrl:(id _Nullable)originImageUrl originImageSize:(NSString* _Nullable)originImageSize;
+ (instancetype _Nonnull )show:(UIImageView *_Nullable)imageView autoLoadImageUrl:(id _Nullable )autoLoadImageUrl originImageUrl:(id _Nullable )originImageUrl;
+ (instancetype _Nonnull )show:(UIImageView *_Nullable)imageView autoLoadImageUrl:(id _Nullable )autoLoadImageUrl;
+ (instancetype _Nonnull )show:(UIImageView *_Nullable)imageView;

/**
 * 全屏浏览一组图片
 
 * @param startIndex 当前组的第startIndex开始展示
 * @param totalCount 展示的总数
 * @param placeHolderImageOrName 当滑动到没有预览图时可以展示 placeHolderImageOrName nullable
 * @param dataSourceBlock (UIImageView * _Nonnull targetImageView, id _Nullable targetImageOrName, id _Nullable targetAutoLoadImageUrl, id _Nullable targetOriginImageUrl) 异步获取第i个展示的数据源
 * @return SGImageBrowser
 */
+ (instancetype _Nonnull )show:(NSInteger)startIndex totalCount:(NSInteger)totalCount placeHolderImageOrName:(id _Nullable )placeHolderImageOrName dataSource:(SGImageBrowserDataSourceGetter _Nonnull )dataSourceBlock;
+ (instancetype _Nonnull )show:(NSInteger)startIndex totalCount:(NSInteger)totalCount dataSource:(SGImageBrowserDataSourceGetter _Nonnull )dataSourceBlock;

@end
