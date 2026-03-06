//
//  WriteTweetViewController.h
//  veivo
//
//  Created by LinXiaojun on 2018/11/10.
//  Copyright © 2018年 Fn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "BaseViewController.h"
#import "AFHTTPSessionManager.h"
#import "AFNetworking.h"
#import "SJAvatarBrowser.h"
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "AiChecksum.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+ASGif.h"
#import "JSONKit.h"
#import<MediaPlayer/MediaPlayer.h>

#import "BBVoiceRecordController.h"
#import "UIColor+BBVoiceRecord.h"
#import "BBHoldToSpeakButton.h"
#import "lame.h"

#import <CTAssetsPickerController/CTAssetsPickerController.h>

#import "UserEntity.h"
#import "UserGroup.h"

#import "NSString+emoji.h"


NS_ASSUME_NONNULL_BEGIN

@interface WriteTweetViewController : UIViewController<UITextFieldDelegate>{
    IBOutlet UIButton * sendBt;
    IBOutlet UITextView *textField;
    IBOutlet UIAlertView *baseAlert;
    IBOutlet UIImageView *image;
    IBOutlet UIImageView *takePhoto;
    IBOutlet UIImageView *video;
    IBOutlet UIImageView *voice;
    IBOutlet UIImageView *imageView;//预览图
    IBOutlet UIView *attachStackView;
    
    IBOutlet UIStackView *preStackView;
    IBOutlet UIImageView *pre1;
    IBOutlet UIImageView *pre2;
    IBOutlet UIImageView *pre3;
    IBOutlet UIImageView *pre4;
    IBOutlet UIImageView *avatar;
    IBOutlet UILabel *writeto;
    IBOutlet UIView *cover1;
    IBOutlet UIView *cover2;
    IBOutlet UIView *cover3;
    IBOutlet UIView *cover4;
    
    IBOutlet UIView *attachSuperView;
    
    IBOutlet UITextField *price;
    IBOutlet UILabel *pricelabel;
    
}
-(IBAction)backAction:(id)sender;
-(NSData *)zipNSDataWithImage:(UIImage *)sourceImage;
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
- (void)textFieldDidEndEditing:(UITextField *)textField;

@end


NS_ASSUME_NONNULL_END
