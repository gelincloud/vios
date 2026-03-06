//
//  veivoWebView.h
//  veivo
// 打开的链接
//  Created by musmile on 15/1/5.
//  Copyright (c) 2015年 Fn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@protocol veivoWebViewProtocol <NSObject>

-(NSString*)excutJavas:(NSString*)jstxt;
-(BOOL)excutJs:(NSString*)aJsStr;

-(NSString*)excutJavasWithShow:(NSString*)jstxt
                     WithTitle:(NSString*)title
                        WithOk:(NSString*)okStr;

@end


@interface veivoWebView : UIViewController
{
    IBOutlet UIWebView * webView;

    IBOutlet UILabel * titlelabel;
    NSDictionary * adiction;
    
    NSMutableArray * menuArray;
    NSMutableArray * menuTxtArray;
    
    IBOutlet UIView * iMenuCover;
    
    IBOutlet UITableView * menuTable;
    
    IBOutlet UIView * titleView;
    
    UIColor * thmeColor;
    
    NSString * alertTitle;
    NSString * alertMsg;
    NSString * alertOk;
    NSString * alertCancel;
    
    NSString * curUrl;
    
    IBOutlet UIView * commonView;
    IBOutlet UIButton * sendBt;
    IBOutlet UITextField * editTF;
    
    IBOutlet UIImageView * backGroundBg;
}

@property(nonatomic,strong)IBOutlet UIWebView * webView;

@property(nonatomic,assign)id<veivoWebViewProtocol> delegate;

-(id)init:(NSDictionary*)aDic;

-(IBAction)backAction:(id)sender;

-(IBAction)moreAction:(id)sender;

-(IBAction)hiddenCover:(id)sender;

-(IBAction)hiddenCommonInput:(id)sender;

-(IBAction)sendbtAction:(id)sender;

- (void)keyboardWillShow:(NSNotification *)n;

-(void)keyboardWillHidden:(NSNotification*)n;

@end
