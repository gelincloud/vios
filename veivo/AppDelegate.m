//
//  AppDelegate.m
//  veivo
//
//  Created by 马洪伟 on 14-4-22.
//  Copyright (c) 2014年 Fn. All rights reserved.
//

#import "AppDelegate.h"
#import "BaseViewController.h"
#import "JSONKit.h"
#import "WechatAuthSDK.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "WXApiManager.h"
#import <AlipaySDK/AlipaySDK.h>
#import <AudioToolbox/AudioToolbox.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import <TwitterKit/TWTRKit.h>


@import UIKit;
@import FirebaseCore;
@import GoogleSignIn;




// 引入JPush功能所需头文件
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@implementation AppDelegate
@synthesize mesPushArr;
@synthesize appdelegate;
@synthesize jsArr;
@synthesize isLogin;

@synthesize cookie;
@synthesize veivoCookie;
@synthesize cs;
@synthesize wbtoken;
@synthesize wbCurrentUserID;
@synthesize wbRefreshToken;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //setenv("CFNETWORK_DIAGNOSTICS", "3", 1);

       
    //Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    }
    else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    }
    else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    
//    //权限申请
//    //进行用户权限的申请
//    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge|UNAuthorizationOptionSound|UNAuthorizationOptionAlert|UNAuthorizationOptionCarPlay completionHandler:^(BOOL granted, NSError * _Nullable error) {
//        //在block中会传入布尔值granted，表示用户是否同意
//        if (granted) {
//            //如果用户权限申请成功，设置通知中心的代理
//            [UNUserNotificationCenter currentNotificationCenter].delegate = self;
//        }
//    }];
    
    //微信注册
    [WXApi registerApp:@"wx969cbab03c4c292f" withDescription:@"demo"];
    //[WXApi registerApp:@"wxd930ea5d5a258f4f" withDescription:@"demo 2.0"];
    
    //微博注册
    //[WeiboSDK enableDebugMode:YES];
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:@"1784628633"];
    
    //FB
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];

    //GOOGLE
    [FIRApp configure];
    
    //twitter
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
//        NSString *twitterConsumerKey = [info objectForKey:@"TwitterConsumerKey"];
//        NSString *twitterConsumerSecret = [info objectForKey:@"TwitterConsumerSecret"];
//

//        [[Twitter sharedInstance] startWithConsumerKey:@"zm2r1SPJjciC5EQjZqPFX2pMs" consumerSecret:@"ZThMTkIailybggEzSQZbTKZLsRIpidRw2Pe5ej7AoaMxy6wdeN"];
    
         [[Twitter sharedInstance] startWithConsumerKey:@"zm2r1SPJjciC5EQjZqPFX2pMs" consumerSecret:@"ZThMTkIailybggEzSQZbTKZLsRIpidRw2Pe5ej7AoaMxy6wdeN"];

    
    //end twitter
    
//    [GIDSignIn.sharedInstance restorePreviousSignInWithCompletion:^(GIDGoogleUser *user,
//                                                                    NSError *error) {
//        NSLog(@"...");
//    }];
    //end google
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    mesPushArr = [[NSMutableArray alloc] init];
    jsArr      = [[NSMutableArray alloc] init];
    isLogin    = NO;
    
    id remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification) {
        NSInteger badgeNumber = application.applicationIconBadgeNumber;
        if (badgeNumber > 0) {
            badgeNumber --;
            application.applicationIconBadgeNumber = badgeNumber;
        }
    }
    
    /*
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    [APService setupWithOption:launchOptions];
     */
    
       // Required
    [JPUSHService setupWithOption:launchOptions];
    
    BaseViewController *baseViewController = [[BaseViewController alloc]initWithNibName:@"BaseViewController" bundle:nil];
    //self.window.rootViewController = baseViewController;
    
    iNavigationController = [[UINavigationController alloc]
                             initWithRootViewController:baseViewController];
    [iNavigationController setNavigationBarHidden:YES];
    switch (Screen_Type) {
        case 1: //完全不显示
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
            break;
        case 2: //透明显示
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
            
            //self.window.backgroundColor=[UIColor yellowColor];
            //[[UINavigationBar appearance] setTintColor:[UIColor orangeColor]];
            
            

            
            //self.iNavigationController.navigationBar.barStyle = UIBarStyleBlack;
//            self.window.backgroundColor = [UIColor orangeColor];
//
//
            
//            [[UINavigationBar appearance] setTranslucent:NO];
//            [[UINavigationBar appearance] setBarTintColor:[UIColor blueColor]];
        
//            [iNavigationController.navigationBar setTranslucent:YES];
//            [iNavigationController.navigationBar setBarTintColor:[UIColor orangeColor]];
            
//           // if (IOS7) {
//                
//                [[UINavigationBar appearance] setBarTintColor:[UIColor blueColor]];
//                [[UINavigationBar appearance] setTranslucent:NO];
////            }
////            else {
////                
////                [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
////            }
//            
//            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
//            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            
            //UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
            
            

            break;
        case 3: //完全不透明
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
            break;
        default:
            break;
    }
    
    
//    switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
//        case 2001:
//            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
//            break;
//        default:
//            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];;
//    }
   // iNavigationController.view.backgroundColor=[UIColor redColor];
    [self.window setRootViewController:iNavigationController];
    
    //self.window.rootViewController.view.backgroundColor = [UIColor blueColor] ;

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoExitFullScreen:) name:@"UIWindowDidBecomeHiddenNotification" object:nil];


    
    return YES;
}
- (void)videoExitFullScreen:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
}
-(BOOL)getMidIsHandle:(NSString*)mesId
{
    BOOL isHave = NO;
    for (int i=0; i<[mesPushArr count]; i++)
    {
        NSString * tmpmid = [mesPushArr objectAtIndex:i];
        if([tmpmid isEqualToString:mesId])
        {
            isHave = YES;
            break;
        }
    }
    return isHave;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:deviceToken forKey:@"DeviceToken"];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    [APService handleRemoteNotification:userInfo];
    NSInteger badgeNumber = application.applicationIconBadgeNumber;
    if (badgeNumber > 0) {
        badgeNumber --;
        application.applicationIconBadgeNumber = badgeNumber;
    }
    
    [[[UIAlertView alloc] initWithTitle:@"这里是标题222" message:@"这里显示的是Message信息" delegate:self cancelButtonTitle:@"Cancel按钮" otherButtonTitles:@"OK",@"Hello",@"World", nil] show];
}
 */

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    
    // IOS 7 Support Required
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    
    
    //判断当前状态
    UIApplicationState state = [application applicationState];
    
    //从后台进入到前台
    if(state == UIApplicationStateInactive){
        // 取得自定义字段内容
        NSString  *other = [userInfo valueForKey:@"other"];//自定义参数，key是自己定义的
        NSDictionary* otherdic = (NSDictionary*)[other objectFromJSONString];
        
        NSString * text = [otherdic objectForKey:@"text"];
        NSString * mid  = [otherdic objectForKey:@"mid"];
        
        //保存mid
        [mesPushArr addObject:mid];
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        //需要页面跳转
        [self.appdelegate showContactView:mid];
    }
    else if(state == UIApplicationStateBackground){
        NSInteger badgeNumber = application.applicationIconBadgeNumber;
        badgeNumber ++;
        application.applicationIconBadgeNumber = badgeNumber;
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"%@", [url absoluteString]);
    
    // 在 host 等于 item.taobao.com 时，说明一个宝贝详情的 url，
    // 那么就使用本地的 TBItemDetailViewController 来显示
    if ([[url scheme] isEqualToString:@"veivo"]) {
        NSString * adiction = [url absoluteString];
        //传递过来的网址
        adiction = [adiction stringByReplacingOccurrencesOfString:@"veivo://"
                                    withString:@"http://"];
        
        //remove https
        adiction = [adiction stringByReplacingOccurrencesOfString:@"https://"
                                                       withString:@""];
        
        //真正的url
        NSString * mark = @"id=?";
        NSRange markRange = [adiction rangeOfString:mark];
        NSString * realUrl = @"";
        NSString * realTxt = @"";
        
        if(markRange.length > 0){
            realUrl = [adiction substringToIndex:markRange.location];
            realTxt =[adiction substringFromIndex:markRange.location + markRange.length];
            realTxt = [realTxt stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        
        //NSString * jstext = [NSString stringWithFormat:@"%@%@",realTxt,realUrl];
        NSString * jstext = [NSString stringWithFormat:@"%@%@",realTxt,adiction];
        NSString * script = [NSString stringWithFormat:@"Veivo.pushContent0(\"%@\",function(){},function(){alert(App.locale.appbase_message_send_ok);});",[realTxt stringByAppendingString:realUrl]];
        
        
        int  show=0;
        if(![self.appdelegate excutJs:script]){
            [self.jsArr addObject:script];
            show = 1;
        }
    }
    
    
    [WeiboSDK handleOpenURL:url delegate:self ];
    
    //return YES;
    return [WXApi handleOpenURL:url delegate:self];
    //return  [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url options:options];
    
    [GIDSignIn.sharedInstance handleURL:url];
    
    [[Twitter sharedInstance] application:application openURL:url options:options];

    //return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
    
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            
            NSString * result = [resultDic objectForKey:@"resultStatus"];
            
            NSString *script;
            
            
            if([result isEqualToString:@"9000"]){
                //支付成功
                script = @"window.paymenttodesktop();";
            }else{
                //支付失败
                script = @"alert('支付失败！');";
            }
            [self.appdelegate excutJs:script];

        }];
    }
    
    
    [WeiboSDK handleOpenURL:url delegate:self];
    
    return [WXApi handleOpenURL:url delegate:self];
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    
    // 在 host 等于 item.taobao.com 时，说明一个宝贝详情的 url，
    // 那么就使用本地的 TBItemDetailViewController 来显示
    if ([[url scheme] isEqualToString:@"veivo"]) {
        NSString * adiction = [url absoluteString];
        //传递过来的网址
        adiction = [adiction stringByReplacingOccurrencesOfString:@"veivo://"
                                                       withString:@"http://"];
        
        //remove https
        adiction = [adiction stringByReplacingOccurrencesOfString:@"https://"
                                                       withString:@""];
        
        //真正的url
        NSString * mark = @"id=?";
        NSRange markRange = [adiction rangeOfString:mark];
        NSString * realUrl = @"";
        NSString * realTxt = @"";
        
        if(markRange.length > 0){
            realUrl = [adiction substringToIndex:markRange.location];
            realTxt =[adiction substringFromIndex:markRange.location + markRange.length];
            realTxt = [realTxt stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        
        //escape " in realTxt
        realTxt = [realTxt stringByReplacingOccurrencesOfString:@"\""
                                                       withString:@"\\\""];

        
        //NSString * jstext = [NSString stringWithFormat:@"%@%@",realTxt,realUrl];
        NSString * jstext = [NSString stringWithFormat:@"%@%@",realTxt,adiction];
        NSString * script = [NSString stringWithFormat:@"Veivo.pushContent0(\"%@\",function(){},function(){alert(App.locale.appbase_message_send_ok);});",[realTxt stringByAppendingString:realUrl]];
        
        
        int  show=0;
        if(![self.appdelegate excutJs:script]){
            [self.jsArr addObject:script];
            show = 1;
        }
        return YES;
    }

    
    
    
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            
            NSLog(@"result = %@",resultDic);
            
            NSString * r = resultDic;
            
            NSString * result = [resultDic objectForKey:@"resultStatus"];
            
            
            NSString *script;
          
            
            if([result isEqualToString:@"9000"]){
                //支付成功
                script = @"window.paymenttodesktop();";
            }else{
                //支付失败
                script = @"alert('支付失败！');";
            }
            [self.appdelegate excutJs:script];
            
        }];
    }
    
    [WeiboSDK handleOpenURL:url delegate:self];
    return [WXApi handleOpenURL:url delegate:self];
    //return YES;
}


-(void) onResp:(BaseResp*)resp{
    /*
         ErrCode ERR_OK = 0(用户同意)
         ERR_AUTH_DENIED = -4（用户拒绝授权）
         ERR_USER_CANCEL = -2（用户取消）
         code    用户换取access_token的code，仅在ErrCode为0时有效
         state   第三方程序发送时用来标识其请求的唯一性的标志，由第三方程序调用sendReq时传入，由微信终端回传，state字符串长度不能超过1K
         lang    微信客户端当前语言
         country 微信用户当前国家信息
         */
    NSLog(@"微信回调");
    
    
    //    if ([respisKindOfClass:[PayRespclass]]){
    //        PayResp*response=(PayResp*)resp;
    //        switch(response.errCode){
    //            caseWXSuccess:
    //                //服务器端查询支付通知或查询API返回的结果再提示成功
    //                NSlog(@"支付成功");
    //                break;
    //            default:
    //                NSlog(@"支付失败，retcode=%d",resp.errCode);
    //                break;
    //        }
    //    }
    
    if ([resp isKindOfClass:[PayResp class]]){
        PayResp *aresp = (PayResp *)resp;
        NSString *script;
        if(aresp.errCode==0){
            script = @"alert('支付成功！');window.paymenttodesktop();";
        }else{
            script = @"alert('支付失败！');";
        }
        
        [self.appdelegate excutJs:script];
        
    }else if([resp isKindOfClass:[SendMessageToWXResp class]]){
        SendMessageToWXResp *aresp = (SendMessageToWXResp *)resp;
        NSString *script;
        if(aresp.errCode==0){
            script = @"alert('分享成功！');";
        }else{
            script = @"alert('分享失败！');";
        }
        
        [self.appdelegate excutJs:script];
    }else if([resp isKindOfClass:[SendAuthResp class]]){
        SendAuthResp *aresp = (SendAuthResp *)resp;
        if (aresp.code != nil) {
            NSString *code = aresp.code;
            NSString *state = aresp.state;
            
            NSDictionary *dic = @{@"code":code};
            
            NSString *sUrl = [NSString stringWithFormat:@"https://www.veivo.com/weixin3.jsp?state=%@&code=%@",state, code];
            
            
            //        BaseViewController *baseViewController = [[BaseViewController alloc]initWithNibName:@"BaseViewController" bundle:nil];
            
            //        NSURLRequest * req = [NSURLRequest requestWithURL:[NSURL URLWithString:sUrl]];
            //
            //        [baseViewController.webView loadRequest:req];
            //
            
            //NSString * script = [@"window.location.href=" stringByAppendingString:sUrl];
            
            [self.appdelegate wechatLogin:sUrl];
            
            //[baseViewController.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sUrl]]];
        }
    }
    
 
}



- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
//        NSString *title = NSLocalizedString(@"发送结果", nil);
//        NSString *message = [NSString stringWithFormat:@"%@: %d\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode, NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil),response.requestUserInfo];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
//                                                        message:message
//                                                       delegate:nil
//                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
//                                              otherButtonTitles:nil];
//        WBSendMessageToWeiboResponse* sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
//        NSString* accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
//        if (accessToken)
//        {
//            self.wbtoken = accessToken;
//        }
//        NSString* userID = [sendMessageToWeiboResponse.authResponse userID];
//        if (userID) {
//            self.wbCurrentUserID = userID;
//        }
//        [alert show];
        
        NSString *script;
        if((int)response.statusCode==0){
            script = @"alert('分享成功！');";
        }else{
            script = @"alert('分享失败！');";
        }
        
        [self.appdelegate excutJs:script];
       
        
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        NSString *title = NSLocalizedString(@"认证结果", nil);
        NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.userId: %@\nresponse.accessToken: %@\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode,[(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken],  NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
//                                                        message:message
//                                                       delegate:nil
//                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
//                                              otherButtonTitles:nil];
        
        self.wbtoken = [(WBAuthorizeResponse *)response accessToken];
        self.wbCurrentUserID = [(WBAuthorizeResponse *)response userID];
        self.wbRefreshToken = [(WBAuthorizeResponse *)response refreshToken];
        //[alert show];
        
        
        if([(WBAuthorizeResponse *)response accessToken] != nil){
            NSString *sUrl = [NSString stringWithFormat:@"https://www.veivo.com/weiboClient.jsp?access_token=%@&uid=%@",self.wbtoken, self.wbCurrentUserID];
            [self.appdelegate wechatLogin:sUrl];

        }
 
        
    }
    else if ([response isKindOfClass:WBPaymentResponse.class])
    {
        NSString *title = NSLocalizedString(@"支付结果", nil);
        NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.payStatusCode: %@\nresponse.payStatusMessage: %@\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode,[(WBPaymentResponse *)response payStatusCode], [(WBPaymentResponse *)response payStatusMessage], NSLocalizedString(@"响应UserInfo数据", nil),response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    else if([response isKindOfClass:WBSDKAppRecommendResponse.class])
    {
        NSString *title = NSLocalizedString(@"邀请结果", nil);
        NSString *message = [NSString stringWithFormat:@"accesstoken:\n%@\nresponse.StatusCode: %d\n响应UserInfo数据:%@\n原请求UserInfo数据:%@",[(WBSDKAppRecommendResponse *)response accessToken],(int)response.statusCode,response.userInfo,response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }else if([response isKindOfClass:WBShareMessageToContactResponse.class])
    {
        NSString *title = NSLocalizedString(@"发送结果", nil);
        NSString *message = [NSString stringWithFormat:@"%@: %d\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode, NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil),response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                              otherButtonTitles:nil];
        WBShareMessageToContactResponse* shareMessageToContactResponse = (WBShareMessageToContactResponse*)response;
        NSString* accessToken = [shareMessageToContactResponse.authResponse accessToken];
        if (accessToken)
        {
            self.wbtoken = accessToken;
        }
        NSString* userID = [shareMessageToContactResponse.authResponse userID];
        if (userID) {
            self.wbCurrentUserID = userID;
        }
        [alert show];
    }
}


#pragma mark- JPUSHRegisterDelegate
//active时候执行的方法
// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    
    
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    //判断当前状态
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    
    //从后台进入到前台
    if(state == UIApplicationStateInactive){
        // 取得自定义字段内容
        NSString  *other = [userInfo valueForKey:@"other"];//自定义参数，key是自己定义的
        NSDictionary* otherdic = (NSDictionary*)[other objectFromJSONString];
        
        NSString * text = [otherdic objectForKey:@"text"];
        NSString * mid  = [otherdic objectForKey:@"mid"];
        
        //保存mid
        [mesPushArr addObject:mid];
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        //需要页面跳转
        [self.appdelegate showContactView:mid];
        
        
        if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            [JPUSHService handleRemoteNotification:text];
        }
        completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
        
    }
    else if(state == UIApplicationStateActive){
        NSInteger badgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;
        badgeNumber ++;
        [UIApplication sharedApplication].applicationIconBadgeNumber = badgeNumber;
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

        return;
    }

    // 声音 及 震动
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    SystemSoundID soundID;
    NSString *path = [[NSBundle mainBundle]pathForResource:@"message" ofType:@"mp3"];
    CFURLRef baseURL = (__bridge CFURLRef)[NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID(baseURL, &soundID);
    AudioServicesPlaySystemSound(soundID);

}
//点击后执行的方法
// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    NSString *mid = [userInfo objectForKey:@"mid"];
    //需要页面跳转
    [self.appdelegate showContactView:mid];

    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
    
    
}

//jpush 自定义消息
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDictionary *extras = [userInfo valueForKey:@"extras"];
    NSString *customizeField1 = [extras valueForKey:@"customizeField1"]; //服务端传递的Extras附加字段，key是自己定义的
    
}

//- (BOOL)application:(UIApplication *)application
//      handleOpenURL:(NSURL *)url
//{
//    return  [WXApi handleOpenURL:url delegate:self];
//    
//}
//-(BOOL)application:(UIApplication*)app openURL:(NSURL*)url options:(NSDictionary<NSString *,id> *)options
//{
//    return  [WXApi handleOpenURL:url delegate:self];
//}
//
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//{
//    
//    return  [WXApi handleOpenURL:url delegate:self];
//    
//}
//
//
//-(void) onResp:(BaseResp*)resp
//{
//    NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
//    if([resp isKindOfClass:[PayResp class]]){
//        //支付返回结果
//        switch (resp.errCode) {
//            case WXSuccess:
//                strMsg = @"支付结果：成功！";
//                //                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
//                break;
//            default:
//                strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
//                //                NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
//                break;
//        }
//        
//    }  
//}

@end
