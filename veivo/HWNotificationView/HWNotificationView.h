//
//  HWNotificationView.h
//  HWNotificationView
//
//  Created by 马洪伟 on 14-5-6.
//  Copyright (c) 2014年 Fn. All rights reserved.
//

typedef  NS_ENUM(NSInteger, HWNotificationViewPosition){
    HWNotificationViewPositionTop =1,
    HWNotificationViewPositionCenter,
    HWNotificationViewPositionBottom
};

#import <UIKit/UIKit.h>

#pragma mark - 提醒视图
/**
 * 消息提示视图
 */
@interface HWNotificationView : UIView

/**
 * 提示视图，2秒自动消失 默认顶部
 * @param view 作用视图
 * @param message 提示文本
 */
+ (void)alertInView:(UIView *)view message:(NSString *)message;

/**
 * 提示视图，2秒自动消失
 * @param view 作用视图
 * @param message 提示文本
 * @param position 出现位置
 */
+ (void)alertInView:(UIView *)view message:(NSString *)message position:(HWNotificationViewPosition)position;


+ (void)playSound;

+ (void)shark;

#pragma mark - 加载视图

//+ (void)showHUDInView:(UIView *)view;
//
//+ (void)showHUDInView:(UIView *)view message:(NSString *)message;
@end
