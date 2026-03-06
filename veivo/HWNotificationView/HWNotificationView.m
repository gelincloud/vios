//
//  HWNotificationView.m
//  HWNotificationView
//
//  Created by 马洪伟 on 14-5-6.
//  Copyright (c) 2014年 Fn. All rights reserved.
//

#import "HWNotificationView.h"
#import <AudioToolbox/AudioToolbox.h>

#ifndef kScreenWidth
#define kScreenWidth [UIScreen mainScreen].applicationFrame.size.width
#endif

@implementation HWNotificationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/**
 * 提示视图，2秒自动消失 默认顶部
 * @param view 作用视图
 * @param message 提示文本
 */
+ (void)alertInView:(UIView *)view message:(NSString *)message
{
    [self alertInView:view message:message position:HWNotificationViewPositionTop];
}

/**
 * 提示视图，2秒自动消失
 * @param view 作用视图
 * @param message 提示文本
 * @param position 出现位置
 */
+ (void)alertInView:(UIView *)view message:(NSString *)message position:(HWNotificationViewPosition)position
{
    
    CGRect frame = CGRectMake(3, -44, view.frame.size.width-6, 44);
    if (position == HWNotificationViewPositionCenter) {
        frame = CGRectMake((view.frame.size.width-100)/2, (view.frame.size.height-100)/2, 100, 100);
    }else if (position == HWNotificationViewPositionBottom){
        frame = CGRectMake(3, view.frame.size.height+44, view.frame.size.width-6, 44);
    }
    __block UIView *alertView = [[UIView alloc]initWithFrame:frame];
    alertView.alpha = 0;
    alertView.layer.masksToBounds = YES;
    alertView.layer.cornerRadius = 5.0;
    alertView.backgroundColor = [UIColor colorWithRed:73.0/255 green:73.0/255 blue:73.0/255 alpha:1];
    alertView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    alertView.layer.borderWidth = 0.5;
    [view addSubview:alertView];
    [view bringSubviewToFront:alertView];
    
    
    UILabel *messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, alertView.frame.size.width-20, alertView.frame.size.height-20)];
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.text = message;
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.textAlignment = NSTextAlignmentLeft;
    [messageLabel setNumberOfLines:5];
    messageLabel.font = [UIFont fontWithName:@"Courier" size:13.0];
    [alertView addSubview:messageLabel];
    
    
    [UIView animateWithDuration:1 animations:^{
        if (position == HWNotificationViewPositionTop) {
            alertView.transform = CGAffineTransformMakeTranslation(0, 44);
            alertView.alpha = 0.7;
        }
        
    } completion:^(BOOL finished) {
        sleep(1);
        [UIView animateWithDuration:1 animations:^{
            alertView.alpha = 0;
            alertView.transform = CGAffineTransformMakeScale(0, 0);
        } completion:^(BOOL finished) {
            [alertView removeFromSuperview];
            alertView = nil;
        }];
    }];
    
    // 声音 及 震动
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    SystemSoundID soundID;
    NSString *path = [[NSBundle mainBundle]pathForResource:@"message" ofType:@"mp3"];
    CFURLRef baseURL = (__bridge CFURLRef)[NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID(baseURL, &soundID);
    AudioServicesPlaySystemSound(soundID);
}

+ (void)playSound
{
    SystemSoundID soundID;
    NSString *path = [[NSBundle mainBundle]pathForResource:@"message" ofType:@"mp3"];
    CFURLRef baseURL = (__bridge CFURLRef)[NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID(baseURL, &soundID);
    AudioServicesPlaySystemSound(soundID);
}

+ (void)shark
{
    // 声音 及 震动
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}


@end
