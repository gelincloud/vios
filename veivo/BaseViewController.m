//
//  BaseViewController.m
//  veivo
//  打开的主界面
//  Created by 马洪伟 on 14-4-22.
//  Copyright (c) 2014年 Fn. All rights reserved.
//

#import "BaseViewController.h"
#import "WebViewJavascriptBridge.h"
#import "HWNotificationView.h"
#import "AppDelegate.h"
#import "JSONKit.h"
#import "veivoWebView.h"
#import "WriteTweetViewController.h"
#import <Foundation/Foundation.h>
#import <AlipaySDK/AlipaySDK.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

#import <TwitterKit/TWTRKit.h>


@import GoogleSignIn;


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
#define IS_ZOOMED (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPHONE_X (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)


@interface BaseViewController ()
{
    IBOutlet UIImageView *loadingView;
    WebViewJavascriptBridge *bridge;
    NSString *userAgent;
    BOOL already;
}
@end


@interface WKWebView(SynchronousEvaluateJavaScript)
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;
@end

@implementation WKWebView(SynchronousEvaluateJavaScript)

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script
{
    __block NSString *resultString = nil;
    __block BOOL finished = NO;
    
    [self evaluateJavaScript:script completionHandler:^(id result, NSError *error) {
        if (error == nil) {
            if (result != nil) {
                resultString = [NSString stringWithFormat:@"%@", result];
            }
        } else {
            NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
        }
        finished = YES;
    }];
    
    while (!finished)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return resultString;
}
@end

@implementation BaseViewController
- (NSString *)detectDevice {
    
    // figure out screen height (portrait)
    int height = [UIScreen mainScreen].fixedCoordinateSpace.bounds.size.height;
    
    // based on the height, give out an NSString for device type
    NSString *deviceModel;
    
    switch (height) {
        case 568:
            deviceModel = @"iPhone 5s or SE";
            break;
            
        case 667:
            deviceModel = @"iPhone 8/7/6s/6";
            break;
            
        case 736:
            deviceModel = @"iPhone 8/7/6s/6 Plus";
            break;
            
        case 812:
            deviceModel = @"iPhone X";
            break;
            
        default:
            deviceModel = @"Dunno. Maybe it's an Android...?";
            break;
    }
    return deviceModel;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSString *iphonex = [self detectDevice];
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
            NSString *stringInt = [NSString stringWithFormat:@"%f",[[UIScreen mainScreen] nativeBounds].size.height];
            NSLog(stringInt);
            NSString *stringIntx = [NSString stringWithFormat:@"%f",[[UIScreen mainScreen] bounds].size.height];
            NSLog(stringIntx);
            
            NSLog(@"%f",[[UIScreen mainScreen] nativeBounds].size.height);
            switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
                case 2001:
                    iphonex=@"iPhone X";
                    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
                    break;
                default:
                    iphonex=@"iphone";
            }
        }
        
       
        
        NSLog(@"%f",[[UIScreen mainScreen] bounds].size.height);
        
        //ios version
        NSString *iosversion = [[UIDevice currentDevice] systemVersion];
        
        // 获取设备名称
        NSString *name = [[UIDevice currentDevice] name];
        // 获取设备系统名称
        NSString *systemName = [[UIDevice currentDevice] systemName];
        // 获取系统版本
        NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
        // 获取设备模型
        NSString *model = [[UIDevice currentDevice] model];
        // 获取设备本地模型
        NSString *localizedModel = [[UIDevice currentDevice] localizedModel];
        // Custom initialization
        userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 16_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.2 Mobile/15E148 Safari/604.1 veivo22 veivowk v202";
        
        userAgent = [[[[iphonex stringByAppendingString:@" "] stringByAppendingString:systemVersion] stringByAppendingString:@" "] stringByAppendingString:userAgent];
        
    }
    return self;
}
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script
{
    __block NSString *resultString = nil;
    __block BOOL finished = NO;
    
    [_webView evaluateJavaScript:script completionHandler:^(id result, NSError *error) {
        if (error == nil) {
            if (result != nil) {
                resultString = [NSString stringWithFormat:@"%@", result];
            }
        } else {
            NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
        }
        finished = YES;
    }];
    
    while (!finished)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return resultString;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    
    
    
//    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//    
//    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
//        statusBar.backgroundColor = [UIColor blueColor];
//    }

//    UINavigationBar *bar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, -43+(ios7:20), 320, 44)];
//    ios6
//    bar.tintColor = [UIColor greenColor];
//    ios7
//    bar.barTintColor = [UIColor blackColor];
//    [self.view addSubview:bar];
    
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 userAgent,
                                 @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    
    //loadingView = [[UIView alloc]initWithFrame:self.view.bounds];
    NSLog(@"00000");

    [self.view addSubview:loadingView];
    [self performSelector:@selector(home) withObject:nil afterDelay:4];
    if (bridge) {
        return;
    }
    
    bridge = [WebViewJavascriptBridge bridgeForWebView: _webView];  //初始化调用

    
//    [bridge registerHandler:@"shareClick" handler:^(id data, WVJBResponseCallback responseCallback) {
//        // data 的类型与 JS中传的参数有关
//        NSDictionary *tempDic = data;
//        // 在这里执行分享的操作
//        NSString *title = [tempDic objectForKey:@"title"];
//        NSString *content = [tempDic objectForKey:@"content"];
//        NSString *url = [tempDic objectForKey:@"url"];
//
//        // 将分享的结果返回到JS中
//        NSString *result = [NSString stringWithFormat:@"分享成功:%@,%@,%@",title,content,url];
//
//        responseCallback(result);  //回调给JS
//
//
//    }];
    
//    [bridge registerHandler:@"statusBarColor" handler:^(id data, WVJBResponseCallback responseCallback) {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//
//       // NSString * themeColor = [mesdic objectForKey:@"themeColor"];
//        NSString * themeColor = @"#284f83";
//
//        if([themeColor isEqualToString:@"#284F83"]){
//            themeColor = @"#284f83";
//        }
//
//        UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//
//
//        if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
//            UIColor * c = [self getColor:themeColor];
//            statusBar.backgroundColor = c;
//            _webView.backgroundColor=c;
//
//        }
//
//        //[loadingView removeFromSuperview];
//        // [self performSelector:@selector(home) withObject:nil];
//        return;
//    }];
    
     [bridge registerHandler:@"wkObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
    
//    bridge = [WebViewJavascriptBridge bridgeForWebView:_webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString * messge   = [NSString stringWithFormat:@"{%@}",data];
        NSDictionary * mesdic = (NSDictionary*)[messge objectFromJSONString];
        NSString * ntype = [mesdic objectForKey:@"ntype"];
        
        
        NSString * openWechat = [mesdic objectForKey:@"openWechat"];
        NSString * openWeibo = [mesdic objectForKey:@"openWeibo"];
        NSString * wechatPay = [mesdic objectForKey:@"wechatPay"];
        NSString * clientLogon = [mesdic objectForKey:@"clientLogon"];
        NSLog(@"11111");
        NSString * aliPay = [mesdic objectForKey:@"aliPay"];
         
         
//        NSString * logonFacebook = [mesdic objectForKey:@"logonFacebook"];
//        NSString * logonGoogle = [mesdic objectForKey:@"logonGoogle"];
        NSString * shareFacebook = [mesdic objectForKey:@"shareFacebook"];
        
//        NSString * shareGoogle = [mesdic objectForKey:@"shareGoogle"];
        
        
        NSString * statusBarColor = [mesdic objectForKey:@"statusBarColor"];
         NSString * openwritetweet = [mesdic objectForKey:@"openwritetweet"];
        NSString * logon = [mesdic objectForKey:@"logon"];
         NSString  *pushreg = [mesdic objectForKey:@"pushreg"];
        NSString * msgsummaries = [mesdic objectForKey:@"msgsummaries"];

        NSString * reqLocation = [mesdic objectForKey:@"reqLocation"];
        
        if(reqLocation!=nil){
            locationManager = [[CLLocationManager alloc]init];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            [locationManager startUpdatingLocation];
            return;
        }
         
         if(openwritetweet!=nil){
             
             NSString * appid = [mesdic objectForKey:@"appid"];
             ((AppDelegate*)([UIApplication sharedApplication].delegate)).appid = appid;
            
             
             NSString * username = [mesdic objectForKey:@"username"];
             ((AppDelegate*)([UIApplication sharedApplication].delegate)).username = username;
//             [_webView evaluateJavaScript:[NSString stringWithFormat:@"Veivo.aid"] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//                 if (response != 0) {
//                     NSLog(@"***************appid=%@,%@",response,error);
//                     
//                     ((AppDelegate*)([UIApplication sharedApplication].delegate)).appid = response;
//                     
//                 }
//             }];
             
             
             //跳转到新的界面
//             [mesdic setValue:@"url" forKey:[@"https://www.veivo.com/qr.jsp?url=" stringByAppendingString:[mesdic objectForKey:@"url"]]];
             
//             veivoWebView * web = [[veivoWebView alloc] init:mesdic];
//             web.delegate = self;
//             [self.navigationController pushViewController:web animated:YES];
             
             //把language保存到application
             NSString * language = [mesdic objectForKey:@"language"];
             ((AppDelegate*)([UIApplication sharedApplication].delegate)).language = language;
             
             WriteTweetViewController *vc = [[WriteTweetViewController alloc] initWithNibName:@"WriteTweetViewController" bundle:nil];
             [self.navigationController pushViewController:vc animated:YES];
             return;
         }
         
         if(pushreg!=nil){
             //zhuce ios push
             //zhuce ios registration id
             
             
             NSString *deviceToken = [[NSUserDefaults standardUserDefaults]objectForKey:@"DeviceToken"];
             NSString *registrationID = JPUSHService.registrationID;
             //NSLog(@"%@", deviceToken);
             BOOL isLogin = ((AppDelegate*)([UIApplication sharedApplication].delegate)).isLogin;
             if (registrationID != nil && ![registrationID isEqualToString:@""] && logon == nil) {
                 
                 
                 // 1.创建一个网络路径
                 NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/info?atx=addunactiveuser&bundle=veivoen&devicetoken=%@",@"https://en.veivo.com", registrationID]];
                 // 2.创建一个网络请求
                 NSURLRequest *request =[NSURLRequest requestWithURL:url];
                 // 3.获得会话对象
                 NSURLSession *session = [NSURLSession sharedSession];
                 // 4.根据会话对象，创建一个Task任务：
                 NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                     NSLog(@"从服务器获取到数据");
                     /*
                      对从服务器获取到的数据data进行相应的处理：
                      */
                     
                     NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                     //NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableLeaves) error:nil];
                     NSLog(@"-------------------result-------------%@",result);
                     //            NSLog(@"-------------------result-------------%@",result);
                     if (result && [result isEqualToString:@"ok"]) {
                         NSLog(@"*****send regid ok.regid:%@",registrationID);
                     }
                     ((AppDelegate*)([UIApplication sharedApplication].delegate)).isLogin = YES;
                     
                 }];
                 // 5.最后一步，执行任务（resume也是继续执行）:
                 [sessionDataTask resume];
                 
                 /*
                  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/info?atx=addunactiveuser&devicetoken=%@",SERVER_URL, registrationID]]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
                  NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                  NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                  
                  NSLog(@"-------------------result-------------%@",result);
                  if (result && [result isEqualToString:@"ok"]) {
                  NSLog(@"*****send regid ok.regid:%@",registrationID);
                  }
                  ((AppDelegate*)([UIApplication sharedApplication].delegate)).isLogin = YES;
                  */
                 
                 
             }
             return;
         }
        if(statusBarColor!=nil){
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            
            
            
            

            NSString * themeColor = [mesdic objectForKey:@"themeColor"];
            
            
            if([themeColor isEqualToString:@"#284F83"]){
                themeColor = @"#284f83";
            }
            
//                UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//
//
//                if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
//                    UIColor * c = [self getColor:themeColor];
//                    statusBar.backgroundColor = c;
//                    _webView.backgroundColor=c;
//
//                }
            
            UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].keyWindow.windowScene.statusBarManager;
                       id statusBar = nil;
                       if ([statusBarManager respondsToSelector:@selector(createLocalStatusBar)]) {
                           UIView *_localStatusBar = [statusBarManager performSelector:@selector(createLocalStatusBar)];
                           if ([_localStatusBar respondsToSelector:@selector(statusBar)]) {
                               statusBar = [_localStatusBar performSelector:@selector(statusBar)];
                           }
                       }

            //[loadingView removeFromSuperview];
           // [self performSelector:@selector(home) withObject:nil];
            
            [WKWebsiteDataStore defaultDataStore];
            
            NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            ((AppDelegate*)([UIApplication sharedApplication].delegate)).cs = cookieStorage;
            
//            NSMutableArray *arrCookies = [[NSMutableArray alloc]init];
//            for (NSHTTPCookie *cookie in cookieStorage.cookies) {
//                //        NSString *excuteJSString = [NSString stringWithFormat:@"setCookie('%@', '%@', 1);", cookie.name, cookie.value];
//                //        NSLog(@"%@", excuteJSString);
//                [arrCookies addObject:cookie];
//            }
            
            [_webView evaluateJavaScript:[NSString stringWithFormat:@"document.cookie+';lh='+window.location.href"] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                if (response != 0) {
                    NSLog(@"\n\n\n\n\n\n document.cookie%@,%@",response,error);
                    
                    ((AppDelegate*)([UIApplication sharedApplication].delegate)).veivoCookie = response;
                    
                }
            }];
            
            
            
            
            
//            WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
//            [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
//                             completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
//                                 for (WKWebsiteDataRecord *record  in records)
//                                 {
//
//                                     if ( [record.displayName containsString:@"veivo"])
//                                     {
//                                         NSLog(@"%@",record.displayName);
//                                     }
//
//                                 }
//                             }];
            
            return;
        }
        
        if(msgsummaries!=nil){
            NSString * msgcount = [mesdic objectForKey:@"msgcount"];
            [UIApplication sharedApplication].applicationIconBadgeNumber = msgcount.intValue;

            return;
        }
        
        if(openWechat != nil){
            if ([WXApi isWXAppInstalled]) {
            //处理微信开放平台指令（分享）
            NSString * title = [mesdic objectForKey:@"title"];
            title = [BaseViewController unescapeUnicodeString: title];
            NSString * text  = [mesdic objectForKey:@"text"];
            text = [BaseViewController unescapeUnicodeString:text];
            NSString * tweetid = [mesdic objectForKey:@"tweetid"];
            NSString * appid = [mesdic objectForKey:@"appid"];
            NSString * url = [mesdic objectForKey:@"url"];
            NSString * flag =  [mesdic objectForKey:@"flag"];
            NSString * avatar  = [mesdic objectForKey:@"avatar"];
            
            WXMediaMessage * message = [WXMediaMessage message];
            if([flag isEqualToString: @"1"]){
                message.title = text;
            }else{
                message.title = title;
            }
            message.description = text;
            
            
            
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:avatar]];
            [message setThumbImage:[UIImage imageWithData:data]];
            
            WXWebpageObject * webpageObject = [WXWebpageObject object];
//            
//            if(tweetid != nil){
//                webpageObject.webpageUrl=[@"https://www.veivo.com/article_detail_new.jsp?tweetid=" stringByAppendingString:tweetid];
//            }else{
                webpageObject.webpageUrl=url;
            //}
            message.mediaObject=webpageObject;
            
            SendMessageToWXReq * req = [[SendMessageToWXReq alloc] init];
            req.bText=NO;
            req.message=message;
            req.scene=[flag intValue];
            
            [WXApi sendReq:req];
            
            return;
            }else{
                //跳转到新的界面
                [mesdic setValue:@"url" forKey:[@"https://www.veivo.com/qr.jsp?url=" stringByAppendingString:[mesdic objectForKey:@"url"]]];
                
                veivoWebView * web = [[veivoWebView alloc] init:mesdic];
                web.delegate = self;
                [self.navigationController pushViewController:web animated:YES];
                return;
            }
        }
        
        if(openWeibo != nil){
            NSString * title = [mesdic objectForKey:@"title"];
            title = [BaseViewController unescapeUnicodeString: title];
            NSString * text  = [mesdic objectForKey:@"text"];
            text = [BaseViewController unescapeUnicodeString:text];
            NSString * tweetid = [mesdic objectForKey:@"tweetid"];
            NSString * appid = [mesdic objectForKey:@"appid"];
            NSString * url = [mesdic objectForKey:@"url"];
            NSString * flag =  [mesdic objectForKey:@"flag"];
            NSString * avatar  = [mesdic objectForKey:@"avatar"];
            
            
            WBMessageObject *message = [WBMessageObject message];
            
            WBWebpageObject *webpage = [WBWebpageObject object];
            webpage.objectID = [BaseViewController getUniqueStrByUUID];
            webpage.title = title;
            webpage.description = text;
            webpage.thumbnailData = [NSData dataWithContentsOfURL:[NSURL URLWithString:avatar]];
            
            
            //图像压缩
            UIImage *image = [self scaleFromImage: [UIImage imageWithData:webpage.thumbnailData]];
            //保存图像
            NSString *strFileName = [self saveImage:image];
            webpage.thumbnailData = UIImagePNGRepresentation(image);
            
            webpage.webpageUrl = url;
            //message.mediaObject = webpage;

            
            
            
            
            //图片对象
            WBImageObject * imageObject = [WBImageObject object];
            imageObject.imageData = UIImageJPEGRepresentation(image, 1.0);
            
            //WBMessageObject *message = [WBMessageObject message];
            //message.text = [text stringByAppendingString:url];                                  // 分享文字： 内容 + Url地址
            //message.imageObject = imageObject;     // 配置分享图片
            
            
            
            message.text = [text stringByAppendingString:url];
            
            message.imageObject = imageObject;
            
            WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
            authRequest.redirectURI = @"http://www.sina.com";
            authRequest.scope = @"all";
            //authRequest.shouldShowWebViewForAuthIfCannotSSO = NO;
            
//            WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:((AppDelegate*)([UIApplication sharedApplication].delegate)).wbtoken];
              WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:nil];
//            request.userInfo = @{@"ShareMessageFrom": @"SendMessageToWeiboViewController",
//                                 @"Other_Info_1": [NSNumber numberWithInt:123],
//                                 @"Other_Info_2": @[@"obj1", @"obj2"],
//                                 @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
            //    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
            [WeiboSDK sendRequest:request];
            
            
            return;
        }
        
         
         
         
//         if(logonFacebook != nil){
//
//
//                   return;
//               }
               if(shareFacebook != nil){
                   
                   NSString * _shareUrl = [mesdic objectForKey:@"_shareUrl"];
                   NSString * title = [mesdic objectForKey:@"title"];
                   
                   FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
                   content.contentURL = [NSURL URLWithString:@"http://developers.facebook.com"];
                   //分享对话框
                   [FBSDKShareDialog showFromViewController:self
                                                 withContent:content
                                                    delegate:nil];

//                   //构建内容
//                   FBSDKShareLinkContent *linkContent = [[FBSDKShareLinkContent alloc] init];
//                   linkContent.contentURL = [NSURL URLWithString:@"https://image.baidu.com"];
//                   linkContent.contentTitle = @"百度";
//                   linkContent.contentDescription = [[NSString alloc] initWithFormat:@"%@",@"星空图片欣赏"];
//                   linkContent.imageURL = [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1561310690603&di=6fb462fc7c72ab479061c8045639f87b&imgtype=0&src=http%3A%2F%2Fe.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F4034970a304e251fb1a2546da986c9177e3e53c9.jpg"];
//                   //分享对话框
//                   [FBSDKShareDialog showFromViewController:self withContent:linkContent delegate:self];
                   
                   return;
               }
//
//               if(logonGoogle != nil){
//
//                   return;
//               }
//               if(shareGoogle != nil){
//
//                   return;
//               }
         
         
        
        if(wechatPay != nil){
            
//            NSString * partnerId = [mesdic objectForKey:@"partnerId"];
            NSString * prepayId = [mesdic objectForKey:@"prepayId"];
            NSString * nonceStr = [mesdic objectForKey:@"nonceStr"];
            NSString * timeStamp = [mesdic objectForKey:@"timeStamp"];
            NSString * sign = [mesdic objectForKey:@"sign"];

            
            PayReq *request = [[PayReq alloc] init];
            request.partnerId = @"1358987502";
            request.prepayId= prepayId;
            request.package = @"Sign=WXPay";
            request.nonceStr= nonceStr;
            request.timeStamp= [timeStamp intValue];
            request.sign= sign;
            [WXApi sendReq:request];
            return;
        }
        
        if(aliPay!=nil){
            
//            NSString * t = @"cGFydG5lcj0iMjA4ODAxMTYzNjAxNzc0NCImc2VsbGVyX2lkPSJ2ZWl2b2JlaWppbmdAZ21haWwuY29tIiZvdXRfdHJhZGVfbm89IjIwMTYxMDE3MDAzMDI0NTc1IiZzdWJqZWN0PSLmnpfmmZPlhpvotK3kubDlupTnlKhCcmlnaHQgRnV0dXJlICjlvZPliY3nrYnnuqfkuqvlj5cwLjk15oqY5LyY5oOgKSImYm9keT0i5p6X5pmT5Yab6LSt5Lmw5bqU55SoQnJpZ2h0IEZ1dHVyZSAo5b2T5YmN562J57qn5Lqr5Y+XMC45NeaKmOS8mOaDoCkiJnRvdGFsX2ZlZT0iNS44OCImbm90aWZ5X3VybD0iaHR0cHM6Ly93d3cudmVpdm8uY29tL2FsaW5vdGlmeW1vYmlsZWFwcCImc2VydmljZT0ibW9iaWxlLnNlY3VyaXR5cGF5LnBheSImcGF5bWVudF90eXBlPSIxIiZfaW5wdXRfY2hhcnNldD0idXRmLTgiJml0X2JfcGF5PSIzMG0iJnJldHVybl91cmw9Im0uYWxpcGF5LmNvbSImc2lnbj0iS25rSGxPaHRDSHk2elc4YVRRTWRZclU3bjdQJTJCTHppQ0szJTJCdWpKSDJYN1M0dFpSQlZHWU9SdVBCcURxSzY2d1BzZHZVOTUlMkJTUjRVTjNMZ09LSlJ6bUxjTkNtcUJsWE1MU3VyMmQyJTJGJTJGMVJ1bHVhUjElMkYlMkZRbm5MVnliJTJGMCUyRkZoN3BEU3pmN1FzNXd1JTJCR0hOYnVMR256MnhWd3ZUUXVZQU5WN0dtMnNabmJTJTJGYyUzRCImc2lnbl90eXBlPSJSU0Ei";
//            
//            NSString * t1 = [[NSString alloc]
//                             initWithData:t encoding:NSUTF8StringEncoding];
            
           // NSString * orderString = [BaseViewController unescapeUnicodeString:[BaseViewController URLDecodedString:[mesdic objectForKey:@"payInfo"]]];
//            NSString * orderString = [[NSString alloc]
//                                                                initWithData:[mesdic objectForKey:@"payInfo"] encoding:NSUTF8StringEncoding];
            
            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:[mesdic objectForKey:@"payInfo"] options:0];
            NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", decodedString); // foo
            
            NSString * orderString = decodedString;
            
            if([decodedString containsString:@"type=4"]){
                //to paypal
                //跳转到新的界面
                NSRange rang = [orderString rangeOfString:@"http://"];
                 orderString = [orderString stringByReplacingCharactersInRange:rang withString:@"https://"];
                NSMutableDictionary * mesdic2 = [self mutableDeepCopy1:mesdic];
                orderString=[orderString stringByAppendingString:@"&gopay=true"];
                [mesdic2 setValue:orderString forKey:@"url"];
                                   
                veivoWebView * web = [[veivoWebView alloc] init:mesdic2];
                web.delegate = self;
                [self.navigationController pushViewController:web animated:YES];
                return;
            }
            
            //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
            NSString *appScheme = @"alisdkveivo";
            [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                NSLog(@"reslut = %@",resultDic);
            }];

            return;
        }
        
        NSLog(@"&&&&&");
        NSLog(@"%@", clientLogon);
        if(clientLogon != nil){
            //        //微信注册
                    //[WXApi registerApp:@"wx969cbab03c4c292f" withDescription:@"weixin"];
            
                    //构造SendAuthReq结构体
            //        SendAuthReq* req =[[SendAuthReq alloc ] init ] ;
            //        req.scope = @"snsapi_userinfo" ;
            //        req.state =  @"0744";
            //        //用于在OnResp中判断是哪个应用向微信发起的授权，这里填写的会在OnResp里面被微信返回
            //        //第三方向微信终端发送一个SendAuthReq消息结构
            //        [WXApi sendReq:req];
            if([clientLogon isEqualToString: @"21"]){
                //fb share
                NSString * _shareUrl = [mesdic objectForKey:@"url"];
                //_shareUrl = [BaseViewController unescapeUnicodeString:_shareUrl];
                _shareUrl = [_shareUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

                NSString * title = [mesdic objectForKey:@"title"];
                title = [title stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
//                NSString * text  = [mesdic objectForKey:@"text"];
//                text = [BaseViewController unescapeUnicodeString:text];
                
                FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
               // content.contentURL = [NSURL URLWithString:@"http://developers.facebook.com"];
                content.contentURL =  [NSURL URLWithString:_shareUrl];;
                
                //分享对话框
                [FBSDKShareDialog showFromViewController:self
                                              withContent:content
                                                 delegate:nil];

//                   //构建内容
//                   FBSDKShareLinkContent *linkContent = [[FBSDKShareLinkContent alloc] init];
//                   linkContent.contentURL = [NSURL URLWithString:@"https://image.baidu.com"];
//                   linkContent.contentTitle = @"百度";
//                   linkContent.contentDescription = [[NSString alloc] initWithFormat:@"%@",@"星空图片欣赏"];
//                   linkContent.imageURL = [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1561310690603&di=6fb462fc7c72ab479061c8045639f87b&imgtype=0&src=http%3A%2F%2Fe.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F4034970a304e251fb1a2546da986c9177e3e53c9.jpg"];
//                   //分享对话框
//                   [FBSDKShareDialog showFromViewController:self withContent:linkContent delegate:self];
                
                return;
                
            }else if([clientLogon isEqualToString: @"11"]){
                //fb
                FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
                
                [login logInWithPermissions:@[@"public_profile"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                    
                     if (error) {

                       NSLog(@"Process error");

                    } else if (result.isCancelled) {

                       NSLog(@"Cancelled");

                    } else {
                        NSString *fbid =  result.token.userID;
                        NSLog(@"Logged in");
                        
   //                     NSString *accessToken = [FBSDKAccessToken currentAccessToken];
   //
   //                     NSString *url = [@"https://graph.facebook.com/USER-ID?fields=id,name,email,picture&access_token=" stringByAppendingString:accessToken];
                        
                        [self getUserInfoWithResult:result];
                        

                    }

                   }];
                
                return;
                
            }if([clientLogon isEqualToString: @"12"]){
                //google
                [GIDSignIn.sharedInstance signInWithPresentingViewController:self
                                                                  completion:^(GIDSignInResult *signInResult,
                                                                               NSError *error) {
                    if (error) { return; }
                    if (signInResult == nil) { return; }

                    GIDGoogleUser *user = signInResult.user;

                    NSString *emailAddress = user.profile.email;

                    NSString *name = user.profile.name;
                    NSString *givenName = user.profile.givenName;
                    NSString *familyName = user.profile.familyName;

                    NSURL *profilePic = [user.profile imageURLWithDimension:320];
                    
                    NSString *picture = [profilePic absoluteString];
                    
                    NSString *uid = user.userID;
                    
                    
                    NSDate *datenow =[NSDate date];//如今时间,你能够输出来看下是什么格式

                     NSTimeZone *zone = [NSTimeZone systemTimeZone];

                     NSInteger interval = [zone secondsFromGMTForDate:datenow];

                     NSDate *localeDate = [datenow  dateByAddingTimeInterval: interval];

                     NSString *timeSp = [NSString stringWithFormat:@"%d", (long)[localeDate timeIntervalSince1970]];

                    
                    
                    NSString *lUrl = [[[[[[[@"https://en.veivo.com/g.jsp?uid=" stringByAppendingString:uid] stringByAppendingString:@"&name="] stringByAppendingString:name] stringByAppendingString:@"&t="] stringByAppendingString:timeSp] stringByAppendingString:@"&picurl="] stringByAppendingString:picture];
                    
                    lUrl= [lUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

                    
            //        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/fb.jsp?uid=%@&name=%@&picurl=%@",@"https://en.veivo.com", fbid,name,picture]];
                   
                    [self excutJs:[[@"window.location.href='" stringByAppendingString:lUrl] stringByAppendingString:@"'"]];
                    
//                    NSURL *loginUrl = [NSURL URLWithString:lUrl];
//
//                    [self loadRequest:[NSURLRequest requestWithURL:loginUrl]];
                    
                }];
                return;
            }else if([clientLogon isEqualToString: @"1"]){
                if ([WXApi isWXAppInstalled]) {
                    //判断是否有微信
                    NSLog(@"open logon");
                    SendAuthReq* req =[[SendAuthReq alloc ] init];
                    req.scope = @"snsapi_userinfo";
                    req.state = @"123";
                    [WXApi sendReq:req];
                    return;
                }else{
                    NSMutableDictionary * mesdic2 = [self mutableDeepCopy1:mesdic];
                    
                    //跳转到新的界面
                    [mesdic2 setValue:@"https://open.weixin.qq.com/connect/qrconnect?appid=wxd10f27f46619550a&redirect_uri=https://www.veivo.com/weixin.jsp&response_type=code&scope=snsapi_login&state=0#wechat_redirect" forKey:@"url"];
                    
                    veivoWebView * web = [[veivoWebView alloc] init:mesdic2];
                    web.delegate = self;
                    [self.navigationController pushViewController:web animated:YES];
                    return;
                    
                }
                
            }else{
                //weibo
//                WBAuthorizeRequest *request = [WBAuthorizeRequest request];
//                request.redirectURI = @"http://www.sina.com";
//                request.scope = @"email,direct_messages_read,direct_messages_write,friendships_groups_read,friendships_groups_write,statuses_to_me_read,follow_app_official_microblog,invitation_write";
//                request.userInfo = @{@"SSO_From": @"SendMessageToWeiboViewController",
//                                     @"Other_Info_1": [NSNumber numberWithInt:123],
//                                     @"Other_Info_2": @[@"obj1", @"obj2"],
//                                     @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
//                [WeiboSDK sendRequest:request];
                WBAuthorizeRequest *request = [WBAuthorizeRequest request];
                request.redirectURI = @"http://www.sina.com";
                request.scope = @"all";
                request.userInfo = @{@"SSO_From": @"SendMessageToWeiboViewController",
                                     @"Other_Info_1": [NSNumber numberWithInt:123],
                                     @"Other_Info_2": @[@"obj1", @"obj2"],
                                     @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
                
//                UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"can install" message:[NSString stringWithFormat:@"%d", [WeiboSDK isWeiboAppInstalled]]                                                              delegate:nil cancelButtonTitle:@"cancel"
//                                                     otherButtonTitles:nil, nil];
//                [alert show];

                
               // request.shouldShowWebViewForAuthIfCannotSSO = NO;
                [WeiboSDK sendRequest:request];

                return;
            }
        }
        
        if([ntype isEqualToString:@"1"]){
            NSString * sender = [mesdic objectForKey:@"sender"];
            NSString * text   = [mesdic objectForKey:@"text"];
            NSString * showmsg= [NSString stringWithFormat:@"%@:%@",sender,text];
            NSString * mid    = [mesdic objectForKey:@"mid"];
            BOOL isHava = [(AppDelegate*)([UIApplication sharedApplication].delegate) getMidIsHandle:mid];
            if(!isHava && false) //现在统一全部不显示了
                [HWNotificationView alertInView:self.view message:showmsg];
        }
        else if(ntype != nil)
        {
            //只震动
            [HWNotificationView shark];
            [HWNotificationView playSound];
        }
        else {
            
            NSString * language = [mesdic objectForKey:@"language"];
            if(language != nil){
                NSString* url = [mesdic objectForKey:@"url"];
                
                if([url rangeOfString:@"twitter.com"].location != NSNotFound){
                    
                    
                    NSString* o_msg = [mesdic objectForKey:@"msg"];
                    NSString* o_link = [mesdic objectForKey:@"link"];
                    
                    NSString *msg = [BaseViewController unescapeUnicodeString:o_msg];
                    
                    NSString *link = [BaseViewController URLDecodedString:o_link];
                    
                    NSString *t = [[msg stringByAppendingString:@" "] stringByAppendingString:link];
                    
                    NSLog(@"native post tweet: \n%@",t);

                    
                    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://post?message=" stringByAppendingString:t]]];
                    } else {
                        int linkLen = [o_link length];
                        int msgLen = [o_msg length];
                        NSLog(@"LINK LEN=%d",linkLen);
                        NSLog(@"MSG LEN=%d",msgLen);
                        t = [[o_msg stringByAppendingString:@" "] stringByAppendingString:o_link];
                        NSLog(@"TOTAL LEN=%d",[t length]);
                        t = [@"https://twitter.com/intent/tweet?text=" stringByAppendingString:t];
                        NSLog(@"TOTAL LEN=%d",[t length]);
                        //NSLog(@"t=%@",t);
                                                
                        NSString * encodedMsg = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(    NULL,    (CFStringRef)[msg stringByAppendingString:@" "],    NULL,    (CFStringRef)@"!*'();:@&=+$,/?%#[]",    kCFStringEncodingUTF8 ));
                        
                        
                        NSLog(@"encodeParam LEN=%d",[encodedMsg length]);
                        
                        
                        NSString *tweet = [encodedMsg stringByAppendingString:o_link];

                        NSLog(@"tweet: \n%@",tweet);

                        
                        
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://twitter.com/intent/tweet?text=" stringByAppendingString:tweet]]];
                        
                        
                     // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/intent/tweet?text=Hello%20World!"]];
                    }
                    
                    
                   // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                }else{
                    //跳转到新的界面
                    veivoWebView * web = [[veivoWebView alloc] init:mesdic];
                    web.delegate = self;
                    [self.navigationController pushViewController:web animated:YES];
                }
             
            }
            else{
                //说明打开safari
                NSString * url = [mesdic objectForKey:@"url"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
        }
       
        //[HWNotificationView alertInView:self.view message:@"您收到一条新消息"];
       
    }];
    [bridge registerHandler:@"WebViewJavascriptBridge" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"bridge registerHandler: \n%@",data);
    }];

   // [_webView setSuppressesIncrementalRendering:YES];
    _webView.customUserAgent=@"Mozilla/5.0 (iPhone; CPU iPhone OS 16_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.2 Mobile/15E148 Safari/604.1 veivo22 veivowk v202";
    
    
    
   // [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:SERVER_URL]]];
    
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:SERVER_URL]]];

    
    
    //设置appdelegate
    [(AppDelegate*)([UIApplication sharedApplication].delegate) setAppdelegate:self];
    
    
    
    

}


//fb share
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {

    NSString *postId = results[@"postId"];

    FBSDKShareDialog *dialog = (FBSDKShareDialog *)sharer;

    if (dialog.mode == FBSDKShareDialogModeBrowser && (postId == nil || [postId isEqualToString:@""])) {

        // 如果使用webview分享的，但postId是空的，

        // 这种情况是用户点击了『完成』按钮，并没有真的分享

        NSString * msg = @"Share Canceled";
        //初始化弹窗
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        //弹出提示框
        [self presentViewController:alert animated:true completion:nil];

    } else {

        //分享成功

        NSString * msg = @"Share Successfully";
        //初始化弹窗
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        //弹出提示框
        [self presentViewController:alert animated:true completion:nil];

    }

    

}

 

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {

    FBSDKShareDialog *dialog = (FBSDKShareDialog *)sharer;

    if (error == nil && dialog.mode == FBSDKShareDialogModeNative) {

        // 如果使用原生登录失败，但error为空，那是因为用户没有安装Facebook app

        // 重设dialog的mode，再次弹出对话框

        dialog.mode = FBSDKShareDialogModeBrowser;

        [dialog show];

    } else {

        NSString * msg = @"Share Fail";
        //初始化弹窗
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        //弹出提示框
        [self presentViewController:alert animated:true completion:nil];

    }

}

 

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
            NSString * msg = @"Share Canceled";
            //初始化弹窗
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            //弹出提示框
            [self presentViewController:alert animated:true completion:nil];

}
//获取fb用户信息 picture用户头像
- (void)getUserInfoWithResult:(FBSDKLoginManagerLoginResult *)result
{
    NSDictionary*params= @{@"fields":@"id,name,email,age_range,first_name,last_name,link,gender,locale,picture,timezone,updated_time,verified"};
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:result.token.userID
                                  parameters:params
                                  HTTPMethod:@"GET"];
    
    [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
        
        NSLog(@"%@",result);
        
        NSString *fbid = [result objectForKey:@"id"];
        
        NSString *name = [result objectForKey:@"name"];
        
        NSString *picture = [[[result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
        
        
        NSMutableDictionary * mesdic2 = [self mutableDeepCopy1:result];
        
        
        
        NSDate *datenow =[NSDate date];//如今时间,你能够输出来看下是什么格式

         NSTimeZone *zone = [NSTimeZone systemTimeZone];

         NSInteger interval = [zone secondsFromGMTForDate:datenow];

         NSDate *localeDate = [datenow  dateByAddingTimeInterval: interval];

         NSString *timeSp = [NSString stringWithFormat:@"%d", (long)[localeDate timeIntervalSince1970]];

        
        NSString *lUrl = [[[[[[[@"https://en.veivo.com/fb.jsp?uid=" stringByAppendingString:fbid] stringByAppendingString:@"&name="] stringByAppendingString:name] stringByAppendingString:@"&t="] stringByAppendingString:timeSp] stringByAppendingString:@"&picurl="] stringByAppendingString:picture];
        
        lUrl= [lUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        
//                //初始化弹窗
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"标题" message:lUrl preferredStyle:UIAlertControllerStyleAlert];
//                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
//                //弹出提示框
//                [self presentViewController:alert animated:true completion:nil];
        
        
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/fb.jsp?uid=%@&name=%@&picurl=%@",@"https://en.veivo.com", fbid,name,picture]];
        
        
        [self excutJs:[[@"window.location.href='" stringByAppendingString:lUrl] stringByAppendingString:@"'"]];
        
//        NSURL *loginUrl = [NSURL URLWithString:lUrl];
//
//        [self loadRequest:[NSURLRequest requestWithURL:loginUrl]];

        
//        //跳转到新的界面
//        [mesdic2 setValue:[[[[[@"https://en.veivo.com/fb.jsp?uid=" stringByAppendingString:fbid] stringByAppendingString:@"&name="] stringByAppendingString:name] stringByAppendingString:@"&picurl="] stringByAppendingString:picture] forKey:@"url"];
//
//        veivoWebView * web = [[veivoWebView alloc] init:mesdic2];
//        web.delegate = self;
//        [self.navigationController pushViewController:web animated:YES];
        
        
//        //初始化弹窗
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"标题" message:result preferredStyle:UIAlertControllerStyleAlert];
//        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
//        //弹出提示框
//        [self presentViewController:alert animated:true completion:nil];
        
        /*
         {
         "age_range" =     {
         min = 21;
         };
         "first_name" = "\U6dd1\U5a1f";
         gender = female;
         id = 320561731689112;
         "last_name" = "\U6f58";
         link = "https://www.facebook.com/app_scoped_user_id/320561731689112/";
         locale = "zh_CN";
         name = "\U6f58\U6dd1\U5a1f";
         picture =     {
         data =         {
         "is_silhouette" = 0;
         url = "https://fb-s-c-a.akamaihd.net/h-ak-fbx/v/t1.0-1/p50x50/18157158_290358084709477_3057447496862917877_n.jpg?oh=01ba6b3a5190122f3959a3f4ed553ae8&oe=5A0ADBF5&__gda__=1509731522_7a226b0977470e13b2611f970b6e2719";
         };
         };
         timezone = 8;
         "updated_time" = "2017-04-29T07:54:31+0000";
         verified = 1;
         }
         */
        
//        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableContainers error:nil];
//        NSLog(@"obj=%@",responseObject);
//
//
//        for (NSDictionary *key in responseObject) {
//
//
//            UserEntity *entity = [[UserEntity alloc] initWithName:[key objectForKey:@"name" ] appid:[key objectForKey:@"id" ]];
//
//            [group1 addEntity:entity];
//
//            NSLog(@"name=%@,appid=%@",entity.name,entity.appid);
//
//
//        }
        
    }];
}

- (void)loadRequest:(NSURLRequest *)request {
    if (request.URL) {
        NSDictionary *cookies = [NSHTTPCookie requestHeaderFieldsWithCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:request.URL]];
        if ([cookies objectForKey:@"Cookie"]) {
            NSMutableURLRequest *mutableRequest = request.mutableCopy;
            [mutableRequest addValue:cookies[@"Cookie"] forHTTPHeaderField:@"Cookie"];
            request = mutableRequest;
        }
    }
    
    [_webView loadRequest:request];
    
   
    
}
-(BOOL)excutJs:(NSString*)jstxt
{
    if((webViewDidLoad<2)){
        [_webView evaluateJavaScript:jstxt completionHandler:nil];
//        NSString * result = [_webView stringByEvaluatingJavaScriptFromString:jstxt];
//        NSLog(@"jsresult:%@",result);
        return YES;
    }
    else{
        [_webView evaluateJavaScript:jstxt completionHandler:nil];
//        NSString * result = [_webView stringByEvaluatingJavaScriptFromString:jstxt];
//        NSLog(@"jsresult:%@",result);
        return YES;
    }
}

-(NSString*)excutJavas:(NSString*)jstxt
{
    NSString * result = [_webView stringByEvaluatingJavaScriptFromString:jstxt];
    NSLog(@"jsresult:%@",result);
    return result;
}

-(NSString*)excutJavasWithShow:(NSString*)jstxt
                     WithTitle:(NSString*)title
                        WithOk:(NSString*)okStr
{
    NSString * result = [_webView stringByEvaluatingJavaScriptFromString:jstxt];
    NSLog(@"jsresult:%@",result);
    
    if(IS_ShowShareDiag)
    {
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:title message:result
                                                      delegate:nil cancelButtonTitle:okStr
                                             otherButtonTitles:nil, nil];
        [alert show];
    }
    
    return result;
}

-(void)showContactView:(NSString*)aMid
{
    //执行javascrip脚本
    NSString * script = [NSString stringWithFormat:@"App.im.quickPosition1('%@');",aMid];
//    NSString *cookiesString = [_webView
//            stringByEvaluatingJavaScriptFromString:script];
    
    int  show=0;
    if(![self excutJs:script]){
        //[((AppDelegate*)([UIApplication sharedApplication].delegate)).jsArr addObject:script];
        [[(AppDelegate*)([UIApplication sharedApplication].delegate) jsArr] addObject:script];
        show = 1;
    }
    
    /*
    NSString * mes = [NSString stringWithFormat:@"%@ -  %@",script,cookiesString];
    [[[UIAlertView alloc] initWithTitle:@"这里是标题222" message:mes
                delegate:self cancelButtonTitle:@"Cancel按钮" otherButtonTitles:@"OK",@"Hello",@"World", nil] show];
     */
}

-(void)wechatLogin:(NSString*)sUrl
{
    
//    NSURLRequest * req = [NSURLRequest requestWithURL:[NSURL URLWithString:sUrl]];
//    [_webView loadRequest:req];
    NSString * _jjj = [[@"flyAway(\"" stringByAppendingString:sUrl] stringByAppendingString:@"\");"];
    [_webView evaluateJavaScript:_jjj completionHandler:nil];
   
}

#pragma mark - 授权定位
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    NSLog(@"调用代理");
    switch (status) {
            
        case kCLAuthorizationStatusNotDetermined:{
            
            if ([manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [manager requestWhenInUseAuthorization];
            }
        }
            break;
        default:{
            
        }
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didChangeAuthorizationStatus----%@",error);
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    switch (Screen_Type) {
        case 1: //完全不显示
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
            break;
        case 2: //透明显示
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
            break;
        case 3: //完全不透明
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
            break;
        default:
            break;
    }

    //刷新timeline
    NSString * refreshtxt = @"refreshTimeline();";
    [self excutJs:refreshtxt];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)home
{
    if (loadingView) {
        [loadingView removeFromSuperview];
        loadingView = nil;
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    //    NSLog(@"%@",[_webView stringByEvaluatingJavaScriptFromString:@"window.navigator.userAgent"]);
    webView.customUserAgent=@"Mozilla/5.0 (iPhone; CPU iPhone OS 16_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.2 Mobile/15E148 Safari/604.1 veivo22 veivowk v202";
    
    //取出cookie
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    ((AppDelegate*)([UIApplication sharedApplication].delegate)).cs = cookieStorage;
    
    //js函数
    NSString *JSFuncString =
    @"function setCookie(name,value,expires)\
    {\
    var oDate=new Date();\
    oDate.setDate(oDate.getDate()+expires);\
    document.cookie=name+'='+value+';expires='+oDate+';path=/'\
    }\
    function getCookie(name)\
    {\
    var arr = document.cookie.match(new RegExp('(^| )'+name+'=({FNXX==XXFN}*)(;|$)'));\
    if(arr != null) return unescape(arr[2]); return null;\
    }\
    function delCookie(name)\
    {\
    var exp = new Date();\
    exp.setTime(exp.getTime() - 1);\
    var cval=getCookie(name);\
    if(cval!=null) document.cookie= name + '='+cval+';expires='+exp.toGMTString();\
    }";
    
    //拼凑js字符串
    NSMutableString *JSCookieString = JSFuncString.mutableCopy;
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        NSString *excuteJSString = [NSString stringWithFormat:@"setCookie('%@', '%@', 1);", cookie.name, cookie.value];
        [JSCookieString appendString:excuteJSString];
    }
    //执行js
    [webView evaluateJavaScript:JSCookieString completionHandler:^(id obj, NSError * _Nullable error) {
        NSLog(@"%@",error);
    }];
    
    //  NSString * url = webView.URL.absoluteString;
    // NSString * url = [[[webView request] URL] absoluteString];
    /*
     [[[UIAlertView alloc] initWithTitle:@"这里是标题222" message:url delegate:self cancelButtonTitle:@"Cancel按钮" otherButtonTitles:@"OK",@"Hello",@"World", nil] show];
     */
    
    //检查有没有js需要执行
    webViewDidLoad++;
    if(webViewDidLoad>=2){
        /*
         [[[UIAlertView alloc] initWithTitle:@"这里是标题222" message:@"5555" delegate:self cancelButtonTitle:@"Cancel按钮" otherButtonTitles:@"OK",@"Hello",@"World", nil] show];
         */
        [self performSelector:@selector(excutAppJs) withObject:nil afterDelay:1];
    }
    
    
}

- (void)webViewDidFinishLoad:(WKWebView *)webView
{
//    NSLog(@"%@",[_webView stringByEvaluatingJavaScriptFromString:@"window.navigator.userAgent"]);
    webView.customUserAgent=@"Mozilla/5.0 (iPhone; CPU iPhone OS 16_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.2 Mobile/15E148 Safari/604.1 veivo22 veivowk v202";
    
    NSString *cookiesString = [_webView stringByEvaluatingJavaScriptFromString:@"document.cookie"];
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults]objectForKey:@"DeviceToken"];
    NSString *registrationID = JPUSHService.registrationID;
    

    BOOL isLogin = ((AppDelegate*)([UIApplication sharedApplication].delegate)).isLogin;
    if (cookiesString != nil && [cookiesString rangeOfString:@"activeUser"].location != NSNotFound && registrationID != nil && ![registrationID isEqualToString:@""] && !isLogin) {
        
        
        // 1.创建一个网络路径
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/info?atx=addunactiveuser&bundle=veivoen&devicetoken=%@",SERVER_URL, registrationID]];
        // 2.创建一个网络请求
        NSURLRequest *request =[NSURLRequest requestWithURL:url];
        // 3.获得会话对象
        NSURLSession *session = [NSURLSession sharedSession];
        // 4.根据会话对象，创建一个Task任务：
        NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"从服务器获取到数据");
            /*
             对从服务器获取到的数据data进行相应的处理：
             */
            
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableLeaves) error:nil];
            NSLog(@"-------------------result-------------%@",result);
//            NSLog(@"-------------------result-------------%@",result);
            if (result && [result isEqualToString:@"ok"]) {
                NSLog(@"*****send regid ok.regid:%@",registrationID);
            }
            ((AppDelegate*)([UIApplication sharedApplication].delegate)).isLogin = YES;
            
        }];
        // 5.最后一步，执行任务（resume也是继续执行）:
        [sessionDataTask resume];
        
        /*
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/info?atx=addunactiveuser&devicetoken=%@",SERVER_URL, registrationID]]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"-------------------result-------------%@",result);
        if (result && [result isEqualToString:@"ok"]) {
            NSLog(@"*****send regid ok.regid:%@",registrationID);
        }
        ((AppDelegate*)([UIApplication sharedApplication].delegate)).isLogin = YES;
        */
        
        
    }
  //  NSString * url = webView.URL.absoluteString;
   // NSString * url = [[[webView request] URL] absoluteString];
    /*
    [[[UIAlertView alloc] initWithTitle:@"这里是标题222" message:url delegate:self cancelButtonTitle:@"Cancel按钮" otherButtonTitles:@"OK",@"Hello",@"World", nil] show];
    */
    
    //检查有没有js需要执行
    webViewDidLoad++;
    if(webViewDidLoad>=2){
        /*
        [[[UIAlertView alloc] initWithTitle:@"这里是标题222" message:@"5555" delegate:self cancelButtonTitle:@"Cancel按钮" otherButtonTitles:@"OK",@"Hello",@"World", nil] show];
        */
        [self performSelector:@selector(excutAppJs) withObject:nil afterDelay:1];
    }
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}
-(void)excutAppJs
{
    NSMutableArray * jsArr = [(AppDelegate*)([UIApplication sharedApplication].delegate) jsArr];
    
    while ([jsArr count]>0)
    {
        NSString * jsscrip = [jsArr objectAtIndex:0];
        [self excutJs:jsscrip];
        [jsArr removeObjectAtIndex:0];
        NSLog(@"%@",jsscrip);
        
        /*
        [[[UIAlertView alloc] initWithTitle:@"这里是标题222" message:@"66666" delegate:self cancelButtonTitle:@"Cancel按钮" otherButtonTitles:@"OK",@"Hello",@"World", nil] show];
        */
    }
}
+(NSString *)URLDecodedString:(NSString*)stringURL
{
    return (__bridge NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                        (CFStringRef)stringURL,
                                                                                        CFSTR(""), 
                                                                                        kCFStringEncodingUTF8); 
}
+ (NSString*) unescapeUnicodeString:(NSString*)string
{
    Byte val[] = {
        0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
        0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
        0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
        0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
        0x3F,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
        0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
        0x3F,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
        0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
        0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
        0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
        0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
        0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
        0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
        0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
        0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
        0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F};
    NSMutableString *out = [NSMutableString string];
    if(string && ![string isEqualToString:@""]){
        int i = 0;
        int len = [string length];
        while (i < len) {
            unichar ch = [string characterAtIndex:i];
            if (ch == '+') {
                [out appendString:@"' '"];
            } else if ('A' <= ch && ch <= 'Z') {
                [out appendString:[NSString stringWithFormat:@"%C",ch]];
            } else if ('a' <= ch && ch <= 'z') {
                [out appendString:[NSString stringWithFormat:@"%C",ch]];
            } else if ('0' <= ch && ch <= '9') {
                [out appendString:[NSString stringWithFormat:@"%C",ch]];
            } else if (ch == '-' || ch == '_'
                       || ch == '.' || ch == '!'
                       || ch == '~' || ch == '*'
                       || ch == '\'' || ch == '('
                       || ch == ')') {
                [out appendString:[NSString stringWithFormat:@"%C",ch]];
            } else if (ch == '%') {
                unichar cint = 0;
                if ('u' != [string characterAtIndex:i+1]) {
                    cint = (cint << 4) | val[[string characterAtIndex:i+1]];
                    cint = (cint << 4) | val[[string characterAtIndex:i+2]];
                    i+=2;
                } else {
                    cint = (cint << 4) | val[[string characterAtIndex:i+2]];
                    cint = (cint << 4) | val[[string characterAtIndex:i+3]];
                    cint = (cint << 4) | val[[string characterAtIndex:i+4]];
                    cint = (cint << 4) | val[[string characterAtIndex:i+5]];
                    i+=5;
                }
                [out appendString:[NSString stringWithFormat:@"%C",cint]];
            }
            i++;
        }
    }
    return [NSString stringWithString:out];
}

+ (NSString *)getUniqueStrByUUID
{
    CFUUIDRef    uuidObj = CFUUIDCreate(nil);//create a new UUID
    
    //get the string representation of the UUID
    
    NSString    *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(nil, uuidObj);
    
    CFRelease(uuidObj);
    
    　　return uuidString ;
    
}
//==========================
// 图像压缩
//==========================
- (UIImage *)scaleFromImage:(UIImage *)image
{
    if (!image)
    {
        return nil;
    }
    NSData *data =UIImagePNGRepresentation(image);
    CGFloat dataSize = data.length/1024;
    CGFloat width  = image.size.width;
    CGFloat height = image.size.height;
    CGSize size;
    
    if (dataSize<=32)//小于50k
    {
        return image;
    }
    else if (dataSize<=64)//小于100k
    {
        size = CGSizeMake(width/1.f, height/1.f);
    }
    else if (dataSize<=128)//小于200k
    {
        size = CGSizeMake(width/2.f, height/2.f);
    }
    else if (dataSize<=256)//小于500k
    {
        size = CGSizeMake(width/2.f, height/2.f);
    }
    else if (dataSize<=512)//小于1M
    {
        size = CGSizeMake(width/2.f, height/2.f);
    }
    else if (dataSize<=1024)//小于2M
    {
        size = CGSizeMake(width/2.f, height/2.f);
    }
    else//大于2M
    {
        size = CGSizeMake(width/2.f, height/2.f);
    }
    NSLog(@"%f,%f",size.width,size.height);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage *newImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (!newImage)
    {
        return image;
    }
    return newImage;
}

//===============
// 保存图像
//===============
- (NSString *)saveImage:(UIImage*)image
{
    NSData *data;
    if (UIImagePNGRepresentation(image) ==nil)
    {
        data = UIImageJPEGRepresentation(image, 1.0);
    }
    else
    {
        data = UIImagePNGRepresentation(image);
    }
    
    //图片保存的路径
    //这里将图片放在沙盒的documents文件夹中
    NSString * DocumentsPath = [NSHomeDirectory()stringByAppendingPathComponent:@"Documents"];
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //把刚刚图片转换的data对象拷贝至沙盒中并保存为image.png
    [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:@"/image.png"]contents:data attributes:nil];
    
    //得到选择后沙盒中图片的完整路径
    NSString *filePath = [[NSString alloc]initWithFormat:@"%@%@",DocumentsPath, @"/image.png"];
    return filePath;
}

- (UIColor *)getColor:(NSString *)hexColor {
    NSString *string = [hexColor substringFromIndex:1];//去掉#号
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    /* 调用下面的方法处理字符串 */
    red = [self stringToInt:[string substringWithRange:range]];
    
    range.location = 2;
    green = [self stringToInt:[string substringWithRange:range]];
    range.location = 4;
    blue = [self stringToInt:[string substringWithRange:range]];
    
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:1.0f];
}

- (int)stringToInt:(NSString *)string {
    
    unichar hex_char1 = [string characterAtIndex:0]; /* 两位16进制数中的第一位(高位*16) */
    int int_ch1;
    if (hex_char1 >= '0' && hex_char1 <= '9')
        int_ch1 = (hex_char1 - 48) * 16;   /* 0 的Ascll - 48 */
    else if (hex_char1 >= 'A' && hex_char1 <='F')
        int_ch1 = (hex_char1 - 55) * 16; /* A 的Ascll - 65 */
    else
        int_ch1 = (hex_char1 - 87) * 16; /* a 的Ascll - 97 */
    unichar hex_char2 = [string characterAtIndex:1]; /* 两位16进制数中的第二位(低位) */
    int int_ch2;
    if (hex_char2 >= '0' && hex_char2 <='9')
        int_ch2 = (hex_char2 - 48); /* 0 的Ascll - 48 */
    else if (hex_char1 >= 'A' && hex_char1 <= 'F')
        int_ch2 = hex_char2 - 55; /* A 的Ascll - 65 */
    else
        int_ch2 = hex_char2 - 87; /* a 的Ascll - 97 */
    return int_ch1+int_ch2;
}

-(NSMutableDictionary *)mutableDeepCopy1:(NSDictionary *) mesdic
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithCapacity:[mesdic count]];
    //新建一个NSMutableDictionary对象，大小为原NSDictionary对象的大小
    NSArray *keys=[mesdic allKeys];
    for(id key in keys)
    {//循环读取复制每一个元素
        id value=[mesdic objectForKey:key];
        id copyValue;
        if ([value respondsToSelector:@selector(mutableDeepCopy1)]) {
            //如果key对应的元素可以响应mutableDeepCopy方法(还是NSDictionary)，调用mutableDeepCopy方法复制
            copyValue=[value mutableDeepCopy1];
        }else if([value respondsToSelector:@selector(mutableCopy)])
        {
            copyValue=[value mutableCopy];
        }
        if(copyValue==nil)
            copyValue=[value copy];
        [dict setObject:copyValue forKey:key];
        
    }
    return dict;
}
@end
