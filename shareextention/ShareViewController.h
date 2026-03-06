//
//  ShareViewController.h
//  shareextention
//
//  Created by musmile on 15/1/12.
//  Copyright (c) 2015年 Fn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "AppDelegate.h"
#import "outveivoWebView.h"

@interface ShareViewController : SLComposeServiceViewController<outveivoWebViewProtocol>
{
    NSString * urlString;
}
@end
