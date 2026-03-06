//
//  outveivoWebView.m
//  veivo
//
//  Created by musmile on 15/1/5.
//  Copyright (c) 2015年 Fn. All rights reserved.
//

#import "outveivoWebView.h"
#import "veivoWebCell.h"


@interface outveivoWebView ()

@end

@implementation outveivoWebView
@synthesize webView;
@synthesize delegate;

-(id)init:(NSDictionary*)aDic
{
    self = [super initWithNibName:@"outveivoWebView" bundle:nil];
    if (self)
    {
        adiction = aDic;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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
    //[menuArray addObject:@"5"];//调整字体
    
    if([language isEqualToString:@"zh_CN"]){
        [menuTxtArray addObject:@"推送"];//推送
        [menuTxtArray addObject:@"短信"];//短信
        [menuTxtArray addObject:@"评论"];//评论
        [menuTxtArray addObject:@"云笔记"];//云笔记
        //[menuTxtArray addObject:@"调整字体"];//调整字体
    }
    else{
        [menuTxtArray addObject:@"Push"];//推送
        [menuTxtArray addObject:@"Message"];//短信
        [menuTxtArray addObject:@"Comment"];//评论
        [menuTxtArray addObject:@"Cloud Notes"];//云笔记
        //[menuTxtArray addObject:@"Adjust the font"];//调整字体
    }
    
    
    //加载网址
    NSString * urlstr     = [adiction objectForKey:@"mainurl"];
    NSString* webStringURL = [urlstr
                stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * url = [NSURL URLWithString:webStringURL];
    NSURLRequest * req = [NSURLRequest requestWithURL:url];
    
    [webView loadRequest:req];
    
    [menuTable reloadData];
    
    [self backAction:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setFullScreen:YES];
    [self backAction:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self setFullScreen:NO];
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
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate viewDidDismiss];
    }];
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

- (void)webViewDidFinishLoad:(WKWebView *)awebView {
    
    // 防止内存飙升
    awebView.customUserAgent=@"Mozilla/5.0 (iPhone; CPU iPhone OS 16_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.2 Mobile/15E148 Safari/604.1 veivo22 veivowk v202";
    
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];//自己添加的，原文没有提到。
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];//自己添加的，原文没有提到。
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    NSString * js = @"document.title";
    NSString * titlestr = awebView.title;
//    NSString * titlestr = [awebView stringByEvaluatingJavaScriptFromString:js];
    if(titlestr)
    {
        [titlelabel setText:titlestr];
    }
    
    //修改服务器页面的meta的值
    NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=device-width,initial-scale=1.0, maximum-scale=1.0,viewport-fit=cover\"", webView.frame.size.width];
    //[webView stringByEvaluatingJavaScriptFromString:meta];
    webView.customUserAgent=@"Mozilla/5.0 (iPhone; CPU iPhone OS 16_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.2 Mobile/15E148 Safari/604.1 veivo22 veivowk v202";
    [webView evaluateJavaScript:meta completionHandler:nil];
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
    return 44;
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //隐藏菜单
    [self hiddenCover:nil];
    
    //执行js
    NSString * curCellType = [menuArray objectAtIndex:indexPath.row];
    
    NSString * urlstr     = [adiction objectForKey:@"url"];
    NSString * jstext = [NSString stringWithFormat:@"%@+%@",titlelabel.text,urlstr];
    
    NSString * script;
    if([curCellType isEqualToString:@"1"]){      //分享到动态
       script = [NSString stringWithFormat:@"Veivo.sendAsMyTweet(\"%@\",function(){alert(App.locale.appbase_message_send_ok);});",jstext];
    }
    else if([curCellType isEqualToString:@"2"]){ //推送
        script = [NSString stringWithFormat:@"Veivo.pushContent(\"%@\",function(){},function(){alert(App.locale.appbase_message_send_ok);});",script];
        
    }
    else if([curCellType isEqualToString:@"3"]){ //短信
        script = [NSString stringWithFormat:@"Veivo.pushContent(\"%@\",function(){},function(){alert(App.locale.appbase_message_send_ok);});",jstext];
    }
    else if([curCellType isEqualToString:@"4"]){ //评论
        script = [NSString stringWithFormat:@"Veivo.sendAsNote(\"%@\",function(){alert(App.locale.appbase_message_send_ok);});" ,jstext];
    }
    else if([curCellType isEqualToString:@"5"]){ //调整字体
        
    }
    
    [self.webView evaluateJavaScript:script completionHandler:nil];
    //[self.delegate excutJs:script];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
