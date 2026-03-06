//
//  ShareViewController.m
//  shareextention
//
//  Created by musmile on 15/1/12.
//  Copyright (c) 2015年 Fn. All rights reserved.
//

#import "ShareViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "outveivoWebView.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (void)viewDidLoad
{
    NSExtensionItem * imageItem = [self.extensionContext.inputItems firstObject];
    
    NSItemProvider * imageItemProvider = [[imageItem attachments] firstObject];
    
    if([imageItemProvider hasItemConformingToTypeIdentifier:(NSString*)kUTTypeURL])
    {
        NSLog(@"xxxxxxxx");
        [imageItemProvider loadItemForTypeIdentifier:(NSString*)kUTTypeURL options:nil completionHandler:^(NSURL* imageUrl, NSError *error) {
            //在这儿做自己的工作
            NSLog(@"xxxxxxx123 = %@",imageUrl.absoluteString);
            urlString = imageUrl.absoluteString;
            
        }];
    }
    
}


- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    NSExtensionItem * imageItem = [self.extensionContext.inputItems firstObject];
    if(!imageItem)
    {
        return NO;
    }
    NSItemProvider * imageItemProvider = [[imageItem attachments] firstObject];
    if(!imageItemProvider)
    {
        return NO;
    }
    if([imageItemProvider hasItemConformingToTypeIdentifier:@"public.url"]&&self.contentText)
    {
        return YES;
    }
    
    
    return NO;
}

-(void)viewDidDismiss
{
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    //[self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
    
    NSExtensionItem *inputItem = self.extensionContext.inputItems.firstObject;
    
    NSExtensionItem *outputItem = [inputItem copy];
    outputItem.attributedContentText = [[NSAttributedString alloc] initWithString:self.contentText attributes:nil];
    
    NSString * userInputTxt = [outputItem.attributedContentText string];
    if(userInputTxt == nil) userInputTxt=@"";
    
    urlString = [urlString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    NSString * url = [NSString stringWithFormat:@"%@%@id=?%@",@"veivo://",urlString,userInputTxt];
    //url =[NSString stringWithFormat:@"veivo://%@",urlString];
    
    NSMutableDictionary * mudic = [[NSMutableDictionary alloc] init];
    [mudic setValue:url forKey:@"mainurl"];
    [mudic setValue:urlString forKey:@"url"];
    [mudic setValue:@"1" forKey:@"isShare"];
    [mudic setValue:@"zh_CN" forKey:@"language"];
    
    outveivoWebView * webview = [[outveivoWebView alloc] init:mudic];
    webview.delegate = self;
    NSLog(@"%@",urlString);
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSLog(@"%@",url);
    
    [self presentViewController:webview animated:YES completion:^{
    }];
    
//    UIResponder* responder = self;
//    while ((responder = [responder nextResponder]) != nil) {
//        NSLog(@"responder = %@", responder);
//        if ([responder respondsToSelector:@selector(openURL:)] == YES) {
//            [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:@""]];
//        }
//    }
    
//    UIResponder *responder = self;
//    while(responder){
//        if ([responder respondsToSelector: @selector(openURL:)]){
//            [responder performSelector: @selector(openURL:) withObject: [NSURL URLWithString:[@"veivo://" stringByAppendingString: urlString].lowercaseString ]];
//        }
//        responder = [responder nextResponder];
//    }
    
    
    UIResponder *responder = self;
    while(responder){
        if ([responder respondsToSelector: @selector(openURL:)]){
            [responder performSelector: @selector(openURL:) withObject: [NSURL URLWithString:url ]];
        }
        responder = [responder nextResponder];
    }
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    SLComposeSheetConfigurationItem * login = [[SLComposeSheetConfigurationItem alloc] init];
    [login setTitle:@"登陆"];
    [login setValue:@"1"];
    return @[];
}

@end
