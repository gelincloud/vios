//
//  AppDelegate.h
//  veivo
//
//  Created by 马洪伟 on 14-4-22.
//  Copyright (c) 2014年 Fn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "WechatAuthSDK.h"
#import "WXApi.h"
#import "WXApiObject.h"

#import "WeiboSDK.h"
#import "WeiboSDK+Statistics.h"

#import <UserNotifications/UserNotifications.h>
#import "JPUSHService.h"



#define SERVER_URL @"https://www.veivo.com"
//#define SERVER_URL @"https://n.veivo.com"
//#define SERVER_URL @"http://192.168.50.113/index.html"
//#define SERVER_URL @"http://www.veivo.com"

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


#define Screen_Type 2

#define IS_ShowShareDiag  YES

@protocol AppDelegateProtocal <NSObject>

-(void)showContactView:(NSString*)aMid;

-(void)wechatLogin:(NSString*)sUrl;

-(BOOL)excutJs:(NSString*)aJsStr;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate,WeiboSDKDelegate,UNUserNotificationCenterDelegate,JPUSHRegisterDelegate>
{
    NSMutableArray * mesPushArr;
    UINavigationController * iNavigationController;
    
    NSMutableArray * jsArr;
    
    NSString* wbtoken;
    NSString* wbCurrentUserID;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) NSMutableArray * jsArr;
@property (strong, nonatomic) NSMutableArray * mesPushArr;
@property (nonatomic,assign) id<AppDelegateProtocal> appdelegate;
@property (readwrite,nonatomic)BOOL isLogin;

@property (strong, nonatomic) NSString *cookie;
@property (strong, nonatomic) NSString *veivoCookie;
@property (strong, nonatomic) NSString *appid;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *veivoDraft;
@property (strong, nonatomic) NSHTTPCookieStorage *cs;

@property (strong, nonatomic) NSString *wbtoken;
@property (strong, nonatomic) NSString *wbRefreshToken;
@property (strong, nonatomic) NSString *wbCurrentUserID;
@property (strong, nonatomic) NSString *language;

-(BOOL)getMidIsHandle:(NSString*)mesId;
//-(void)onResp:(BaseResp *)resp;

@end
