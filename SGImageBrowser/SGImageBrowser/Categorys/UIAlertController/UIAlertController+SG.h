//
//  UIAlertController+SG.h
//  SGAlertController
//
//  Created by 刘山国 on 2018/2/7.
//  Copyright © 2018年 山国. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * _Nonnull const kNowIt     = @"知道了";
static NSString * _Nonnull const kSure      = @"确定";
static NSString * _Nonnull const kCancel    = @"取消";

typedef void (^UIAlertControllerActionBlock)(NSUInteger buttonIndex, UIAlertController * _Nullable alertController);

@interface UIAlertController (SG)

/**
 *  弹出Alert 单按钮 参数：message  默认title ”提示“ 默认按钮 ”知道了“
 *
 *  @param message         内容
 *
 *  @return UIAlertController
 */
+ (instancetype _Nonnull )alert:(NSString *_Nonnull)message;

/**
 *  弹出Alert 单按钮 参数：title、message、confirmBtn
 *
 *  @param title             Title
 *  @param message           内容
 *  @param confirmBtn        确认按钮
 *
 *  @return UIAlertController
 */
+ (instancetype _Nonnull )alert:(NSString *_Nullable)title
                        message:(NSString *_Nonnull)message
                     confirmBtn:(NSString *_Nonnull)confirmBtn ;

/**
 *  弹出Alert 双按钮 参数：message、actionBlock  默认title ”提示“ ，按钮 “取消”、"确定"
 *
 *  @param message          内容
 *  @param actionBlock      选择结果回调
 *
 *  @return UIAlertController
 */
+ (instancetype _Nonnull )alert:(NSString *_Nonnull)message
                       onAction:(UIAlertControllerActionBlock _Nullable )actionBlock;

/**
 *  弹出Alert 自定义 参数：title、message、cancelTitle、otherBtns、actionBlock
 *
 *  @param title             Title
 *  @param message           内容
 *  @param cancelTitle       取消
 *  @param otherBtns         其他按钮
 *  @param actionBlock       选择结果回调
 *
 *  @return UIAlertController
 */
+ (instancetype _Nonnull )alert:(NSString *_Nullable)title
                        message:(NSString *_Nonnull)message
                      cancelBtn:(NSString *_Nullable)cancelTitle
                      otherBtns:(id _Nonnull)otherBtns
                       onAction:(UIAlertControllerActionBlock _Nullable )actionBlock ;

#pragma mark - ActionSheet

/**
 *  弹出ActionSheet 参数：actions、actionBlock
 *
 *  @param actions            其他按钮
 *  @param actionBlock       选择结果回调
 *
 *  @return UIAlertController
 */
+ (instancetype _Nonnull )sheet:(id _Nonnull)actions
                       onAction:(UIAlertControllerActionBlock _Nonnull )actionBlock ;
/**
 *  弹出ActionSheet 参数：title、actions、actionBlock
 *
 *  @param title             Title
 *  @param actions           其他按钮
 *  @param actionBlock       选择结果回调
 *
 *  @return UIAlertController
 */
+ (instancetype _Nonnull )sheet:(NSString *_Nullable)title
                        actions:(id _Nonnull)actions
                       onAction:(UIAlertControllerActionBlock _Nonnull)actionBlock ;

/**
 *  弹出ActionSheet Sheet自定义 参数：title、message、cancelTitle、actions、actionBlock
 *
 *  @param title             Title
 *  @param message           内容
 *  @param cancelTitle       取消
 *  @param actions           其他按钮 NSArray<NSString *> *  or NSString *
 *  @param actionBlock       选择结果回调
 *
 *  @return UIAlertController
 */
+ (instancetype _Nonnull )sheet:(NSString *_Nullable)title
                        message:(NSString *_Nullable)message
                      cancelBtn:(NSString *_Nullable)cancelTitle
                        actions:(id _Nullable )actions
                       onAction:(UIAlertControllerActionBlock _Nullable )actionBlock;
/**
 *  弹出AlertOrSheet 类型自定义 参数：title、message、cancelTitle、otherBtns、type、actionBlock
 *
 *  @param title             Title
 *  @param message           内容
 *  @param cancelTitle       取消
 *  @param otherBtns         其他按钮 NSArray<NSString *> *   or NSString *
 *  @param type              UIAlertControllerStyle
 *  @param actionBlock       选择结果回调
 *
 *  @return UIAlertController
 */
+ (instancetype _Nonnull )showAlertOrSheet:(NSString *_Nullable)title
                                   message:(NSString *_Nullable)message
                                 cancelBtn:(NSString *_Nullable)cancelTitle
                                 otherBtns:(id _Nullable)otherBtns
                                      type:(UIAlertControllerStyle)type
                                  onAction:(UIAlertControllerActionBlock _Nullable)actionBlock;


/**
 *  AlertOrSheet 全自定义, 不自动弹出，自己定义完后自己调用show
 *
 *  @param title             Title
 *  @param message           内容
 *  @param cancelTitle       取消
 *  @param otherBtns         其他按钮 NSArray<NSString *> *   or NSString *
 *  @param type              UIAlertControllerStyle
 *  @param actionBlock       选择结果回调
 *
 *  @return UIAlertController
 */
+ (instancetype _Nonnull )alertOrSheet:(NSString *_Nullable)title
                               message:(NSString *_Nullable)message
                             cancelBtn:(NSString *_Nullable)cancelTitle
                             otherBtns:(id _Nullable)otherBtns
                                  type:(UIAlertControllerStyle)type
                              onAction:(UIAlertControllerActionBlock _Nullable)actionBlock;
/**
 *  AlertOrSheet自定义, 不自动弹出，自己定义完后自己调用show
 */
- (void)show ;
@end
