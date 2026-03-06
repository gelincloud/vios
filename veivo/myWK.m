//
//  myWK.m
//  veivo
//
//  Created by LinXiaojun on 2018/8/8.
//  Copyright © 2018年 Fn. All rights reserved.
//

#import "myWK.h"

@implementation myWK

- (instancetype)initWithCoder:(NSCoder *)coder
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    WKWebViewConfiguration *myConfiguration = [WKWebViewConfiguration new];
    self = [super initWithFrame:frame configuration:myConfiguration];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    return self;
}

@end
