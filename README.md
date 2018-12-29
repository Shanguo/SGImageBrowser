# SGImageBrowser


安装
==============

### CocoaPods

1. 在 Podfile 中添加  `pod 'SGImageBrowser'`。
2. 执行 `pod install` 或 `pod update`。
3. 导入 `#import <SGImageBrowser.h>`。
4. [查看源代码](https://github.com/Shanguo/SGImageBrowser)


示例展示 Demo
==============

<img src="DemoImages/demo.gif" width="300">

使用 Usage
==============

### 只需要一个方法调用就可以放大浏览图片，下载图片，查看原图等。

- 1. 简单的ImageView全屏浏览图片

```
[SGImageBrowser show:self.imageView];        
```
- 2. 其他任意容器中的ImageView，下例为UICollectionCell的ImageView

```
__weak typeof(self) weakSelf = self;
/**
 * show: 点击了九宫格中的第i个图片，动画弹出第i个图片
 * totalCount: 照片总数
 * placeHolderImageOrName: 提供placeHolder可以为本地图片名称，或者UIImage
 * dataSource: 当滚动到第i个位置是，提供第i个位置的图片
 */
[SGImageBrowser show:indexPath.row totalCount:self.imgNames.count placeHolderImageOrName:nil dataSource:^(NSInteger index, SGImageBrowserDataSourceBlock  _Nonnull dataSourceBlock) {
    // 当滚动到某个位置时，提供那个位置的图片
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    //  懒加载midlleUrl中等大小的图片，点击查看原图按钮加载originUrl
    NSURL *middleUrl = [weakSelf imageUrlWithType:URL_Middle atIndex:index];
    NSURL *originUrl = [weakSelf imageUrlWithType:URL_Origin atIndex:index];
    /**
     * 第1个参数imageView: 为了退出浏览时，缩回动画，缩回到这个imageView的位置
     * 第2个参数: 提供第i个位置图片或者名称用于显示
     * 第3个参数: 提供第i个位置图片url 用于加载图片
     * 第4个参数: 提供第i个位置图片原图url,第2,3,4个参数必选一个才能显示图片
     * 第5个参数: 提供图片大小用于下载原图的按钮显示 @"1024KB"
     */
    dataSourceBlock(cell.imageView,nil,middleUrl,originUrl,@"1024KB");
}];        
```
- 3. 使用一组图片或者一组图片的url，浏览一组图片

```
// dataSourceBlock的5个参数说明: 数据源至少有一个提供图片的不为nil即可
// dataSourceBlock(UIImageView, 图片或者图片名称, 自动加载的url(NSString or NSURL), 原图或者高清图url, 图片大小字符串)
__weak typeof(self) weakSelf = self;
[SGImageBrowser show:0 totalCount:self.imgNames.count placeHolderImageOrName:nil dataSource:^(NSInteger index, SGImageBrowserDataSourceBlock  _Nonnull dataSourceBlock) {
    dataSourceBlock(nil, weakSelf.imgNames[index],nil,nil,nil);
}];  
```

API
==============

任意的imageView可以简单的快速全屏浏览。

```
/**
 数据源回调block.

 @param targetImageView 第index个 imageView _Nullable
 @param targetImageOrName 第index个 image 可以是本地图片的名称
 @param targetAutoLoadImageUrl  第index个 自动下载更清晰的图片url String or URL nullable
 @param targetOriginImageUrl 第index个 高清图片url可用于显示原图的按钮，当autoLoadUrl不存在时使用这个url String or URL nullable
 @param targetOriginImageSize 第index个 高清图片大小 NSString，设置好NSString直接填充
 */
typedef void (^SGImageBrowserDataSourceBlock)(UIImageView * _Nullable targetImageView, id _Nullable targetImageOrName, id _Nullable targetAutoLoadImageUrl, id _Nullable targetOriginImageUrl, NSString * _Nullable targetOriginImageSize);


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
            
```
