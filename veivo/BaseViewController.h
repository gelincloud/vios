//
//  BaseViewController.h
//  veivo
//  打开的主界面
//  Created by 马洪伟 on 14-4-22.
//  Copyright (c) 2014年 Fn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "veivoWebView.h"
#import <WebKit/WebKit.h>


@interface BaseViewController : UIViewController
<CLLocationManagerDelegate,AppDelegateProtocal,veivoWebViewProtocol>
{
    CLLocationManager *locationManager;
    
    int  webViewDidLoad;
}

@property (weak, nonatomic) IBOutlet WKWebView *webView;
+ (NSString*) unescapeUnicodeString:(NSString*)string;
+(NSString *)URLDecodedString:(NSString*)stringURL;
+ (NSString *)getUniqueStrByUUID;
-(NSMutableDictionary *)mutableDeepCopy1;
-(NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;
- (void)loadRequest:(NSURLRequest *)request;
@end


