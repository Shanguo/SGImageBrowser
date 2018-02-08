//
//  UIAlertController+SG.m
//  UIAlertController
//
//  Created by 刘山国 on 2018/2/7.
//  Copyright © 2018年 山国. All rights reserved.
//

#import "UIAlertController+SG.h"
#import "UIApplication+SG.h"

@implementation UIAlertController (SG)

/**
 *  弹出Alert 单按钮 参数：message  默认title ”提示“ 默认按钮 ”知道了“
 *
 *  @param message         内容
 *
 *  @return UIAlertController
 */
+ (instancetype _Nonnull )alert:(NSString *_Nonnull)message{
    return [UIAlertController alert:nil message:message confirmBtn:kNowIt];
}

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
                     confirmBtn:(NSString *_Nonnull)confirmBtn {
    return [UIAlertController alert:title message:message cancelBtn:nil otherBtns:confirmBtn onAction:nil];
}

/**
 *  弹出Alert 双按钮 参数：message、actionBlock  默认title ”提示“ ，按钮 “取消”、"确定"
 *
 *  @param message          内容
 *  @param actionBlock      选择结果回调
 *
 *  @return UIAlertController
 */
+ (instancetype _Nonnull )alert:(NSString *_Nonnull)message
                       onAction:(UIAlertControllerActionBlock _Nullable )actionBlock {
    return [UIAlertController alert:nil message:message cancelBtn:kCancel otherBtns:kSure onAction:actionBlock];
}

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
                       onAction:(UIAlertControllerActionBlock _Nullable )actionBlock {
    
    return [UIAlertController showAlertOrSheet:title
                                       message:message
                                     cancelBtn:cancelTitle
                                     otherBtns:otherBtns
                                          type:UIAlertControllerStyleAlert
                                      onAction:actionBlock];
}

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
                       onAction:(UIAlertControllerActionBlock _Nonnull )actionBlock {
    return [self sheet:nil actions:actions onAction:actionBlock];
}

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
                       onAction:(UIAlertControllerActionBlock _Nonnull)actionBlock {
    return [[self class] sheet:title
                       message:nil
                     cancelBtn:kCancel
                       actions:actions
                      onAction:actionBlock];
}

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
                       onAction:(UIAlertControllerActionBlock _Nullable )actionBlock {
    
    return [UIAlertController showAlertOrSheet:title
                                       message:message
                                     cancelBtn:cancelTitle
                                     otherBtns:actions
                                          type:UIAlertControllerStyleActionSheet
                                      onAction:actionBlock];
}

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
                                  onAction:(UIAlertControllerActionBlock _Nullable)actionBlock {
    
    UIAlertController *alertController = [UIAlertController alertOrSheet:title message:message cancelBtn:cancelTitle otherBtns:otherBtns type:type onAction:actionBlock];
    [alertController show];
    return alertController;
}


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
                              onAction:(UIAlertControllerActionBlock _Nullable)actionBlock {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:type];
    
    if (cancelTitle) {
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction * action){
                                                           if (actionBlock) actionBlock(0,alertController);
                                                           [alertController dismissViewControllerAnimated:YES completion:nil];
                                                       }];
        [alertController addAction:cancel];
    }
    if (otherBtns) {
        if ([otherBtns isKindOfClass:[NSString class]]) otherBtns = @[otherBtns];
        for (int i=0; i<[(NSArray*)otherBtns count]; i++) {
            NSString *aTitle = otherBtns[i];
            if (aTitle.length==0) continue;
            UIAlertAction   *action = [UIAlertAction
                                       actionWithTitle:aTitle
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action)
                                       {
                                           if (actionBlock)actionBlock(i+1,alertController);
                                           [alertController dismissViewControllerAnimated:YES completion:nil];
                                       }];
            [alertController addAction:action];
        }
    }
    
    return alertController;
}

/**
 *  AlertOrSheet自定义, 不自动弹出，自己定义完后自己调用show
 */
- (void)show {
    UIViewController *controller = [[UIApplication sharedApplication] topViewController];
    [controller presentViewController:self animated:YES completion:nil];
}


@end
