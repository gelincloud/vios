//
//  outveivoWebView.h
//  veivo
//
//  Created by musmile on 15/1/5.
//  Copyright (c) 2015年 Fn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@protocol outveivoWebViewProtocol <NSObject>

@optional
-(void)excutJs:(NSString*)jstxt;
-(void)viewDidDismiss;

@end


@interface outveivoWebView : UIViewController
{
    IBOutlet WKWebView * webView;

    IBOutlet UILabel * titlelabel;
    NSDictionary * adiction;
    
    NSMutableArray * menuArray;
    NSMutableArray * menuTxtArray;
    
    IBOutlet UIView * iMenuCover;
    
    IBOutlet UITableView * menuTable;
    
}

@property(nonatomic,strong)IBOutlet WKWebView * webView;

@property(nonatomic,assign)id<outveivoWebViewProtocol> delegate;

-(id)init:(NSDictionary*)aDic;

-(IBAction)backAction:(id)sender;

-(IBAction)moreAction:(id)sender;

-(IBAction)hiddenCover:(id)sender;

@end
