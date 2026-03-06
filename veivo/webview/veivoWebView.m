//
//  veivoWebView.m
//  veivo
//  打开的链接
//  Created by musmile on 15/1/5.
//  Copyright (c) 2015年 Fn. All rights reserved.
//

#import "veivoWebView.h"
#import "veivoWebCell.h"
#import "AppDelegate.h"
#import "WechatAuthSDK.h"
#import "WXApi.h"
#import "WXApiObject.h"

@interface veivoWebView ()

@end

@implementation veivoWebView
@synthesize webView;
@synthesize delegate;

#define NOTFI_CHATIMAGE @"chatimage"
#define  adjustsScrollViewInsets(scrollView)\
do {\
_Pragma("clang diagnostic push")\
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")\
if ([scrollView respondsToSelector:NSSelectorFromString(@"setContentInsetAdjustmentBehavior:")]) {\
NSMethodSignature *signature = [UIScrollView instanceMethodSignatureForSelector:@selector(setContentInsetAdjustmentBehavior:)];\
NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];\
NSInteger argument = 2;\
invocation.target = scrollView;\
invocation.selector = @selector(setContentInsetAdjustmentBehavior:);\
[invocation setArgument:&argument atIndex:2];\
[invocation retainArguments];\
[invocation invoke];\
}\
_Pragma("clang diagnostic pop")\
} while (0)

-(id)init:(NSDictionary*)aDic
{
    if(Screen_Type == 3){
        self = [super initWithNibName:@"veivoWebView2" bundle:nil];
    }
    else{
        self = [super initWithNibName:@"veivoWebView2" bundle:nil];
    }

    if (self)
    {
        adiction = aDic;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
//        case 2001:
//            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
//            [UIApplication sharedApplication].statusBarHidden = YES;
//            break;
//        default:
//            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];;
//    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];

//    //微信注册
//    [WXApi registerApp:@"wx969cbab03c4c292f" withDescription:@"weixin"];
    
    //设置菜单
    menuArray = [[NSMutableArray alloc] init];
    menuTxtArray = [[NSMutableArray alloc] init];
    
    NSString * isShare = [adiction objectForKey:@"isShare"];
    NSString * language= [adiction objectForKey:@"language"];
    
    if([isShare isEqualToString:@"1"]){
        [menuArray addObject:@"1"];//分享到动态
        
        if([language isEqualToString:@"zh_CN"]){
            [menuTxtArray addObject:@"分享到动态"];
        }
        else{
            [menuTxtArray addObject:@"Tweet"];
        }
    }
    
    [menuArray addObject:@"2"];//推送
    [menuArray addObject:@"3"];//短信
    [menuArray addObject:@"4"];//评论
    [menuArray addObject:@"5"];//云笔记
    [menuArray addObject:@"6"];//关闭
    //[menuArray addObject:@"5"];//调整字体
    
    if([language isEqualToString:@"zh_CN"]){
        [menuTxtArray addObject:@"推送"];//推送
        [menuTxtArray addObject:@"短信"];//短信
        [menuTxtArray addObject:@"评论"];//评论
        [menuTxtArray addObject:@"云笔记"];//云笔记
        [menuTxtArray addObject:@"关闭"];
        //[menuTxtArray addObject:@"调整字体"];//调整字体
        
        alertTitle = @"提示";
        alertMsg   = @"请输入内容";
        alertOk    = @"确定";
        alertCancel= @"取消";
        
        [sendBt setTitle:@"发送" forState:UIControlStateNormal];
        
        [titlelabel setText:@"加载中..."];
    }
    else{
        [menuTxtArray addObject:@"Push"];//推送
        [menuTxtArray addObject:@"Message"];//短信
        [menuTxtArray addObject:@"Comment"];//评论
        [menuTxtArray addObject:@"Cloud Notes"];//云笔记
        [menuTxtArray addObject:@"Close"];
        //[menuTxtArray addObject:@"Adjust the font"];//调整字体
        
        alertTitle = @"Prompt";
        alertMsg   = @"Please input content";
        alertOk    = @"Ok";
        alertCancel= @"Cancel";
        
        [sendBt setTitle:@"Send" forState:UIControlStateNormal];
        
        [titlelabel setText:@"Loading..."];
    }
    
    
    //加载网址
    NSString * urlstr     = [adiction objectForKey:@"url"];
    urlstr = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

//    NSURL * url = [NSURL URLWithString:urlstr];
//    NSURLRequest * req = [NSURLRequest requestWithURL:url];
//
//    [webView loadRequest:req];
    
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlstr]]];
    
    [menuTable reloadData];
    
    //设置颜色
    NSString * colorstr = [adiction objectForKey:@"themeColor"];
    NSRange redRange;redRange.length=2;redRange.location=1;
    NSString * rgbRed   = [colorstr substringWithRange:redRange];
    NSRange greenRange;greenRange.length = 2;greenRange.location =3;
    NSString * rgbGreen = [colorstr substringWithRange:greenRange];
    NSRange blueRange;blueRange.length=2;blueRange.location=5;
    NSString * rgbBlue  = [colorstr substringWithRange:blueRange];
    
    CGFloat red   = [self floatFromHexString:rgbRed];
    CGFloat green = [self floatFromHexString:rgbGreen];
    CGFloat blue  = [self floatFromHexString:rgbBlue];
    UIColor * athemColor = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1.0f];
    
    thmeColor = athemColor;
    [titleView setBackgroundColor:thmeColor];
    
//    self.view.window.rootViewController.view.backgroundColor = [UIColor blueColor] ;
    webView.superview.backgroundColor=thmeColor;
    
    
    UISwipeGestureRecognizer * ecognizer = [[UISwipeGestureRecognizer alloc]
                            initWithTarget:self action:@selector(handleSwipeFrom:)];
    [webView addGestureRecognizer:ecognizer];
    
    UISwipeGestureRecognizer * ecognizertitle = [[UISwipeGestureRecognizer alloc]
            initWithTarget:self action:@selector(handleSwipeFrom:)];
    [titleView addGestureRecognizer:ecognizertitle];
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionDown) {
        
        NSLog(@"swipe down");
        //执行程序
    }
    if(recognizer.direction==UISwipeGestureRecognizerDirectionUp) {
        
        NSLog(@"swipe up");
        //执行程序
    }
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionLeft) {
        
        NSLog(@"swipe left");
        //执行程序
    }
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        
        NSLog(@"swipe right");
        //[self.navigationController popViewControllerAnimated:YES];
        [self backAction:nil];
    }
}

- (CGFloat)floatFromHexString:(NSString *)hexString { //
    //假设一定是两位的字符
    NSRange firtRange;firtRange.length=1;firtRange.location=0;
    NSString * firtChar  = [hexString substringWithRange:firtRange];
    NSRange secondRange;secondRange.length=1;secondRange.location=1;
    NSString * secondChar= [hexString substringWithRange:secondRange];
    
    firtChar   = [self getRealHexChar:firtChar];
    secondChar = [self getRealHexChar:secondChar];
    
    CGFloat result =0;
    CGFloat firtfloat   = [firtChar floatValue];
    CGFloat secondFloat = [secondChar floatValue];
    result = firtfloat * 16 + secondFloat;
    return result;
}

-(NSString*)getRealHexChar:(NSString*)aChar
{
    NSString * realChar = aChar;
    if([aChar isEqualToString:@"A"] || [aChar isEqualToString:@"a"]){
        realChar = @"10";
    }
    else if([aChar isEqualToString:@"B"] || [aChar isEqualToString:@"b"]){
        realChar = @"11";
    }
    else if([aChar isEqualToString:@"C"] || [aChar isEqualToString:@"c"]){
        realChar = @"12";
    }
    else if([aChar isEqualToString:@"D"] || [aChar isEqualToString:@"d"]){
        realChar = @"13";
    }
    else if([aChar isEqualToString:@"E"] || [aChar isEqualToString:@"e"]){
        realChar = @"14";
    }
    else if([aChar isEqualToString:@"F"] || [aChar isEqualToString:@"f"]){
        realChar = @"15";
    }
    return realChar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setFullScreen:YES];
    
    //对键盘notify的响应，以实现历史记录的尺寸，在输入法变化时，动态变化
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHidden:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

//键盘将要出现
- (void)keyboardWillShow:(NSNotification *)n
{
    //根据键盘的情况修正历史记录的坐标
    NSDictionary* userInfo = [n userInfo];
    // get the size of the keyboard
    NSValue* boundsValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [boundsValue CGRectValue].size;
    //动画显示历史纪录
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0];
    
    //修正输入框的矫正
    CGRect cgfFrame = commonView.frame;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    cgfFrame.origin.y = (screenHeight - keyboardSize.height)
    - cgfFrame.size.height;
    commonView.frame = cgfFrame;
    
    [UIView commitAnimations];
}

//键盘将要消失
-(void)keyboardWillHidden:(NSNotification*)n
{
    //根据键盘的情况坐标
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0];
    
    //修正输入框的矫正
    CGRect cgfFrame = commonView.frame;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    cgfFrame.origin.y = (screenHeight - cgfFrame.size.height);
    commonView.frame = cgfFrame;

    [UIView commitAnimations];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self setFullScreen:NO];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIKeyboardWillShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIKeyboardWillHideNotification
     object:nil];
}

- (void)setFullScreen:(BOOL)fullScreen
{
    // 状态条
    //[UIApplication sharedApplication].statusBarHidden = fullScreen;
    // 导航条
    //[self.navigationController setNavigationBarHidden:fullScreen];
    // tabBar的隐藏通过在初始化方法中设置hidesBottomBarWhenPushed属性来实现
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)backAction:(id)sender
{
    if([webView canGoBack])
    {
        [webView goBack];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(IBAction)moreAction:(id)sender
{
    //显示菜单
    iMenuCover.hidden = !iMenuCover.hidden;
    
    CGRect tableframe = menuTable.frame;
    tableframe.size.height = [menuTable contentSize].height;
    menuTable.frame = tableframe;
}

-(IBAction)hiddenCover:(id)sender
{
    iMenuCover.hidden = !iMenuCover.hidden;
}

- (void)webViewDidFinishLoad:(UIWebView *)awebView {
    // 防止内存飙升
    
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];//自己添加的，原文没有提到。
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];//自己添加的，原文没有提到。
    
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSString * js = @"document.title";
   // NSString * titlestr = awebView.title;
   NSString * titlestr = [awebView stringByEvaluatingJavaScriptFromString:js];
    if(titlestr)
    {
        [titlelabel setText:titlestr];
    }
    
    //修改服务器页面的meta的值  
    NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=device-width,initial-scale=1.0, maximum-scale=1.0,viewport-fit=cover\"", webView.frame.size.width];  
    [webView stringByEvaluatingJavaScriptFromString:meta];
    //[webView evaluateJavaScript:meta completionHandler:nil];
}


//section数目
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//section里面cell数目
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [menuTxtArray count];
}

//
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

//cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 24)];
    [view setBackgroundColor:[UIColor clearColor]];
    return view;
}

//初始化cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    veivoWebCell *cell = nil;
    static NSString *cell1 = @"cell1";
    cell = [tableView dequeueReusableCellWithIdentifier:cell1];
    cell = nil;
    if (!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"veivoWebCell" owner:self options:nil] objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType  = UITableViewCellAccessoryNone;
    }
    
    [cell.celltext setText:[menuTxtArray objectAtIndex:[indexPath row]]];

    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    [cell.celltext setCenter:CGPointMake(75, 32)];
    [cell.contentView setBackgroundColor:thmeColor];
    
    return cell;
}

//- (BOOL)webView:(WKWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(WKWebViewNavigationType)navigationType
//{
//    curUrl = [[request URL] absoluteString];
//    return YES;
//}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{

    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
    
    
//    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
//    NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
//    for (NSHTTPCookie *cookie in cookies) {
//        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
//    }
//    decisionHandler(WKNavigationResponsePolicyAllow);
    NSHTTPCookieStorage *cookieStorage  = ((AppDelegate*)([UIApplication sharedApplication].delegate)).cs;
    
    NSMutableArray *arrCookies = [[NSMutableArray alloc]init];
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        //        NSString *excuteJSString = [NSString stringWithFormat:@"setCookie('%@', '%@', 1);", cookie.name, cookie.value];
        //        NSLog(@"%@", excuteJSString);
        [arrCookies addObject:cookie];
    }

}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
//    //如果是跳转一个新页面
//    if (navigationAction.targetFrame == nil) {
//        [webView loadRequest:navigationAction.request];
//    }
//    
//    decisionHandler(WKNavigationActionPolicyAllow);
//    
    
}





- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //隐藏菜单
    [self hiddenCover:nil];
    
    //执行js
    NSString * curCellType = [menuArray objectAtIndex:indexPath.row];
    
    //NSString * urlstr     = [adiction objectForKey:@"url"];
     NSString * urlstr = curUrl;

    NSString * js = @"window.location.href";
   
    
//     [webView evaluateJavaScript:js completionHandler:^(id result, NSError *error) {
//         urlstr = result;
//    }];
//    NSLog(webView.URL.absoluteString);
    //urlstr = webView.URL.absoluteString;
    urlstr = [webView stringByEvaluatingJavaScriptFromString:js];
    //urlstr = [webView evaluateJavaScript:js completionHandler:nil];
    
    NSString * jstext = [NSString stringWithFormat:@"%@%@",titlelabel.text,urlstr];
    
    NSString * script;
    if([curCellType isEqualToString:@"1"]){      //分享到动态
       script = [NSString stringWithFormat:@"Veivo.sendAsMyTweet(\"%@\",function(){alert(App.locale.appbase_message_send_ok);});",jstext];
    }
    else if([curCellType isEqualToString:@"2"]){ //推送
        script = [NSString stringWithFormat:@"Veivo.pushContent(\"%@\",function(){},function(){alert(App.locale.appbase_message_send_ok);});",jstext];
        
    }
    else if([curCellType isEqualToString:@"3"]){ //短信
        script = [NSString stringWithFormat:@"Veivo.shareByMessage(\"%@\",function(){},function(){alert(App.locale.appbase_message_send_ok);});",jstext];
    }
    else if([curCellType isEqualToString:@"4"]){ //评论
        script = [NSString stringWithFormat:@"Veivo.commentAndShare(\"%@\",\"%@\",function(){alert(App.locale.appbase_message_send_ok);});",jstext,@"apple"];
    }
    else if([curCellType isEqualToString:@"5"]){ //调整字体
        script = [NSString stringWithFormat:@"Veivo.sendAsNote(\"%@\",function(){alert(App.locale.appbase_message_send_ok);});",jstext];
    }
    else if([curCellType isEqualToString:@"6"]){
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([curCellType isEqualToString:@"4"])
    {
        /*
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg
                                                      delegate:self
                                cancelButtonTitle:alertCancel otherButtonTitles:alertOk, nil];
        alert.alertViewStyle=UIAlertViewStylePlainTextInput;
        //UIAlertViewStyleDefault 默认风格，无输入框
        //UIAlertViewStyleSecureTextInput 带一个密码输入框
        //UIAlertViewStylePlainTextInput 带一个文本输入框
        //UIAlertViewLoginAndPasswordInput 带一个文本输入框，一个密码输入框
        [alert show];
         */
        
        commonView.hidden = NO;
    }
    else if([curCellType isEqualToString:@"1"]){
       // NSString * excutstr = [self.delegate excutJavas:script];
       // UIAlertView *alert= [[UIAlertView alloc] initWithTitle:alertTitle message:excutstr
       //                                            delegate:nil cancelButtonTitle:alertOk otherButtonTitles:nil, nil];
        //[alert show];
        
        //[self.delegate excutJavasWithShow:script WithTitle:alertTitle WithOk:alertOk];
        [self.delegate excutJs:script];
        //[self.webView evaluateJavaScript:script completionHandler:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self.delegate excutJs:script];
       // [self.webView evaluateJavaScript:script completionHandler:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        NSString * inputStr = [[alertView textFieldAtIndex:0] text];
        
        if(inputStr.length <=0)
        {
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg
                                                          delegate:nil cancelButtonTitle:alertOk otherButtonTitles:nil, nil];
            [alert show];
        }
        else
        {
            //NSString * urlstr     = [adiction objectForKey:@"url"];
            NSString * urlstr = curUrl;
            NSString * jstext = [NSString stringWithFormat:@"%@%@",titlelabel.text,urlstr];
            NSString * script = [NSString stringWithFormat:@"Veivo.commentAndShare(\"%@\",\"%@\",function(){alert(App.locale.appbase_message_send_ok);});",jstext,inputStr];
            
            [self.delegate excutJs:script];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

-(IBAction)hiddenCommonInput:(id)sender
{
    commonView.hidden = YES;
    [editTF resignFirstResponder];
    [backGroundBg setImage:[UIImage imageNamed:@"intputbgnor"]];
}

-(IBAction)sendbtAction:(id)sender
{
    NSString * inputStr = [editTF text];
    
    if(inputStr.length <=0)
    {
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg
                                                      delegate:nil cancelButtonTitle:alertOk otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        [editTF resignFirstResponder];
        //NSString * urlstr     = [adiction objectForKey:@"url"];
        NSString * urlstr = curUrl;
        NSString * js = @"window.location.href";
       // urlstr = webView.URL;
        //urlstr = [webView evaluateJavaScript:js completionHandler:nil];
        urlstr = [webView stringByEvaluatingJavaScriptFromString:js];
        
        NSString * jstext = [NSString stringWithFormat:@"%@%@",titlelabel.text,urlstr];
        NSString * script = [NSString stringWithFormat:@"Veivo.commentAndShare(\"%@\",\"%@\",function(){alert(App.locale.appbase_message_send_ok);});",jstext,inputStr];
        
        [self.delegate excutJs:script];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [backGroundBg setImage:[UIImage imageNamed:@"intputtextprebg"]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [backGroundBg setImage:[UIImage imageNamed:@"intputbgnor"]];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * curStr = [textField text];
    NSString * newStr = [curStr stringByReplacingCharactersInRange:range withString:string];
    if([newStr length]>0){
        [sendBt setBackgroundImage:[UIImage imageNamed:@"sendbgtxt"] forState:UIControlStateNormal];
    }
    else{
        [sendBt setBackgroundImage:[UIImage imageNamed:@"sendbtbg"] forState:UIControlStateNormal];
    }
    return YES;
}

@end
