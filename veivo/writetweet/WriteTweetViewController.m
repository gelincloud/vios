//
//  WriteTweetViewController.m
//  veivo
//
//  Created by LinXiaojun on 2018/11/10.
//  Copyright © 2018年 Fn. All rights reserved.
//

#import "WriteTweetViewController.h"
#import "AppDelegate.h"
#import "BaseViewController.h"
#import "AFHTTPSessionManager.h"
#import "AFNetworking.h"
#import "SJAvatarBrowser.h"
#import <Foundation/Foundation.h>
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


#define kFakeTimerDuration       0.2
#define kMaxRecordDuration       30     //最长录音时长
#define kRemainCountingDuration  10     //剩余多少秒开始倒计时

@interface WriteTweetViewController ()
{
    AVAudioRecorder *recorder;//录音的对象
    NSTimer *timer;//时间
    NSURL *urlPlay;//保存路径
    NSMutableDictionary *attach;
    NSString * activeUser;
    MPMoviePlayerController *playerVc;
    NSMutableDictionary *paths;
    AVAudioRecorder * _recorder;
    NSURL *voiceFileUrl;
    NSURL *voiceurl1;
    UIView *customView;
    NSString *appid;
    NSString *writetovalue;
    UIView *first;
    UITableView *tableView;
    NSMutableArray *_dataSource;
    
    BOOL isHaveDian;
    
    BOOL canBack;
    
    NSString *send;
    NSString *sent;
    NSString *sending;
    NSString *selectanapptotweet;
    NSString *pricetxt;
    
    NSMutableDictionary *appid_dic;
    NSMutableDictionary *writeto_dic;

    
}
@property (nonatomic, strong) BBVoiceRecordController *voiceRecordCtrl;
//@property (nonatomic, weak) IBOutlet BBHoldToSpeakButton *btnRecord;
@property (nonatomic, assign) BBVoiceRecordState currentRecordState;
@property (nonatomic, strong) NSTimer *fakeTimer;
@property (nonatomic, assign) float duration;
@property (nonatomic, assign) BOOL canceled;

@property (nonatomic, assign) PHAssetCollection *plCollection;

@end

@implementation WriteTweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    NSString *language  = ((AppDelegate*)([UIApplication sharedApplication].delegate)).language;
    NSLog(@"%@",language);
    
    NSString *appid=((AppDelegate*)([UIApplication sharedApplication].delegate)).appid;
    NSLog(@"appid=%@",appid);
    NSString *username=((AppDelegate*)([UIApplication sharedApplication].delegate)).username;
    NSLog(@"appid=%@",username);
    NSString *avatarUrl = [self avatarString:appid];
    NSLog(@"avatar=%@",avatarUrl);
    
    UIImage * avatarImg = [self getImageFromURL:avatarUrl];
    [avatar setImage:avatarImg];
    avatar.userInteractionEnabled = YES;
   UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAvatar)];
    t.numberOfTapsRequired = 1;
   // [image setUserInteractionEnabled:YES];
    [avatar addGestureRecognizer:t];
    
    [avatar setHidden:YES];//隐藏头像，改用文字
    
    [writeto setTextAlignment:UITextAlignmentCenter];
    [writeto setText:username];
     writeto.userInteractionEnabled = YES;
    UITapGestureRecognizer *t1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLabel)];
    t1.numberOfTapsRequired = 1;
    // [image setUserInteractionEnabled:YES];
    [writeto addGestureRecognizer:t1];
    
    
    [self initdata];
    
    first = [[UIView alloc] initWithFrame:CGRectMake(30, 100, 300, 135)];
    first.backgroundColor = [UIColor blueColor];[self.view addSubview:first];
    first.hidden = YES;
    
    tableView = [self makeTableView];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"newFriendCell"];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    // 用此方式替代TableView代理的didSelectRowAtIndexPath函数
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myTableViewClick:)];
    [tableView addGestureRecognizer:tapGesture];
    
    appid_dic = [[NSMutableDictionary alloc] init];
    
    writeto_dic = [[NSMutableDictionary alloc] init];

    
//    NSUInteger indexs[] = {1};
//    NSIndexPath *oneNodeIndexPath = [NSIndexPath indexPathWithIndexes:indexs length:1];
//    NSLog(@"oneNodeIndexPath: %@", oneNodeIndexPath);
//    [self tableView:tableView cellForRowAtIndexPath:oneNodeIndexPath];
    
    [first addSubview:tableView];

    if([language isEqualToString:@"en"] )
    {
        send = @"Send";
        sent = @"Sent.";
        sending = @"Sending...";
        selectanapptotweet=@"Select an app to tweet";
        pricetxt = @"Tips Amount:";
    }else{
        send = @"发送";
        sent = @"已发送";
        sending = @"发送中...";
        selectanapptotweet = @"写到哪个应用？";
        pricetxt = @"求赏金额($)：";
    }
    
    [pricelabel setText:pricetxt];
    
    canBack = NO;
    
    //加载text
//    [textField setValue:<#(nullable id)#> forKey:<#(nonnull NSString *)#>]
//    ((AppDelegate*)([UIApplication sharedApplication].delegate)).veivoDraft;
//
    textField.text = ((AppDelegate*)([UIApplication sharedApplication].delegate)).veivoDraft;
    
    attach = [[NSMutableDictionary alloc] init];
    paths = [[NSMutableDictionary alloc] init];
    
    UISwipeGestureRecognizer * ecognizer = [[UISwipeGestureRecognizer alloc]
                                            initWithTarget:self action:@selector(handleSwipeFrom:)];
    [self.view addGestureRecognizer:ecognizer];
    [sendBt setTitle:send forState:UIControlStateNormal];
    textField.delegate = self;
   
    //拖动退出键盘
    [textField setUserInteractionEnabled:YES];
    textField.scrollEnabled = YES;
    textField.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [sendBt addTarget:self
                          action:@selector(BtnClick:)
                forControlEvents:UIControlEventTouchUpInside];
    
    //textfield背景颜色
    // textField.backgroundColor = [self hexToColor:ffffff];

    //自动聚焦
      [textField becomeFirstResponder];
    
   //相册
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    [image setUserInteractionEnabled:YES];
    [image addGestureRecognizer:singleTap];
    
    //拍照
     UITapGestureRecognizer *singleTapTakePhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takePhotoDetected)];
    singleTapTakePhoto.numberOfTapsRequired = 1;
    [takePhoto setUserInteractionEnabled:YES];
    [takePhoto addGestureRecognizer:singleTapTakePhoto];
    
    //拍视频
    UITapGestureRecognizer *singleTapTakeVideo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takeVideoDetected)];
    singleTapTakeVideo.numberOfTapsRequired = 1;
    [video setUserInteractionEnabled:YES];
    [video addGestureRecognizer:singleTapTakeVideo];
    
    
    
    //选视频
//    UITapGestureRecognizer *singleTapTakePhoto2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takePhotoDetected2)];
//    singleTapTakePhoto2.numberOfTapsRequired = 1;
//    [voice setUserInteractionEnabled:YES];
//    [voice addGestureRecognizer:singleTapTakePhoto2];
    
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected2)];
    singleTap2.numberOfTapsRequired = 1;
    [voice setUserInteractionEnabled:YES];
    [voice addGestureRecognizer:singleTap2];
    
//    //uitextview
//    UITapGestureRecognizer *singleTapuitextview = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(uitextviewDetected)];
//    singleTapuitextview.numberOfTapsRequired = 1;
//    [textField setUserInteractionEnabled:YES];
//    [textField addGestureRecognizer:singleTapuitextview];
//
    //录音
//    UITapGestureRecognizer *singleTapTakeAudio = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takeAudioDetected)];
//    singleTapTakeAudio.numberOfTapsRequired = 1;
//    [voice setUserInteractionEnabled:YES];
//    [voice addGestureRecognizer:singleTapTakeAudio];
    
    //button长按事件
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(btnLong:)];
//    longPress.minimumPressDuration = 0.5; //定义按的时间
//    [voice setUserInteractionEnabled:YES];
//    [voice addGestureRecognizer:longPress];
    
    
    
 
    
    //软键盘挡住布局
    //注册观察键盘的变化
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transformView:) name:UIKeyboardWillChangeFrameNotification object:nil];
//
   
    //发语音初始化
//    _btnRecord.layer.borderWidth = 0.5;
//    _btnRecord.layer.borderColor = [UIColor colorWithHex:0xA3A5AB].CGColor;
//    _btnRecord.layer.cornerRadius = 4;
//    _btnRecord.layer.masksToBounds = YES;
//    _btnRecord.enabled = NO;    //将事件往上传递
//    _btnRecord.titleLabel.font = [UIFont boldSystemFontOfSize:16];
//    [_btnRecord setTitleColor:[UIColor colorWithHex:0x565656] forState:UIControlStateNormal];
//    [_btnRecord setTitleColor:[UIColor colorWithHex:0x565656] forState:UIControlStateHighlighted];
//    [_btnRecord setTitle:@"Hold to talk" forState:UIControlStateNormal];
//
   
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        if (granted) {
            // 通过验证
        } else {
            // 未通过验证
        }
    }];
    
    
    // request authorization status
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // init picker
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            
            // set delegate
            picker.delegate = self;
            
            // Optionally present picker as a form sheet on iPad
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                picker.modalPresentationStyle = UIModalPresentationFormSheet;
            
            // present picker
            //自动打开
            //[self presentViewController:picker animated:YES completion:nil];
        });
    }];
    
    
//    //自定义键盘上面的view
//    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180, 45)];
//    customView.backgroundColor = [UIColor lightTextColor];
//    textField.inputAccessoryView = customView;
//    customView.userInteractionEnabled = YES;
//
//    //[attachStackView removeFromSuperview];
//   [customView addSubview:attachStackView];
    customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180, 45)];
    customView.backgroundColor = [UIColor lightTextColor];
    customView.userInteractionEnabled = YES;
    
    textField.inputAccessoryView = customView;
    price.inputAccessoryView = customView;

    attachSuperView = attachStackView.superview;
    //[attachStackView removeFromSuperview];
    
    
    
   // textField.delegate = self;
//    [textField addTarget:self
//                       action:@selector(textFieldDidChange:)
//             forControlEvents:UIControlEventEditingChanged];
    
    // 键盘出现的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    // 键盘消失的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
    
    price.delegate = self;
    price.placeholder=@"0";
    price.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    
    //appid
    NSString *ccc = ((AppDelegate*)([UIApplication sharedApplication].delegate)).veivoCookie;
    NSLog(@"cookie=%@",ccc);
}
#pragma mark -键盘监听方法
- (void)keyboardWasShown:(NSNotification *)notification
{
    NSLog(@"键盘出现");
    //自定义键盘上面的view
    [customView addSubview:attachStackView];

}
- (void)keyboardWillBeHiden:(NSNotification *)notification
{
    NSLog(@"键盘退出");
    //[textField.inputAccessoryView removeFromSuperview];
   // [attachStackView removeFromSuperview];
    
   
    
//    /* Top space to superview Y*/
  
    // [self.view addConstraint:leftButtonYConstraint];

    
    [attachSuperView addSubview:attachStackView];
    
    
//    NSLayoutConstraint *leftButtonYConstraint = [NSLayoutConstraint
//                                                 constraintWithItem:attachSuperView attribute:NSLayoutAttributeTop
//                                                 relatedBy:NSLayoutRelationEqual toItem:self attribute:
//                                                 NSLayoutAttributeTop multiplier:1.0f constant:258];
//    [attachSuperView addConstraint:leftButtonYConstraint];

    //[customView removeFromSuperview];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

//// 获得焦点
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//   // _descLabel.text = @"获得焦点";
//    NSLog(@"focused.");
//    //自定义键盘上面的view
//    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180, 45)];
//    customView.backgroundColor = [UIColor lightTextColor];
//    textField.inputAccessoryView = customView;
//    customView.userInteractionEnabled = YES;
//
//    //[attachStackView removeFromSuperview];
//    [customView addSubview:attachStackView];
//    return YES;
//}
//
//// 失去焦点
//- (void)textFieldDidEndEditing:(UITextField *)textField{
//   // _descLabel.text = @"失去焦点";
//    NSLog(@"blur.");
//}
- (BOOL)checkPermission {
    AVAudioSessionRecordPermission permission = [[AVAudioSession sharedInstance] recordPermission];
    return permission == AVAudioSessionRecordPermissionGranted;
}
- (void)configRecorder {
    // ...其他设置
    voiceFileUrl = [NSURL fileURLWithPath:[self filePathWithName:[self newRecorderName]]];
    NSLog(@"voiceFileUrl=%@",[voiceFileUrl absoluteString]);
    NSError *error = nil;
    NSDictionary *setting = [self recordSetting];
    _recorder = [[AVAudioRecorder alloc] initWithURL:voiceFileUrl settings:setting error:&error];
    if (error) {
        // 录音文件创建失败处理
    }
    _recorder.delegate = self;
    _recorder.meteringEnabled = YES;
    // ...其他设置
}
-(void)configRecorder1{
    //设置音频会话
    NSError *sessionError;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&sessionError];
    if (sessionError){
        NSLog(@"Error creating session: %@",[sessionError description]);
        
    }else{
        [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
        
    }
    NSError *error = nil;
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init];
    [recordSetting setObject:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setObject:[NSNumber numberWithFloat:22050] forKey:AVSampleRateKey];
    [recordSetting setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    [recordSetting setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [recordSetting setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    [recordSetting setObject:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
   /*
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"aaa.wav"];
    voiceurl1 = [NSURL fileURLWithPath:path];
   */
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"text.caf"];
    voiceurl1 = [NSURL URLWithString:path];

    
    _recorder = [[AVAudioRecorder alloc] initWithURL:voiceurl1 settings:recordSetting error:nil];
    _recorder.meteringEnabled = YES;
    [_recorder prepareToRecord];
}
-(NSDictionary *)recordSetting2{
    
        
    
        NSDictionary *recordFileSettings = [NSDictionary
                                            
                                                                                    dictionaryWithObjectsAndKeys:
                                            
                                                                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                            
                                                                                    AVEncoderAudioQualityKey,
                                            
                                                                                    [NSNumber numberWithInt:16],
                                            
                                                                                    AVEncoderBitRateKey,
                                            
                                                                                    [NSNumber numberWithInt:2],
                                            
                                                                                    AVNumberOfChannelsKey,
                                            
                                                                                    [NSNumber numberWithFloat:44100.0],
                                            
                                                                                    AVSampleRateKey,
                                            
                                                                                    nil];
    
        return recordFileSettings;
    
}

// 录音参数设置
- (NSDictionary *)recordSetting {
    
    NSMutableDictionary *recSetting = [[NSMutableDictionary alloc] init];
    // General Audio Format Settings
    
    recSetting[AVFormatIDKey] = @(kAudioFormatLinearPCM);
    recSetting[AVSampleRateKey] = @44100;
    
    
    
    /*
    recSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                
                [NSNumber numberWithFloat: 15000],AVSampleRateKey, //采样率
                
                [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                
                [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,//通道
                
                [NSNumber numberWithInt: AVAudioQualityMedium],AVEncoderAudioQualityKey,//音频编码质量
                
                nil];
    
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
   */
    
    
    //recSetting[AVNumberOfChannelsKey] = @2;
    // Linear PCM Format Settings
    //recSetting[AVLinearPCMBitDepthKey] = @24;
    //recSetting[AVLinearPCMIsBigEndianKey] = @YES;
    //recSetting[AVLinearPCMIsFloatKey] = @YES;
    // Encoder Settings
    //recSetting[AVEncoderAudioQualityKey] = @(AVAudioQualityMedium);
    //recSetting[AVEncoderBitRateKey] = @128000;
    
//    let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0)),//声音采样率
//                            AVFormatIDKey : NSNumber(value: Int32(kAudioFormatLinearPCM)), //编码格式
//                    AVNumberOfChannelsKey : NSNumber(value: 2),//采集音轨
//                 AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue))]//音频质量
    
    return [recSetting copy];
}
// 录音文件的名称使用时间戳+caf后缀
- (NSString *)newRecorderName {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddhhmmss";
    return [[formatter stringFromDate:[NSDate date]] stringByAppendingPathExtension:@"caf"];
}
// Document目录
- (NSString *)filePathWithName:(NSString *)fileName {
    NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [urlStr stringByAppendingPathComponent:fileName];
}
    
//键盘回收
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
    if(first.isHidden==NO)
        first.hidden = YES;

    
//
//    // [attachStackView resignFirstResponder];
//    NSLog(@"subview length:%@",[voice.subviews count]);
//    NSLog(@"x:%f",voice.frame.origin.x);
//    NSLog(@"y:%f",voice.frame.origin.y);
//
//    NSLog(@"size w:%f",voice.frame.size.width);
//    NSLog(@"size h:%f",voice.frame.size.height);
//
//
//    UIView * currentTouchView = touches.allObjects[0].view;
//
//    //voice
//    CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
//
//    if (CGRectContainsPoint(attachStackView.frame, touchPoint)) {
//        self.currentRecordState = BBVoiceRecordState_Recording;
//        [self dispatchVoiceState];
//    }
//
//    //[self.nextResponder touchesBegan:touches withEvent:event];
//
//    for(UIView *view in self.view.subviews)
//    {
//        [view resignFirstResponder];
//    }
//    [self configRecorder1];
//    [_recorder record];
}

//移动UIView
-(void)transformView:(NSNotification *)aNSNotification
{
    //获取键盘弹出前的Rect
    NSValue *keyBoardBeginBounds=[[aNSNotification userInfo]objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect beginRect=[keyBoardBeginBounds CGRectValue];
    
    //获取键盘弹出后的Rect
    NSValue *keyBoardEndBounds=[[aNSNotification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect  endRect=[keyBoardEndBounds CGRectValue];
    
    //获取键盘位置变化前后纵坐标Y的变化值
    CGFloat deltaY=endRect.origin.y-beginRect.origin.y;
    NSLog(@"看看这个变化的Y值:%f",deltaY);
    
    //在0.25s内完成self.view的Frame的变化，等于是给self.view添加一个向上移动deltaY的动画
//    [UIView animateWithDuration:0.25f animations:^{
//        [attachStackView setFrame:CGRectMake(attachStackView.frame.origin.x, attachStackView.frame.origin.y+deltaY, attachStackView.frame.size.width, attachStackView.frame.size.height)];
//    }];
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+deltaY, self.view.frame.size.width, self.view.frame.size.height)];
    }];
    
}

-(void)takeAudioDetected
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&setCategoryError];
    if(setCategoryError){
        NSLog(@"%@", [setCategoryError description]);
//        if (_faildBlock) {
//            _faildBlock([setCategoryError description]);
//        }
    }
    
    
    //录音设置
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/byingRecord.aac", strUrl]];
    NSLog(@"*********url:%@",url);
    urlPlay = url;
    
    
    //创建录音文件，准备录音
    if ([recorder prepareToRecord]) {
        //开始
        [recorder record];
    }
    
    //设置定时检测
    //    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
    
//    NSError *error;
//    //初始化
//    recorder = [[AVAudioRecorder alloc]initWithURL:url settings:recordSetting error:&error];
//    //开启音量检测
//    recorder.meteringEnabled = YES;
//    recorder.delegate = self;
//
//    //创建录音文件，准备录音
//    if ([recorder prepareToRecord]) {
//        //开始
//        [recorder record];
//    }
    
   

    
    //设置定时检测
    //    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];

}

//录制视频
- (void)takeVideoDetected
{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypeCamera;//sourcetype有三种分别是camera，photoLibrary和photoAlbum
    NSArray *availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];//Camera所支持的Media格式都有哪些,共有两个分别是@"public.image",@"public.movie"
    ipc.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];//设置媒体类型为public.movie
    [self presentViewController:ipc animated:YES completion:nil];
    ipc.videoMaximumDuration = 30.0f;//30秒
    ipc.delegate = self;//设置委托
}

- (void)uitextviewDetected
{
    NSLog(@"single tap on uitextview");
}

-(void)takePhotoDetected{
     NSLog(@"single Tap on takePhoto1");
    [self takePhoto];
}
-(void)takePhotoDetected2{
    NSLog(@"single Tap on takePhoto222222222222");
    [self takePhoto2];
}
-(void)tapDetected{
    NSLog(@"single Tap on imageview");
    
    [self goAlbum];
    
}
-(void)tapAvatar{
    first.hidden=NO;
//    if(first.isHidden==YES)
//        first.hidden = NO;
//    else
//        first.hidden = YES;
    
}
-(void)tapLabel{
    first.hidden=NO;
    //    if(first.isHidden==YES)
    //        first.hidden = NO;
    //    else
    //        first.hidden = YES;
    
}
-(void)tapDetected2{
    NSLog(@"single Tap on imageview");
    
    [self goAlbum2];
    
}
-(void)avatarTapAction:(UITapGestureRecognizer *)tap
{
    NSInteger * tag = tap.view.tag;
    NSString *inStr = [NSString stringWithFormat: @"%ld", (long)tag];
    NSString *p = [paths objectForKey:inStr];
    NSLog(@"videoPath=%@",p);
    
    NSString *extension = [p pathExtension];
    if ([extension isEqualToString:@"MOV"]) {
       //[playerVc play];
       /*
        
        NSURL *URL = [[NSURL alloc] initWithString:p];
        //NSURL *URL = [[NSURL alloc] initFileURLWithPath:p];
        playerVc = [[MPMoviePlayerViewController alloc] initWithContentURL:URL];
        [self presentMoviePlayerViewControllerAnimated:playerVc];
        //playerVc.movieSourceType=MPMovieSourceTypeFile;
        
        [playerVc play];
        */
        
        
//        NSURL *videoUrl = [NSURL fileURLWithPath:p];
//        playerVc = [[MPMoviePlayerController alloc]initWithContentURL:videoUrl];
//        playerVc.view.frame =CGRectMake(0,0, 320,320 * (9.0 /16.0));
//        playerVc.scalingMode =MPMovieScalingModeAspectFill;
//        playerVc.controlStyle =MPMovieControlStyleDefault;
//        [self.view addSubview:playerVc.view];
//        [playerVc play];
    } else {
       [SJAvatarBrowser showImage:(UIImageView *)tap.view];
    }
}

- (void)BtnClick:(UIButton *)btn
{
    
    //can send
//    if([curStr length]>0||attach.allKeys.count>0){
//        [sendBt setBackgroundImage:[UIImage imageNamed:@"sendbgtxt"] forState:UIControlStateNormal];
//    }
//    else{
//        [sendBt setBackgroundImage:[UIImage imageNamed:@"sendbtbg"] forState:UIControlStateNormal];
//    }
    
    
   
    
    //UIImage * t =sendBt.currentBackgroundImage;
    NSString * curStr = [textField text];
    if([curStr length]>0||attach.allKeys.count>0){
        //can send
    }else{
        [self canNotSend];
        return;
    }
   
    //要判断如果有视频
   // [NSThread sleepForTimeInterval:2.0];
    //服务端判断
    
    
    NSString * text = [textField text];
    text = [NSString stringWithCString:[text UTF8String] encoding:NSUTF8StringEncoding];

    NSLog(@"%@", text);
    NSLog(@"%@", [text emojiEncode]);
    NSString *userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 16_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.2 Mobile/15E148 Safari/604.1 veivo22 veivowk v202";
    //1 需要请求的URL
    
    NSString *ccc = ((AppDelegate*)([UIApplication sharedApplication].delegate)).veivoCookie;
    NSLog(@"cookie=%@",ccc);
    NSString *urlString = nil;
    NSString *server=nil;
    
    if([ccc containsString:@"en.veivo.com"])
    {
        urlString = [NSString stringWithFormat:@"https://en.veivo.com/info"];
        server = [NSString stringWithFormat:@"https://en.veivo.com/"];
    }
    else
    {
         urlString = [NSString stringWithFormat:@"https://www.veivo.com/info"];
        server = [NSString stringWithFormat:@"https://www.veivo.com/"];
    }

    
    //1.创建NSURLSession对象（可以获取单例对象）
    NSURLSession *session = [NSURLSession sharedSession];
    
    //2.根据NSURLSession对象创建一个Task
    
   
    
    //创建一个请求对象，并这是请求方法为POST，把参数放在请求体中传递
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    //[request setURL:[NSURL URLWithString:urlString]];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *contentType = [NSString stringWithFormat:@"text/plain"];
    
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *postBody = [NSMutableData data];
    
    
    [request setValue:((AppDelegate*)([UIApplication sharedApplication].delegate)).veivoCookie forHTTPHeaderField:@"Cookie"];
    //
    //NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    [request setHTTPBody:postBody];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    //请求头
    

    request.HTTPMethod = @"POST";
    
    
    //compose json attach
    /*
    {"d":"https://en.veivo.com/v1/veivo/1560671918492388/v2_f089da942o5ew1azQ74o3Z1SmuwA8J7yXwYp6Gk9xx0KDA1ztDUdew2hddDWYGJu7M_UXeoh4nPpcSErfEjastBkNmr1iqtScN6gl_kHs_H2T85m2y1krOdC1lM-","n":"u=1330142631,201311495&fm=26&gp=0.jpg","p":"https://www.veivo.com/userimages/photoPreview/1dea/9b8a/7ecb/7053/8796/7212/5af8/98f6/preview.jpg","t":"image/jpeg","s":25965,"h":"1dea9b8a7ecb7053879672125af898f6","x":"320","y":180.11257035647282}]"
    */
    
    NSMutableArray *myArray = [[NSMutableArray alloc] init];
    
    NSString * jsonStr = @"[";
    
   
    
    for (int i = 0; i < attach.allValues.count; i ++) {
        NSMutableDictionary * a = [[NSMutableDictionary alloc] init];
        
        NSString * md5 = [attach.allKeys objectAtIndex:i];
        NSString * fid = [attach objectForKey:md5][0];
        NSString * fileType = [attach objectForKey:md5][1];
        NSString * fileName = [attach objectForKey:md5][2];
//        NSString * contentMd5 = [attach objectForKey:md5][3];
//        NSString * imgMd5 = [attach objectForKey:md5][4];
//        NSLog(@"746");
        NSString *d = [[[[server stringByAppendingString:@"v1/veivo/"] stringByAppendingString:activeUser] stringByAppendingString:@"/"] stringByAppendingString:fid];
        NSLog(@"d:%@",d);
        NSLog(@"#####fid=%@",fid);
        
        
        //for (int i = 4; i <= 32; i += 4) {
          //  hashBuffer.append(hash.substring(i - 4, i)).append("/");
        //}
        
        /*
        NSString * dir = [NSString alloc];
        for( int i = 4; i <=32 ; i +=4 ){
            NSRange r = NSMakeRange(i-4,4);
            NSString *e = [md5 substringWithRange:r];
            NSLog(@"each:%@",e);
            //dir = [[dir stringByAppendingString:e] stringByAppendingString:@"/"];
        }
        NSLog(@"#####dir:%@",dir);
        */
        
        
        [a setObject:fid forKey:@"d"];
        [a setObject:fileName forKey:@"n"];
        [a setObject:@"https://www.veivo.com/userimages/photoPreview/1dea/9b8a/7ecb/7053/8796/7212/5af8/98f6/preview.jpg" forKey:@"p"];
        [a setObject:fileType forKey:@"t"];
        [a setObject:@"1000" forKey:@"s"];
        [a setObject:@"320" forKey:@"x"];
        [a setObject:@"180" forKey:@"y"];
        [a setObject:md5 forKey:@"h"];
        
        
        NSString *j = [self UIUtilsFomateJsonWithDictionary:a];
        NSLog(@"json:%@",j);
        jsonStr = [[jsonStr stringByAppendingString:j] stringByAppendingString:@","];
        //[myArray addObject:j];
    }
    
    
    
    
    NSString *truncatedString = [jsonStr substringToIndex:[jsonStr length]-1];
    truncatedString = [truncatedString stringByAppendingString:@"]"];
    
    if(attach.allValues.count==0)
        truncatedString = @"[]";
    
    NSString * error = nil;
   NSLog(@"jsonData as string:\n%@", truncatedString);
    
    NSLog(@"price=%@",price.text);
    
    //NSString * curStr = [textView text];
    
    NSLog(@"%@",curStr);
    
//    NSString *d = [NSString stringWithFormat:@"atx=tweet&message=%@&price=%@&attach=%@",text,price.text,truncatedString];
//    NSLog(@"%@",d);
    
//    NSString *dd = [[NSString stringWithFormat:@"atx=tweet&message=%@&price=%@&attach=%@",text,price.text,truncatedString] dataUsingEncoding:NSUTF8StringEncoding];
    
    if(appid==nil)
        appid = ((AppDelegate*)([UIApplication sharedApplication].delegate)).appid;
    
    NSString *dd = [NSString stringWithFormat:@"atx=tweet&ios=3&price=%@&attach=%@&appid=%@&message=%@",price.text,truncatedString,appid, [text emojiEncode]];
    
    //dd = [self URLEncodedString:dd];
    
    NSLog(@"POST STRING:%@",dd);
    
    //NSLog(@"escape:%@",[self encodeWithEscape:dd]);
    
    
//    NSString *ddd = [dd stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
//    NSLog(@"POST STRING:%@",ddd);
    
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingMacChineseSimp);
    NSData *postData = [dd dataUsingEncoding: enc allowLossyConversion: YES];
   
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    [request setValue: postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue: @"application/x-www-form-urlencoded;charset=gbk" forHTTPHeaderField:@"Content-Type"];

    
    [postBody appendData:postData];
    
    
    NSLog(@"请求data的大小：%lu",(unsigned long)[postData length]);
    
//    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error) {
//        //拿到响应头信息
//        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
//
//        //解析拿到的响应数据
//        NSLog(@"%@\n%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding],res.allHeaderFields);
//
//
//        canBack = YES;
//
//    }];
//
//    //3.执行Task
//    //注意：刚创建出来的task默认是挂起状态的，需要调用该方法来启动任务（执行任务）
//    [dataTask resume];
    
    
    
    //长文本无法发送，试用AFNetwork来Post
    NSMutableDictionary *parameters=[NSMutableDictionary dictionary];
    
    [parameters setObject:@"tweet" forKey:@"atx"];
    [parameters setObject:@"3" forKey:@"ios"];
    [parameters setObject:price.text forKey:@"price"];
    [parameters setObject:truncatedString forKey:@"attach"];
    [parameters setObject:appid forKey:@"appid"];
    [parameters setObject:[text emojiEncode] forKey:@"message"];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager.requestSerializer setValue:((AppDelegate*)([UIApplication sharedApplication].delegate)).veivoCookie forHTTPHeaderField:@"Cookie"];
    
     [manager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];

    
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //success
        self->canBack = YES;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //fail
        NSLog(@"发送失败！");
    }];
    
    //end
    
    
    [self presentSheetSending];
    
      [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector: @selector(performBack:)  userInfo:nil repeats:YES];
    
}
- (void)textViewDidChange:(UITextView *)textView
{
    
    NSLog(@"textview changed...");
    
    //保存
    ((AppDelegate*)([UIApplication sharedApplication].delegate)).veivoDraft = [textView text];
    
    NSString * curStr = [textView text];
    
    NSLog(@"%@",curStr);
    
    if([curStr length]>0||attach.allKeys.count>0){
        [sendBt setBackgroundImage:[UIImage imageNamed:@"sendbgtxt"] forState:UIControlStateNormal];
    }
    else{
        [sendBt setBackgroundImage:[UIImage imageNamed:@"sendbtbg"] forState:UIControlStateNormal];
    }
    
    
    NSHTTPCookieStorage *cookieStorage  = ((AppDelegate*)([UIApplication sharedApplication].delegate)).cs;
    
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        NSString *excuteJSString = [NSString stringWithFormat:@"setCookie('%@', '%@', 1);", cookie.name, cookie.value];
        NSLog(@"%@", excuteJSString);
    }
    
}

- (void) performBack: (NSTimer *)timer {
    //check can back
    
    
    
    
    //[NSThread sleepForTimeInterval:2.0];
    
    
    
    if(canBack == YES){
        [baseAlert dismissWithClickedButtonIndex:0 animated:NO];//important
        
        //[baseAlert release];
        
        baseAlert = NULL;
        
        NSLog(@"###############dismissing sending...");
       
        NSLog(@"***back");
        [self.navigationController popViewControllerAnimated:YES];
        
        
        ((AppDelegate*)([UIApplication sharedApplication].delegate)).veivoDraft = @"";
        
        [timer invalidate];
        timer = nil;
    }
 
}

- (void) performDismiss: (NSTimer *)timer {
    
    [baseAlert dismissWithClickedButtonIndex:0 animated:NO];//important
    
    //[baseAlert release];
    
    baseAlert = NULL;
    NSLog(@"***performDismiss...");
  //  [self.navigationController popViewControllerAnimated:YES];
}
- (void) performDismissSending: (NSTimer *)timer {
    
}
- (void) presentSheetSending {
    
    baseAlert = [[UIAlertView alloc]  initWithTitle:@"Alert" message:sending  delegate:self cancelButtonTitle:nil                               otherButtonTitles: nil];
    
    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector: @selector(performDismissSending:)  userInfo:nil repeats:NO];
    
    [baseAlert show];
    
}
- (void) presentSheet {
    
    baseAlert = [[UIAlertView alloc]  initWithTitle:@"Alert" message:sent  delegate:self cancelButtonTitle:nil                               otherButtonTitles: nil];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector: @selector(performDismiss:)  userInfo:nil repeats:NO];
    
    [baseAlert show];
    
}
//- (void) changeSheet {
//
//    NSLog(@"**********change sheet...");
//
//    [baseAlert setMessage:sent];
//
////    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector: @selector(performDismiss:)  userInfo:nil repeats:NO];
////
////    [baseAlert show];
//
//
//
//}
- (void) canNotSend {
    
    baseAlert = [[UIAlertView alloc]  initWithTitle:@"Alert" message:@"\n Can not send empty tweet... "  delegate:self cancelButtonTitle:nil                               otherButtonTitles: nil];
    
    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector: @selector(performDismiss:)  userInfo:nil repeats:NO];
    
    [baseAlert show];
    
}
//开始拍照
-(void)takePhoto
{
    NSLog(@"single Tap on takePhoto2");

    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: sourceType]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = sourceType;
        picker.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
        picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        [self presentViewController:picker animated:YES completion:^{
            
        }];
    }
}
//开始拍照
-(void)takePhoto2
{
    NSLog(@"single Tap on takePhoto2**********2222222222222");
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: sourceType]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = sourceType;
        picker.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
        picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        [self presentViewController:picker animated:YES completion:^{
            
        }];
    }
}
//相册选择
- (void)goAlbum {
//    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary]) {
//        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//        picker.delegate = self;
//        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//        picker.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
//        picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
//        [self presentViewController:picker animated:YES completion:^{
//
//        }];
//    }
    
    
      [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        
                if (status !=PHAuthorizationStatusAuthorized)return;
        
                dispatch_async(dispatch_get_main_queue(), ^{
            
                        CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            
                        picker.delegate =self;
            
                        // 显示选择的索引
            
                        picker.showsSelectionIndex =YES;
            
                        // 设置相册的类型：相机胶卷 +自定义相册
            
                        picker.assetCollectionSubtypes =@[
                                                          
                                                                                                         @(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                                                                                                         
                                                                                                                                                        @(PHAssetCollectionSubtypeAlbumRegular)];
            
                        // 不需要显示空的相册
            
                        picker.showsEmptyAlbums =NO;
            
                       // [self presentViewController:picker animated:YEScompletion:nil];
                    [self presentViewController:picker animated:YES completion:^{
            
                    }];
                    });
        
            }];
    
}
//相册选择2
- (void)goAlbum2 {
    //    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary]) {
    //        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    //        picker.delegate = self;
    //        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //        picker.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    //        picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    //        [self presentViewController:picker animated:YES completion:^{
    //
    //        }];
    //    }
    
    
      [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        
                if (status !=PHAuthorizationStatusAuthorized)return;
        
                dispatch_async(dispatch_get_main_queue(), ^{
            
                        CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            
                        picker.delegate =self;
            
                        // 显示选择的索引
            
                        picker.showsSelectionIndex =YES;
            
                        // 设置相册的类型：相机胶卷 +自定义相册
            
                        picker.assetCollectionSubtypes =@[
                                                          
                                                                                                         @(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                                                                                                         
                                                                                                                                                        @(PHAssetCollectionSubtypeAlbumRegular)];
            
                        // 不需要显示空的相册
            
                        picker.showsEmptyAlbums =NO;
            
                       // [self presentViewController:picker animated:YEScompletion:nil];
            [self presentViewController:picker animated:YES completion:^{
                
            }];
                    });
        
            }];
    
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
-(IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


//utility
- (CGFloat) getFileSize:(NSString *)path
{
    NSLog(@"%@",path);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    float filesize = -1.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];//获取文件的属性
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0*size/1024;
    }else{
        NSLog(@"找不到文件");
    }
    return filesize;
}//此方法可以获取文件的大小，返回的是单位是KB。
- (CGFloat) getVideoLength:(NSURL *)URL
{
    AVURLAsset *avUrl = [AVURLAsset assetWithURL:URL];
    CMTime time = [avUrl duration];
    int second = ceil(time.value/time.timescale);
    return second;
}//此方法可以获取视频文件的时长。

- (void) convertVideoQuailtyWithInputURL:(NSURL*)inputURL
                               outputURL:(NSURL*)outputURL
                         completeHandler:(void (^)(AVAssetExportSession*))handler
{
    //presetName 几种格式
    //AVAssetExportPresetLowQuality,
    //AVAssetExportPreset960x540,
    //AVAssetExportPreset640x480,
    //AVAssetExportPresetMediumQuality,
    //AVAssetExportPreset1920x1080,
    //AVAssetExportPreset1280x720,
    //AVAssetExportPresetHighestQuality,
    //AVAssetExportPresetAppleM4A
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
    // NSLog(resultPath);
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4; //转换的格式
    exportSession.shouldOptimizeForNetworkUse= YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         switch (exportSession.status) {
             case AVAssetExportSessionStatusCompleted:
                 NSLog(@"AVAssetExportSessionStatusCompleted");
                 NSLog(@"%@",[NSString stringWithFormat:@"%f s", [self getVideoLength:outputURL]]);
                 NSLog(@"%@", [NSString stringWithFormat:@"%.2f kb", [self getFileSize:[outputURL path]]]);
                 //UISaveVideoAtPathToSavedPhotosAlbum([outputURL path], self, nil, NULL);//这个是保存到手机相册
                 NSLog(@"这地方写你的上传视频或者再次判断视频的大小等等");
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"AVAssetExportSessionStatusFailed");
                 break;
         }
     }];
}




//image
#pragma mark - UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    // 设置代理
    ipc.delegate = self;
    
    switch (buttonIndex) {
        case 0: { // 拍照
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) return;
            ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        }
        case 1: { // 相册
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
            ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        }
        default:
            break;
    }
    
    // 显示控制器
    [self presentViewController:ipc animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
//- (UIView *)coverView {
//    if (!_coverView) {
//        UIView *view = [[UIView alloc] init];
//        view.backgroundColor = [UIColor clearColor];
//        view.hidden = YES;
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverClick)];
//        [view addGestureRecognizer:tap];
//        [self addSubview:view];
//        _coverView = view;
//    }
//    return _coverView;
//}
//- (void)coverClick {
//    self.shaking = NO;
//    NSLog(@"click delete");
//}
- (void)putPath:(NSString *)path videoPath:(NSString *)videoPath withKey:(NSString *)k {
    if(videoPath!=nil){
        //视频声音
        NSData * fileData = [NSData dataWithContentsOfFile:path];
        NSString * md5 = [self MD5:fileData];
        NSArray *pp = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [pp objectAtIndex:0];
        NSString *videoFile = [documentsDirectory stringByAppendingPathComponent:[md5 stringByAppendingString:@".MOV"]];
        NSLog(@"videoFile1=%@",videoFile);
        [paths setObject:videoFile forKey:k];
    }
}

/**
 *  在选择完图片后调用
 *
 *  @param info   里面包含了图片信息
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 销毁控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // 获得图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    // 显示图片
    //imageView.image = image;
//    UIImageView *v = [[UIImageView alloc] init];
//
//    //[v height];
//
//    [preStackView addArrangedSubview:v];
    
    NSString *path = [info objectForKey:@"UIImagePickerControllerImageURL"];
    NSString *videoPath = nil;
    
    if(path==nil&&![[info objectForKey:@"UIImagePickerControllerMediaType"] isEqualToString:@"public.image"]){
        path = [info objectForKey:@"UIImagePickerControllerMediaURL"];
        
        NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        NSString *moviePath = [videoUrl path];
        //这里利用MPMoviePlayerController来获取
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:videoUrl] ;
        UIImage  *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        
        //test
       // playerVc = [[MPMoviePlayerController alloc]initWithContentURL:videoUrl] ;
        //[playerVc play];
        
        //end test
        
        image = thumbnail;
        player = nil;//释放player
        
        videoPath = moviePath;
    }
    
    
    UIImageView* imageview=[[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 45, 45)];
    UIImageView* playview=[[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 45, 45)];

    if(pre1.image ==nil){
        pre1.image = image;
        //[SJAvatarBrowser showImage:pre1];
        pre1.userInteractionEnabled = YES;
        //添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTapAction:)];
        [pre1 addGestureRecognizer:tap];
        tap.view.tag=1;
        
        [self putPath:path videoPath:videoPath withKey:@"1"];
        
        
        
        //添加删除按钮
        UIImage *delimg = [UIImage imageNamed:@"closebt.png"];
        UIImageView *delimgview = [[UIImageView alloc] init];
        delimgview.frame = CGRectMake(65, -0, 22,22);
        //delimgview.backgroundColor = [UIColor yellowColor];
        delimgview.image = delimg;

        [pre1 addSubview:delimgview];
        
        UITapGestureRecognizer *delImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delImg:)];
        delImgTap.numberOfTapsRequired = 1;
        [delimgview setUserInteractionEnabled:YES];
        [delimgview addGestureRecognizer:delImgTap];
        
        
        //添加视频标志
        if(videoPath !=nil){
            UIImage *playimg = [UIImage imageNamed:@"play.png"];
            playview.image=playimg;
             [pre1 addSubview:playview];
        }
        
        //上传进度条
//        UIProgressView *progressView;
//        progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
//        progressView.progressTintColor = [UIColor colorWithRed:187.0/255 green:160.0/255 blue:209.0/255 alpha:1.0];
//        [[progressView layer]setFrame:CGRectMake(20, 20, 50, 50)];
//        [[progressView layer]setBorderColor:[UIColor redColor].CGColor];
//        progressView.trackTintColor = [UIColor clearColor];
//        [progressView setProgress:(float)(50/100) animated:YES];  ///15
//
//        [[progressView layer]setCornerRadius:progressView.frame.size.width / 2];
//        [[progressView layer]setBorderWidth:3];
//        [[progressView layer]setMasksToBounds:TRUE];
//        progressView.clipsToBounds = YES;
        
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"progress" withExtension:@"gif"];
        //加载GIF图片
        CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);
        //将GIF图片转换成对应的图片源
        size_t frameCout=CGImageSourceGetCount(gifSource);
        //获取其中图片源个数，即由多少帧图片组成
        NSMutableArray* frames=[[NSMutableArray alloc] init];
        //定义数组存储拆分出来的图片
        for (size_t i=0; i<frameCout;i++){
            CGImageRef imageRef=CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
            //从GIF图片中取出源图片
            UIImage* imageName=[UIImage imageWithCGImage:imageRef];
            //将图片源转换成UIimageView能使用的图片源
            [frames addObject:imageName];//将图片加入数组中
            CGImageRelease(imageRef);
            
        }
             imageview.animationImages=frames;
             //将图片数组加入UIImageView动画数组中
             imageview.animationDuration=3;
             //每次动画时长
             [imageview startAnimating];
             //开启动画，此处没有调用播放次数接口，UIImageView默认播放次数为无限次，故这里不做处理
        [pre1 addSubview:imageview];
        
       
    }else if(pre2.image ==nil){
        pre2.image = image;
        //[SJAvatarBrowser showImage:pre2];
        pre2.userInteractionEnabled = YES;
        //添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTapAction:)];
        [pre2 addGestureRecognizer:tap];
        //[tap setValue:videoPath forKey:@"videoPath"];
        tap.view.tag=2;
        [self putPath:path videoPath:videoPath withKey:@"2"];
        
        //添加删除按钮
        UIImage *delimg = [UIImage imageNamed:@"closebt.png"];
        UIImageView *delimgview = [[UIImageView alloc] init];
        delimgview.image = delimg;
        delimgview.frame = CGRectMake(65, -0, 22,22);
        
        [pre2 addSubview:delimgview];
        
        UITapGestureRecognizer *delImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delImg:)];
        delImgTap.numberOfTapsRequired = 1;
        [delimgview setUserInteractionEnabled:YES];
        [delimgview addGestureRecognizer:delImgTap];
        
        //添加视频标志
        if(videoPath !=nil){
            UIImage *playimg = [UIImage imageNamed:@"play.png"];
            playview.image=playimg;
            [pre2 addSubview:playview];
        }
        
        
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"progress" withExtension:@"gif"];
        //加载GIF图片
        CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);
        //将GIF图片转换成对应的图片源
        size_t frameCout=CGImageSourceGetCount(gifSource);
        //获取其中图片源个数，即由多少帧图片组成
        NSMutableArray* frames=[[NSMutableArray alloc] init];
        //定义数组存储拆分出来的图片
        for (size_t i=0; i<frameCout;i++){
            CGImageRef imageRef=CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
            //从GIF图片中取出源图片
            UIImage* imageName=[UIImage imageWithCGImage:imageRef];
            //将图片源转换成UIimageView能使用的图片源
            [frames addObject:imageName];//将图片加入数组中
            CGImageRelease(imageRef);
            
        }

        imageview.animationImages=frames;
        //将图片数组加入UIImageView动画数组中
        imageview.animationDuration=3;
        //每次动画时长
        [imageview startAnimating];
        //开启动画，此处没有调用播放次数接口，UIImageView默认播放次数为无限次，故这里不做处理
        [pre2 addSubview:imageview];
    }else if(pre3.image ==nil){
        pre3.image = image;
        //[SJAvatarBrowser showImage:pre3];
        pre3.userInteractionEnabled = YES;
        //添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTapAction:)];
        [pre3 addGestureRecognizer:tap];
        //[tap setValue:videoPath forKey:@"videoPath"];
        tap.view.tag=3;
        [self putPath:path videoPath:videoPath withKey:@"3"];
        
        //添加删除按钮
        UIImage *delimg = [UIImage imageNamed:@"closebt.png"];
        UIImageView *delimgview = [[UIImageView alloc] init];
        delimgview.image = delimg;
        delimgview.frame = CGRectMake(65, -0, 22,22);
        
        [pre3 addSubview:delimgview];
        
        UITapGestureRecognizer *delImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delImg:)];
        delImgTap.numberOfTapsRequired = 1;
        [delimgview setUserInteractionEnabled:YES];
        [delimgview addGestureRecognizer:delImgTap];
        
        
        //添加视频标志
        if(videoPath !=nil){
            UIImage *playimg = [UIImage imageNamed:@"play.png"];
            playview.image=playimg;
            [pre3 addSubview:playview];
        }
        
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"progress" withExtension:@"gif"];
        //加载GIF图片
        CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);
        //将GIF图片转换成对应的图片源
        size_t frameCout=CGImageSourceGetCount(gifSource);
        //获取其中图片源个数，即由多少帧图片组成
        NSMutableArray* frames=[[NSMutableArray alloc] init];
        //定义数组存储拆分出来的图片
        for (size_t i=0; i<frameCout;i++){
            CGImageRef imageRef=CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
            //从GIF图片中取出源图片
            UIImage* imageName=[UIImage imageWithCGImage:imageRef];
            //将图片源转换成UIimageView能使用的图片源
            [frames addObject:imageName];//将图片加入数组中
            CGImageRelease(imageRef);
            
        }

        imageview.animationImages=frames;
        //将图片数组加入UIImageView动画数组中
        imageview.animationDuration=3;
        //每次动画时长
        [imageview startAnimating];
        //开启动画，此处没有调用播放次数接口，UIImageView默认播放次数为无限次，故这里不做处理
        [pre3 addSubview:imageview];
    }else if(pre4.image ==nil){
        pre4.image = image;
        //[SJAvatarBrowser showImage:pre4];
        pre4.userInteractionEnabled = YES;
        //添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTapAction:)];
        [pre4 addGestureRecognizer:tap];
        //[tap setValue:videoPath forKey:@"videoPath"];
        tap.view.tag=4;
        [self putPath:path videoPath:videoPath withKey:@"4"];
        
        //添加删除按钮
        UIImage *delimg = [UIImage imageNamed:@"closebt.png"];
        UIImageView *delimgview = [[UIImageView alloc] init];
        delimgview.image = delimg;
        delimgview.frame = CGRectMake(65, -0, 22,22);
        
        [pre4 addSubview:delimgview];
        
        UITapGestureRecognizer *delImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delImg:)];
        delImgTap.numberOfTapsRequired = 1;
        [delimgview setUserInteractionEnabled:YES];
        [delimgview addGestureRecognizer:delImgTap];
        
        //添加视频标志
        if(videoPath !=nil){
            UIImage *playimg = [UIImage imageNamed:@"play.png"];
            playview.image=playimg;
            [pre4 addSubview:playview];
        }
        
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"progress" withExtension:@"gif"];
        //加载GIF图片
        CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);
        //将GIF图片转换成对应的图片源
        size_t frameCout=CGImageSourceGetCount(gifSource);
        //获取其中图片源个数，即由多少帧图片组成
        NSMutableArray* frames=[[NSMutableArray alloc] init];
        //定义数组存储拆分出来的图片
        for (size_t i=0; i<frameCout;i++){
            CGImageRef imageRef=CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
            //从GIF图片中取出源图片
            UIImage* imageName=[UIImage imageWithCGImage:imageRef];
            //将图片源转换成UIimageView能使用的图片源
            [frames addObject:imageName];//将图片加入数组中
            CGImageRelease(imageRef);
            
        }

        imageview.animationImages=frames;
        //将图片数组加入UIImageView动画数组中
        imageview.animationDuration=3;
        //每次动画时长
        [imageview startAnimating];
        //开启动画，此处没有调用播放次数接口，UIImageView默认播放次数为无限次，故这里不做处理
        [pre4 addSubview:imageview];
    }else{
        NSString *alertTitle = @"";
        NSString *alertMsg = @"最多只能发4个附件";
        NSString *alertOk = @"确认";
        NSString *alertCancel = @"取消";
        
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg
                                                      delegate:self
                                             cancelButtonTitle:alertCancel otherButtonTitles:alertOk, nil];
        [alert show];
    }



   
    
    [self upload:path withProgress:imageview withImage:image withMedia:info withMediaType:nil withGifNsData:nil];
    
    //NSString *md5 = [self md5HashOfPath:path];
    //put into dict
    //[attach setObject:<#(nonnull id)#> forKey:md5];
    
}

- (void) convertMp3Finish:(NSObject*) withObject withPath:(NSString*)path{
    NSLog(@"convert mp3 finish");
    
    UIImage *image = [UIImage imageNamed:@"audiogreypng.png"];

    
    UIImageView* imageview=[[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 45, 45)];
    UIImageView* voiceview=[[UIImageView alloc] initWithFrame:CGRectMake(2.5, 2.5, 85, 85)];
    
    if(pre1.image ==nil){
        pre1.image = image;
        //[SJAvatarBrowser showImage:pre1];
        pre1.userInteractionEnabled = YES;
        //添加手势
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTapAction:)];
//        [pre1 addGestureRecognizer:tap];
//        tap.view.tag=1;
        
       // [self putPath:path videoPath:videoPath withKey:@"1"];
        
        
        
        //添加删除按钮
        UIImage *delimg = [UIImage imageNamed:@"closebt.png"];
        UIImageView *delimgview = [[UIImageView alloc] init];
        delimgview.alpha = 1;
        delimgview.image = delimg;
        delimgview.frame = CGRectMake(65, -0, 22,22);
        
        [pre1 addSubview:delimgview];
        
        UITapGestureRecognizer *delImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delImg:)];
        delImgTap.numberOfTapsRequired = 1;
        [delimgview setUserInteractionEnabled:YES];
        [delimgview addGestureRecognizer:delImgTap];
        
        
        //添加语音标志
       
//            UIImage *playimg = [UIImage imageNamed:@"audiogreypng.png"];
//            voiceview.image=playimg;
//            [pre1 addSubview:voiceview];
        
        
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"progress" withExtension:@"gif"];
        //加载GIF图片
        CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);
        //将GIF图片转换成对应的图片源
        size_t frameCout=CGImageSourceGetCount(gifSource);
        //获取其中图片源个数，即由多少帧图片组成
        NSMutableArray* frames=[[NSMutableArray alloc] init];
        //定义数组存储拆分出来的图片
        for (size_t i=0; i<frameCout;i++){
            CGImageRef imageRef=CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
            //从GIF图片中取出源图片
            UIImage* imageName=[UIImage imageWithCGImage:imageRef];
            //将图片源转换成UIimageView能使用的图片源
            [frames addObject:imageName];//将图片加入数组中
            CGImageRelease(imageRef);
            
        }
        imageview.animationImages=frames;
        //将图片数组加入UIImageView动画数组中
        imageview.animationDuration=3;
        //每次动画时长
        [imageview startAnimating];
        //开启动画，此处没有调用播放次数接口，UIImageView默认播放次数为无限次，故这里不做处理
        [pre1 addSubview:imageview];
        
        
    }else if(pre2.image ==nil){
        pre2.image = image;
        //[SJAvatarBrowser showImage:pre2];
        pre2.userInteractionEnabled = YES;
        //添加手势
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTapAction:)];
//        [pre2 addGestureRecognizer:tap];
//        //[tap setValue:videoPath forKey:@"videoPath"];
//        tap.view.tag=2;
//        [self putPath:path videoPath:videoPath withKey:@"2"];
//
        //添加删除按钮
        UIImage *delimg = [UIImage imageNamed:@"closebt.png"];
        UIImageView *delimgview = [[UIImageView alloc] init];
        delimgview.alpha = 1;
        delimgview.image = delimg;
        delimgview.frame = CGRectMake(65, -0, 22,22);
        
        [pre2 addSubview:delimgview];
        
        UITapGestureRecognizer *delImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delImg:)];
        delImgTap.numberOfTapsRequired = 1;
        [delimgview setUserInteractionEnabled:YES];
        [delimgview addGestureRecognizer:delImgTap];
        
        //添加语音标志
       
//            UIImage *playimg = [UIImage imageNamed:@"audiogreypng.png"];
//            voiceview.image=playimg;
//            [pre2 addSubview:voiceview];
        
        
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"progress" withExtension:@"gif"];
        //加载GIF图片
        CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);
        //将GIF图片转换成对应的图片源
        size_t frameCout=CGImageSourceGetCount(gifSource);
        //获取其中图片源个数，即由多少帧图片组成
        NSMutableArray* frames=[[NSMutableArray alloc] init];
        //定义数组存储拆分出来的图片
        for (size_t i=0; i<frameCout;i++){
            CGImageRef imageRef=CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
            //从GIF图片中取出源图片
            UIImage* imageName=[UIImage imageWithCGImage:imageRef];
            //将图片源转换成UIimageView能使用的图片源
            [frames addObject:imageName];//将图片加入数组中
            CGImageRelease(imageRef);
            
        }
        
        imageview.animationImages=frames;
        //将图片数组加入UIImageView动画数组中
        imageview.animationDuration=3;
        //每次动画时长
        [imageview startAnimating];
        //开启动画，此处没有调用播放次数接口，UIImageView默认播放次数为无限次，故这里不做处理
        [pre2 addSubview:imageview];
    }else if(pre3.image ==nil){
        pre3.image = image;
        //[SJAvatarBrowser showImage:pre3];
        pre3.userInteractionEnabled = YES;
        //添加手势
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTapAction:)];
//        [pre3 addGestureRecognizer:tap];
//        //[tap setValue:videoPath forKey:@"videoPath"];
//        tap.view.tag=3;
//        [self putPath:path videoPath:videoPath withKey:@"3"];
        
        //添加删除按钮
        UIImage *delimg = [UIImage imageNamed:@"closebt.png"];
        UIImageView *delimgview = [[UIImageView alloc] init];
        delimgview.alpha = 1;
        delimgview.image = delimg;
        delimgview.frame = CGRectMake(65, -0, 22,22);
        
        [pre3 addSubview:delimgview];
        
        UITapGestureRecognizer *delImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delImg:)];
        delImgTap.numberOfTapsRequired = 1;
        [delimgview setUserInteractionEnabled:YES];
        [delimgview addGestureRecognizer:delImgTap];
        
        
        //添加语音标志
        
//            UIImage *playimg = [UIImage imageNamed:@"audiogreypng.png"];
//            voiceview.image=playimg;
//            [pre3 addSubview:voiceview];
//
        
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"progress" withExtension:@"gif"];
        //加载GIF图片
        CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);
        //将GIF图片转换成对应的图片源
        size_t frameCout=CGImageSourceGetCount(gifSource);
        //获取其中图片源个数，即由多少帧图片组成
        NSMutableArray* frames=[[NSMutableArray alloc] init];
        //定义数组存储拆分出来的图片
        for (size_t i=0; i<frameCout;i++){
            CGImageRef imageRef=CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
            //从GIF图片中取出源图片
            UIImage* imageName=[UIImage imageWithCGImage:imageRef];
            //将图片源转换成UIimageView能使用的图片源
            [frames addObject:imageName];//将图片加入数组中
            CGImageRelease(imageRef);
            
        }
        
        imageview.animationImages=frames;
        //将图片数组加入UIImageView动画数组中
        imageview.animationDuration=3;
        //每次动画时长
        [imageview startAnimating];
        //开启动画，此处没有调用播放次数接口，UIImageView默认播放次数为无限次，故这里不做处理
        [pre3 addSubview:imageview];
    }else if(pre4.image ==nil){
       pre4.image = image;
        //[SJAvatarBrowser showImage:pre4];
        pre4.userInteractionEnabled = YES;
        //添加手势
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTapAction:)];
//        [pre4 addGestureRecognizer:tap];
//        //[tap setValue:videoPath forKey:@"videoPath"];
//        tap.view.tag=4;
//        [self putPath:path videoPath:videoPath withKey:@"4"];
//
        //添加删除按钮
        UIImage *delimg = [UIImage imageNamed:@"closebt.png"];
        UIImageView *delimgview = [[UIImageView alloc] init];
        delimgview.alpha = 1;
        delimgview.image = delimg;
        delimgview.frame = CGRectMake(65, -0, 22,22);
        
        [pre4 addSubview:delimgview];
        
        UITapGestureRecognizer *delImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delImg:)];
        delImgTap.numberOfTapsRequired = 1;
        [delimgview setUserInteractionEnabled:YES];
        [delimgview addGestureRecognizer:delImgTap];
        
        //添加语音标志
        
//            UIImage *playimg = [UIImage imageNamed:@"audiogreypng.png"];
//            voiceview.image=playimg;
//            [pre4 addSubview:voiceview];
        
        
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"progress" withExtension:@"gif"];
        //加载GIF图片
        CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);
        //将GIF图片转换成对应的图片源
        size_t frameCout=CGImageSourceGetCount(gifSource);
        //获取其中图片源个数，即由多少帧图片组成
        NSMutableArray* frames=[[NSMutableArray alloc] init];
        //定义数组存储拆分出来的图片
        for (size_t i=0; i<frameCout;i++){
            CGImageRef imageRef=CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
            //从GIF图片中取出源图片
            UIImage* imageName=[UIImage imageWithCGImage:imageRef];
            //将图片源转换成UIimageView能使用的图片源
            [frames addObject:imageName];//将图片加入数组中
            CGImageRelease(imageRef);
            
        }
        
        imageview.animationImages=frames;
        //将图片数组加入UIImageView动画数组中
        imageview.animationDuration=3;
        //每次动画时长
        [imageview startAnimating];
        //开启动画，此处没有调用播放次数接口，UIImageView默认播放次数为无限次，故这里不做处理
        [pre4 addSubview:imageview];
    }else{
        NSString *alertTitle = @"";
        NSString *alertMsg = @"最多只能发4个附件";
        NSString *alertOk = @"确认";
        NSString *alertCancel = @"取消";
        
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg
                                                      delegate:self
                                             cancelButtonTitle:alertCancel otherButtonTitles:alertOk, nil];
        [alert show];
    }
    
    
    
    NSDictionary *info=[[NSDictionary alloc] initWithObjects:@[@"mp3"] forKeys:@[@"UIImagePickerControllerMediaType"]];
    

    
    [self upload:path withProgress:imageview withImage:image withMedia:info withMediaType:nil withGifNsData:nil];
}

- (void) delImg:(UITapGestureRecognizer *)tap
{
    NSLog(@"del img");
    UIImageView *tapView = (UIImageView *)tap.view;
    
    UIImageView *imgView = tapView.superview;
    
    //md5 of image
//    NSData *data = UIImagePNGRepresentation(imgView.image);
//    unsigned char digest[CC_MD5_DIGEST_LENGTH];
//    CC_MD5( data.bytes, (CC_LONG)data.length, digest );
//
//    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
//
//    for( int i = 0; i < CC_MD5_DIGEST_LENGTH; i++ )
//    {
//        [output appendFormat:@"%02x", digest[i]];
//    }
//    NSString *md5 = output;
    NSData *fileData = [self zipNSDataWithImage:imgView.image];
    //NSData *fileData = UIImagePNGRepresentation(imgView.image);
     NSString *md5 = [self MD5:fileData];
    //end md5 of image
    
    //[tapView removeFromSuperview];
   // UIImageView *view = tapView.superView;
    [imgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //[imgView removeFromSuperview];
    
    imgView.image = nil;
    
    //把剩下的Img依次移动
    
    UIStackView *stackView = (UIStackView *)imgView.superview;
    
    [self arrangeSubviewsImg:stackView];
    
    //[(UIStackView *)imgView.superview removeArrangedSubview:imgView];
    
    //删除attach
    NSLog(@"all keys:%@",attach.allKeys);
    NSLog(@"all values:%@",attach.allValues);
    [attach removeObjectForKey:md5];
    NSLog(@"all keys:%@",attach.allKeys);
    NSLog(@"all values:%@",attach.allValues);
    
    NSString * curStr = [textField text];
    if([curStr length]>0||attach.allKeys.count>0){
        [sendBt setBackgroundImage:[UIImage imageNamed:@"sendbgtxt"] forState:UIControlStateNormal];
    }
    else{
        [sendBt setBackgroundImage:[UIImage imageNamed:@"sendbtbg"] forState:UIControlStateNormal];
    }
    
}
- (void)arrangeSubviewsImg:(UIView *)view {
    
    // Get the subviews of the view
    NSArray *subviews = [view subviews];
    
    // Return if there are no subviews
    if ([subviews count] == 0) return; // COUNT CHECK LINE
    
    UIImageView *preImgView=nil;
    for (UIView *sub in subviews) {
        
        UIImageView *subview = sub;
        
        // Do what you want to do with the subview
        NSLog(@"%@", subview);
        
        
        if (preImgView==nil) {

        } else {
            if (preImgView.image==nil&&subview.image!=nil) {
                //move image to previous
                preImgView.image=subview.image;
                
                
                //if(subview.image.)
                
                subview.image=nil;
                
                
                //清除del button
                 NSArray *subviews_1 = [subview subviews];
                for (UIView *sub_1 in subviews_1) {
                    [sub_1 removeFromSuperview];
                    [preImgView addSubview:sub_1];
                }
                
                //添加删除按钮
                UIImage *delimg = [UIImage imageNamed:@"closebt.png"];
                UIImageView *delimgview = [[UIImageView alloc] init];
                delimgview.alpha = 1;
                delimgview.image = delimg;
                delimgview.frame = CGRectMake(65, -0, 22,22);
                
                [preImgView addSubview:delimgview];
                
                UITapGestureRecognizer *delImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delImg:)];
                delImgTap.numberOfTapsRequired = 1;
                [delimgview setUserInteractionEnabled:YES];
                [delimgview addGestureRecognizer:delImgTap];
                
                 //添加progress
                
                
                
            } else {
                
            }
        }
        
        preImgView = subview;

        // List the subviews of subview
        //[self listSubviewsOfView:subview];
    }
}

- (IBAction)upload :(NSString *)path withProgress:(UIImageView *)progressView withImage:(UIImage *)image withMedia:(NSDictionary *)media withMediaType:(PHAssetMediaType *) mediaType withGifNsData:(NSData *) gifNsData{
    
    NSString * fileType = [self sd_contentTypeForImageData:UIImageJPEGRepresentation(image,1.0f)];
    NSLog(@"文件类型：%@", fileType);
    
    double rawsize = [UIImageJPEGRepresentation(image,1.0f) length];
    
    NSString *raw_ssize = [[NSNumber numberWithDouble:rawsize] stringValue];
    
    NSLog(@"文件大小：%@",raw_ssize);
    
    NSData *fileData = [self zipNSDataWithImage:image];
    
   if(gifNsData !=nil )
       fileData = gifNsData;
    
    //NSData *fileData = UIImageJPEGRepresentation(image,0.1f);
    //NSData *fileData = UIImagePNGRepresentation(image);
    //checksum
    
    
    
    NSString *md5 = [self MD5:fileData];
    NSLog(@"md5=%@",md5);
    
//    NSString *imgMd5 = md5;
//
//    NSString *contentMd5 = md5;
    
    
    
    NSString *filePath = nil;
    //if(path!=nil){
       filePath = path; // do whatever you need to get the full path to your file
    //}
    
    //从路径中获得完整的文件名 （带后缀） 对从相册中取出的图片，视频都有效。
    NSString *fileName = nil;
    if(filePath==nil||media!=nil||mediaType==2){
        //
        
        if(media!=nil||mediaType==2){
            //视频或者音频
            NSString * mtype = [media objectForKey:@"UIImagePickerControllerMediaType"];
            NSLog(@"%@",mtype);
            if([mtype isEqualToString:@"public.movie"]||mediaType==2){
                
                fileData = [NSData dataWithContentsOfFile:path];
                md5 = [self MD5:fileData];
                
               
                NSString *mp4 = @"mp4";
                NSString *MP4= @"MP4";
                NSString *pathExt = [path pathExtension];
                NSLog(@"1996");
                if(pathExt == nil){
                    pathExt = @"mp4";
                }
                fileName = [[md5 stringByAppendingString:@"."] stringByAppendingString:pathExt];
//                if([path containsString:mp4]||[path containsString:MP4]){
//                    fileName = [md5 stringByAppendingString:@".mp4"];
//                }else{
//                    fileName = [md5 stringByAppendingString:@".MOV"];
//                }
                //contentMd5 = md5;
                
                fileType = @"video/quicktime";
                
               
            //保存视频
            NSArray *pp = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [pp objectAtIndex:0];
                
                NSString *videoFile = nil;
                
                NSString *pathExt1 = [path pathExtension];
                NSLog(@"2014");
                if(pathExt1==nil){
                    pathExt1=@"mp4";
                }
                videoFile = [documentsDirectory stringByAppendingPathComponent:[[md5 stringByAppendingString:@"."] stringByAppendingString:pathExt1]];
                
//                 if([path containsString:@"mp4"]||[path containsString:@"MP4"]){
//                      videoFile = [documentsDirectory stringByAppendingPathComponent:[md5 stringByAppendingString:@".mp4"]];
//                 }else{
//                      videoFile = [documentsDirectory stringByAppendingPathComponent:[md5 stringByAppendingString:@".MOV"]];
//                 }
           
                NSLog(@"videoFile2=%@",videoFile);
                
//                NSString *alertTitle = @"";
//                NSString *alertMsg = videoFile;
//                NSString *alertOk = @"确认";
//                NSString *alertCancel = @"取消";
//                
//                UIAlertView *alert= [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg
//                                                              delegate:self
//                                                     cancelButtonTitle:alertCancel otherButtonTitles:alertOk, nil];
//                [alert show];
                
                
                
            [fileData writeToFile:videoFile atomically:YES];
                
            }else if([mtype isEqualToString:@"mp3"]){
                //voice
                
               
                  md5 = [self md5HashOfPath:path];
                
                NSLog(@"2045");
                fileName = [md5 stringByAppendingString:@".mp3"];
                NSFileManager* fm=[NSFileManager defaultManager];
                fileData = [fm contentsAtPath:path];
                fileType = @"audio/mp3";
                
                
                double size = [fileData length];
                
                NSString *ssize = [[NSNumber numberWithDouble:size] stringValue];
                
                NSLog(@"mp3文件大小：%@",ssize);
                
            }else{
                 if(gifNsData !=nil )
                     fileName = [md5 stringByAppendingString:@".gif"];
                     else
                fileName = [md5 stringByAppendingString:@".jpg"];
            }
        }else{
            if(gifNsData !=nil )
                fileName = [md5 stringByAppendingString:@".gif"];
                else
            fileName = [md5 stringByAppendingString:@".jpg"];
        }
        
    }else{
       fileName = [filePath lastPathComponent];
    }
    
    NSLog(@"文件名fileName：%@",fileName);
    
    
    
    double size = [fileData length];
    
    NSString *ssize = [[NSNumber numberWithDouble:size] stringValue];
    
    NSLog(@"压缩后文件大小：%@",ssize);
    
    //cookie
    NSHTTPCookieStorage *cookieStorage  = ((AppDelegate*)([UIApplication sharedApplication].delegate)).cs;
    
    //NSString * activeUser = nil;
    NSString * num = nil;
    NSString * token = nil;
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        NSString *n = cookie.name;
        NSString *v = cookie.value;
        if([n isEqualToString:@"activeUser"]){
            activeUser = v;
        }else if([n isEqualToString:@"num"]){
            num = v;
        }else if([n isEqualToString:@"token"]){
            token = v;
        }else{
            
        }
    }
    
    
    
    // 1.创建一个管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    
    // 2.封装参数(这个字典只能放非文件参数)
//javascript
//    xhr.setRequestHeader("Content-Type", file.type+(file.charset?";charset="+file.charset:""));
//    xhr.setRequestHeader("X-File-Size",fileBlob.size);
//    xhr.setRequestHeader("X-Auth-Token",getCookie('token'));
//    xhr.setRequestHeader("X-Auth-Num",getCookie('num'));
//    xhr.setRequestHeader("Content-Disposition", "attachment;filename="+escape(encodeURIComponent(file.name)));
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"X-Auth-Num"] = num;
    params[@"X-Auth-Token"] = token;
    params[@"User-Agent"] = @"Mozilla/5.0 (iPhone; CPU iPhone OS 16_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.2 Mobile/15E148 Safari/604.1 veivo22 veivowk v202";
    NSLog(@"2116");
    params[@"Content-Disposition"] = [@"attachment;filename=" stringByAppendingString:fileName];
    params[@"Content-Type"] = fileType;
    params[@"Content-Length"] = ssize;
    params[@"X-File-Size"] = ssize;
    //params[@"height"] = @1.55;
    
    // 2.发送一个请求
    NSString *ccc = ((AppDelegate*)([UIApplication sharedApplication].delegate)).veivoCookie;
    
    NSLog(@"***cookie=%@",ccc);
    NSLog(@"uploading");
    
    params[@"Cookie"] = ccc;

    NSString *url = nil;
    
    
    if([ccc containsString:@"en.veivo.com"])
    {
        url = [NSString stringWithFormat:@"https://en.veivo.com/v1/veivo/"];
    }
    else
    {
        url = [NSString stringWithFormat:@"https://www.veivo.com/v1/veivo/"];
    }

    
    //NSString *url = @"https://en.veivo.com/v1/veivo/";
    NSLog(@"2145");
    url = [url stringByAppendingString:activeUser];
    url = [url stringByAppendingString:@"/"];
    url = [url stringByAppendingString:md5];
    
    NSLog(@"upload url:%@",url);

    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:url];
    //NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];

    [request setHTTPMethod:@"PUT"];
    
    //NSURL *filePath = [NSURL fileURLWithPath:@"file://path/to/image.png"];
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromData:fileData progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"Success: %@ %@", response, responseObject);
            //停止进度条
            [progressView removeFromSuperview];
            
            
           
            
            //upload
            NSString * up = @"https://en.veivo.com/vfs?des=up";
            if([ccc containsString:@"en.veivo.com"])
            {
                up = [NSString stringWithFormat:@"https://en.veivo.com/vfs?des=up"];
            }
            else
            {
                up = [NSString stringWithFormat:@"https://www.veivo.com/vfs?des=up"];
            }
            
            NSDictionary *dict = @{@"n": fileName,@"t" : fileType, @"to" :  @"veivo.vcloud.send",@"s":ssize,@"h":md5};
            
            NSString * ret = [self multiPartPost:dict withUrl:up];
            
            NSLog(@"ret=%@",ret);
            
            
            NSDictionary * dd = (NSDictionary*)[ret objectFromJSONString];
            
            NSString * fid = [dd objectForKey:@"fid"];
            
            NSLog(@"fid=%@",fid);
            
             NSArray *v = @[fid, fileType,fileName];
           // NSArray *v = @[fid, fileType,fileName,md5,imgMd5];//md5 is the md5 of content
            
            //放到dict
            [attach setObject:v forKey:md5];
            
           // if([curStr length]>0||attach.allKeys.count>0){
                [sendBt setBackgroundImage:[UIImage imageNamed:@"sendbgtxt"] forState:UIControlStateNormal];
            //}
            //else{
               // [sendBt setBackgroundImage:[UIImage imageNamed:@"sendbtbg"] forState:UIControlStateNormal];
            //}
            
            NSLog(@"all values:%@",attach.allValues);
            
            
            
        }
    }];
    [uploadTask resume];
    
    /*
    NSError *error;
    NSURLRequest *request = [mgr.requestSerializer multipartFormRequestWithMethod:@"PUT" URLString:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
       // NSData *fileData = [self zipNSDataWithImage:image];
        NSLog(@"***MIME-TYPE:%@",fileType);
        NSLog(@"***size:%@",[[NSNumber numberWithDouble:[fileData length]] stringValue]);
        NSLog(@"***md5:%@",[self MD5:fileData]);
        [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:fileType];
    } error:&error
                    
    ];
    
    AFHTTPRequestOperation *operation = [mgr HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"%@", @"上传成功");
        NSLog(@"%@", responseObject);
        //停止进度条
        [progressView removeFromSuperview];
        
        
        //upload
        NSString * up = @"https://en.veivo.com/vfs?des=up";
        if([ccc containsString:@"en.veivo.com"])
        {
            up = [NSString stringWithFormat:@"https://en.veivo.com/vfs?des=up"];
        }
        else
        {
            up = [NSString stringWithFormat:@"https://www.veivo.com/vfs?des=up"];
        }
     
     
     //   "[{"d":"https:en.veivo.com/v1/veivo/1560671918492388/v2_ec22b6a3e_5lZI3n50xRwZXKQb9-xehCwF56XeQbQKziAzEiic53WkcqsFOaJ2H1FlE6vbBG83NcjyfR8_25TRean3iUeupQN4d4kego3RlLZWT4","n":"1908904-2459f818a5ea992b.jpg","p":"https://www.veivo.com/userimages/photoPreview/186d/a0bc/9992/3545/74c5/03ac/edf7/34de/preview.jpg","t":"image/jpeg","s":26086,"h":"186da0bc9992354574c503acedf734de","x":300,"y":240}]”
     
     
     
        NSDictionary *dict = @{@"n": fileName,@"t" : fileType, @"to" :  @"veivo.vcloud.send",@"s":ssize,@"h":md5};
        
        NSString * ret = [self multiPartPost:dict withUrl:up];
        
        NSLog(@"ret=%@",ret);
        
        
        NSDictionary * dd = (NSDictionary*)[ret objectFromJSONString];
        
        NSString * fid = [dd objectForKey:@"fid"];
        
        NSLog(@"fid=%@",fid);
        
        
        //放到dict
        [attach setObject:fid forKey:md5];
        
        NSLog(@"all values:%@",attach.allValues);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        //停止进度条，并提示失败消息
        [progressView removeFromSuperview];
    }];
    
    [mgr.operationQueue addOperation:operation];
    */
}


//图片处理函数主方法
-(NSData *)zipNSDataWithImage:(UIImage *)sourceImage{
    //进行图像尺寸的压缩
    CGSize imageSize = sourceImage.size;//取出要压缩的image尺寸
    CGFloat width = imageSize.width;    //图片宽度
    CGFloat height = imageSize.height;  //图片高度
    //1.宽高大于1280(宽高比不按照2来算，按照1来算)
    if (width>1280||height>1280) {
        if (width>height) {
            CGFloat scale = height/width;
            width = 1280;
            height = width*scale;
        }else{
            CGFloat scale = width/height;
            height = 1280;
            width = height*scale;
        }
        //2.宽大于1280高小于1280
    }else if(width>1280||height<1280){
        CGFloat scale = height/width;
        width = 1280;
        height = width*scale;
        //3.宽小于1280高大于1280
    }else if(width<1280||height>1280){
        CGFloat scale = width/height;
        height = 1280;
        width = height*scale;
        //4.宽高都小于1280
    }else{
    }
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [sourceImage drawInRect:CGRectMake(0,0,width,height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //进行图像的画面质量压缩
    NSData *data=UIImageJPEGRepresentation(newImage, 1.0);
    if (data.length>100*1024) {
        if (data.length>1024*1024) {//1M以及以上
            data=UIImageJPEGRepresentation(newImage, 0.7);
        }else if (data.length>512*1024) {//0.5M-1M
            data=UIImageJPEGRepresentation(newImage, 0.8);
        }else if (data.length>200*1024) {
            //0.25M-0.5M
            data=UIImageJPEGRepresentation(newImage, 0.9);
        }
    }
    return data;
}

- (NSString *)md5HashOfPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // Make sure the file exists
  //  if( [fileManager fileExistsAtPath:path isDirectory:nil] )
    if(true)
    {
        NSData *data = [NSData dataWithContentsOfFile:path];
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5( data.bytes, (CC_LONG)data.length, digest );
        
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        
        for( int i = 0; i < CC_MD5_DIGEST_LENGTH; i++ )
        {
            [output appendFormat:@"%02x", digest[i]];
        }
        
        return output;
    }
    else
    {
        return @"";
    }
}
- (double)calulateImageFileSize:(UIImage *)image {
    NSData *data = UIImagePNGRepresentation(image);
    if (!data) {
        data = UIImageJPEGRepresentation(image, 1.0);//需要改成0.5才接近原图片大小，原因请看下文
    }
    double dataLength = [data length] * 1.0;
    return dataLength;
}
-(NSString *)multiPartPost:(NSDictionary *)dicData withUrl:(NSString *) u{
    NSString * ret = nil;
    NSString * POST_BOUNDS = @"---------------------------7d33a816d302b6";
    NSURL *url = [NSURL URLWithString:u];
    NSMutableString *bodyContent = [NSMutableString string];
    for(NSString *key in dicData.allKeys){
        id value = [dicData objectForKey:key];
        [bodyContent appendFormat:@"--%@\r\n",POST_BOUNDS];
        [bodyContent appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        [bodyContent appendFormat:@"%@\r\n",value];
    }
    [bodyContent appendFormat:@"--%@--\r\n",POST_BOUNDS];
    NSData *bodyData=[bodyContent dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [request addValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@",POST_BOUNDS] forHTTPHeaderField:@"Content-Type"];
    [request addValue: [NSString stringWithFormat:@"%zd",bodyData.length] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:bodyData];
    NSLog(@"请求的长度%@",[NSString stringWithFormat:@"%zd",bodyData.length]);
    __autoreleasing NSError *error=nil;
    __autoreleasing NSURLResponse *response=nil;
    NSLog(@"输出Bdoy中的内容>>\n%@",[[NSString alloc]initWithData:bodyData encoding:NSUTF8StringEncoding]);
    NSData *reciveData= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error){
        NSLog(@"出现异常%@",error);
    }else{
        NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse *)response;
        if(httpResponse.statusCode==200){
            NSLog(@"服务器成功响应!>>%@",[[NSString alloc]initWithData:reciveData encoding:NSUTF8StringEncoding]);
            ret = [[NSString alloc]initWithData:reciveData encoding:NSUTF8StringEncoding];
            return ret;
        }else{
            NSLog(@"服务器返回失败>>%@",[[NSString alloc]initWithData:reciveData encoding:NSUTF8StringEncoding]);
            return ret;
        }
        
    }
    return ret;
}

- (NSString *)UIUtilsFomateJsonWithDictionary:(NSMutableDictionary *)dic {
    
    NSArray *keys = [dic allKeys];
    
    NSString *string = [NSString string];
    
    
    
    for (NSString *key in keys) {
        
        NSString *value = [dic objectForKey:key];
        
        
        
        value = [NSString stringWithFormat:@"\"%@\"",value];
        
        NSString *newkey = [NSString stringWithFormat:@"\"%@\"",key];
        
        
        
        
        
        if (!string.length) {
            
            string = [NSString stringWithFormat:@"%@:%@}",newkey,value];
            
        }else {
            
            string = [NSString stringWithFormat:@"%@:%@,%@",newkey,value,string];
            
        }
        
    }
    
    string = [NSString stringWithFormat:@"{%@",string];
    
    return string;
    
}

- (NSString*)MD5:(NSData *) data
{
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5([data bytes], (CC_LONG)data.length, md5Buffer);
    
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}




- (NSString *)sd_contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
        case 0x52:
            // R as RIFF for WEBP
            if ([data length] < 12) {
                return nil;
            }
            
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"image/webp";
            }
            
            return nil;
    }
    return nil;
}
- (UIImage *)firstFrameWithVideoURL:(NSURL *)url size:(CGSize)size
{
    // 获取视频第一帧
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(size.width, size.height);
    NSError *error = nil;
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(0, 10) actualTime:NULL error:&error];
    {
        return [UIImage imageWithCGImage:img];
    }
    return nil;
}

//voice
- (void)startFakeTimer
{
    if (_fakeTimer) {
        [_fakeTimer invalidate];
        _fakeTimer = nil;
    }
    self.fakeTimer = [NSTimer scheduledTimerWithTimeInterval:kFakeTimerDuration target:self selector:@selector(onFakeTimerTimeOut) userInfo:nil repeats:YES];
    [_fakeTimer fire];
}

- (void)stopFakeTimer
{
    if (_fakeTimer) {
        [_fakeTimer invalidate];
        _fakeTimer = nil;
    }
}

- (void)onFakeTimerTimeOut
{
    self.duration += kFakeTimerDuration;
    NSLog(@"+++duration+++ %f",self.duration);
    float remainTime = kMaxRecordDuration-self.duration;
    if ((int)remainTime == 0) {
        self.currentRecordState = BBVoiceRecordState_Normal;
        [self dispatchVoiceState];
    }
    else if ([self shouldShowCounting]) {
        self.currentRecordState = BBVoiceRecordState_RecordCounting;
        [self dispatchVoiceState];
        [self.voiceRecordCtrl showRecordCounting:remainTime];
    }
    else
    {
        float fakePower = (float)(1+arc4random()%99)/100;
        [self.voiceRecordCtrl updatePower:fakePower];
    }
}

- (BOOL)shouldShowCounting
{
    if (self.duration >= (kMaxRecordDuration-kRemainCountingDuration) && self.duration < kMaxRecordDuration && self.currentRecordState != BBVoiceRecordState_ReleaseToCancel) {
        return YES;
    }
    return NO;
}

- (void)resetState
{
    [self stopFakeTimer];
    self.duration = 0;
    self.canceled = YES;
}

/*
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
    if (CGRectContainsPoint(_btnRecord.frame, touchPoint)) {
        self.currentRecordState = BBVoiceRecordState_Recording;
        [self dispatchVoiceState];
    }
}
*/

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
   
//   // if (_canceled) {
//    if(self.canceled){
//        [_recorder stop];
//        return;
//    }
//
//    CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
//    if (CGRectContainsPoint(attachStackView.frame, touchPoint)) {
//        self.currentRecordState = BBVoiceRecordState_Recording;
//    }
//    else
//    {
//        self.currentRecordState = BBVoiceRecordState_ReleaseToCancel;
//    }
//    [self dispatchVoiceState];
}

//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//   NSLog(@"%@",[_recorder isRecording]?@"YES":@"NO");
//    [_recorder stop];
//
//   // if (_canceled) {
//    NSLog(@"_canceled:%b",_canceled);
//    NSLog(@"self._canceled:%b",self.canceled);
//    if(self.canceled){
//        return;
//    }
//
//    CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
//    if (CGRectContainsPoint(attachStackView.frame, touchPoint)) {
//        if (self.duration < 1) {
//            [self.voiceRecordCtrl showToast:@"Message Too Short."];
//        }
//        else
//        {
////            NSURL *fileUrl = [NSURL fileURLWithPath:[self filePathWithName:[self newRecorderName]]];
//            long size = [self fileSizeAtPath:[voiceurl1 absoluteString]];
//            NSLog(@"caf size:%ld",size);
//
//            NSString *cafStr = [voiceurl1 absoluteString];
//
//            NSString *mp3Str = [cafStr stringByReplacingOccurrencesOfString:@".caf" withString:@".mp3"];
//
//            NSLog(@"caf path:%@",cafStr);
//            NSLog(@"mp3 path:%@", mp3Str);
//
//
//            NSString *mp3FileName = @"Mp3File";
//            mp3FileName = [mp3FileName stringByAppendingString:@".mp3"];
//            NSString *mp3FilePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"] stringByAppendingPathComponent:mp3FileName];
//
//            [self toMp31:cafStr:mp3FilePath];
//
//           // [self audioToMP3:cafStr:mp3FilePath];
//
//            long mp3size = [self fileSizeAtPath:mp3FilePath];
//            NSLog(@"mp3 size:%ld",mp3size);
//            //upload voice
//
//
//
//
//        }
//    }
//    self.currentRecordState = BBVoiceRecordState_Normal;
//    [self dispatchVoiceState];
//}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
//    [_recorder stop];
//   // if (_canceled) {
//    if(self.canceled){
//        return;
//    }
//
//    CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
//    if (CGRectContainsPoint(attachStackView.frame, touchPoint)) {
//        if (self.duration < 1) {
//            [self.voiceRecordCtrl showToast:@"Message Too Short."];
//        }
//        else
//        {
////            NSURL *fileUrl = [NSURL fileURLWithPath:[self filePathWithName:[self newRecorderName]]];
//            long size = [self fileSizeAtPath:[voiceFileUrl absoluteString]];
//            NSLog(@"%ld",size);
//            //upload voice
//        }
//    }
//    self.currentRecordState = BBVoiceRecordState_Normal;
//    [self dispatchVoiceState];
}

- (void)dispatchVoiceState
{
    if (_currentRecordState == BBVoiceRecordState_Recording) {
        self.canceled = NO;
        [self startFakeTimer];
    }
    else if (_currentRecordState == BBVoiceRecordState_Normal)
    {
        [self resetState];
    }
    //[attachStackView updateRecordButtonStyle:_currentRecordState];
    [self.voiceRecordCtrl updateUIWithRecordState:_currentRecordState];
}

- (BBVoiceRecordController *)voiceRecordCtrl
{
    if (_voiceRecordCtrl == nil) {
        _voiceRecordCtrl = [BBVoiceRecordController new];
    }
    return _voiceRecordCtrl;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)btnShort
{
    NSLog(@"de");
}
-(void)btnLong:(UILongPressGestureRecognizer *)gestureRecognizer{
    NSLog(@"touching...");
    
    
   
        NSLog(@"dispatch...");
        self.currentRecordState = BBVoiceRecordState_Recording;
        [self dispatchVoiceState];
   
    
}
- (long long)fileSizeAtPath:(NSString*)filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (void)toMP3:(NSString*) _strCafSavePath : (NSString *)_strMp3SavePath
{
    @try
    {
        //[ShowLoading show:NO];
        int read, write;
        NSLog(@"file size:%ld",[self fileSizeAtPath:_strCafSavePath]);
        FILE *pcm = fopen([[NSTemporaryDirectory() stringByAppendingPathComponent:_strCafSavePath] cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([[NSHomeDirectory() stringByAppendingPathComponent:_strMp3SavePath] cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        
        lame_t lame =lame_init();
        lame_set_in_samplerate(lame, 44100);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception)
    {
        NSLog(@"%@",[exception description]);
    }
    @finally
    {
        //[ShowLoading hidden];
//        if ([self.delegate respondsToSelector:@selector(saveVoiceFinish)]) {
//            [self.delegate saveVoiceFinish];
//        }
    }
}

- (void) toMp31:(NSString*) _strCafSavePath : (NSString*) mp3FilePath
{
    NSString *cafFilePath = _strCafSavePath;
    //=[NSTemporaryDirectory() stringByAppendingString:@"RecordedFile"];
    
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
//        lame_t lame = lame_init();
//        lame_set_in_samplerate(lame, 44100);
//        lame_set_VBR(lame, vbr_default);
//        lame_init_params(lame);
        
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 44100.0);//声音采样率
//        lame_set_VBR(lame, vbr_default);
//        lame_set_num_channels(lame,2);//默认为2双通道
//        lame_set_brate(lame,8);
//        lame_set_mode(lame,3);
        lame_set_quality(lame,5); /* 2=high 5 = medium 7=low 音质*/
        lame_init_params(lame);

        
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
        
        [self convertMp3Finish:nil withPath:mp3FilePath];
        
        long mp3size = [self fileSizeAtPath:mp3FilePath];
        NSLog(@"***mp3 size:%ld",mp3size);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
//        [self performSelectorOnMainThread:@selector(convertMp3Finish)
//                               withObject:nil
//                            waitUntilDone:YES];
    }
}
- (void)toMp33:(NSString*)cafFilePath:(NSString*)mp3FilePath

{
    
        
    
        //NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
    
//        NSString *cafFilePath = [pathstringByAppendingPathComponent:@"record.caf"];
//
//        NSString *mp3FilePath = [pathstringByAppendingPathComponent:@"record.mp3"];
//
//
    
        @try {
        
                int read, write;
        
                
        
                FILE *pcm =fopen([cafFilePath cStringUsingEncoding:1],"rb");//被转换的文件
        
                FILE *mp3 =fopen([mp3FilePath cStringUsingEncoding:1],"wb");//转换后文件的存放位置
        
                
        
                const int PCM_SIZE =8192;
        
                const int MP3_SIZE =8192;
        
                short int pcm_buffer[PCM_SIZE*2];
        
                unsigned char mp3_buffer[MP3_SIZE];
        
                
        
                lame_t lame =lame_init();
        
                lame_set_in_samplerate(lame,44100);
        
                lame_set_VBR(lame,vbr_default);
        
                lame_init_params(lame);
        
                
        
                do {
            
                        read = fread(pcm_buffer,2*sizeof(short int), PCM_SIZE, pcm);
            
                        if (read ==0)
                
                                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            
                        else
                
                                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
                        
            
                        fwrite(mp3_buffer, write,1, mp3);
            
                        
            
                    } while (read !=0);
        
                
        
                lame_close(lame);
        
                fclose(mp3);
        
                fclose(pcm);
        
            }
    
        @catch (NSException *exception) {
        
               // NSLog(@"%@",[exception description]);
        
            }
    [self convertMp3Finish:nil withPath:mp3FilePath];
    
    long mp3size = [self fileSizeAtPath:mp3FilePath];
    NSLog(@"***mp3 size:%ld",mp3size);
}

- (void)audioToMP3: (NSString *)sourcePath:(NSString*) mp3FilePath {
    
    NSString *inPath = sourcePath;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:sourcePath]){
        
        NSLog(@"file path error!");
        
        //return @"";
        
    }
    
    NSString *outPath = mp3FilePath;
    
    @try {
        
        int read, write;
        
        FILE *pcm = fopen([inPath cStringUsingEncoding:1], "rb");
        
        fseek(pcm, 4*1024, SEEK_CUR);
        
        FILE *mp3 = fopen([outPath cStringUsingEncoding:1], "wb");
        
        const int PCM_SIZE = 8192;
        
        const int MP3_SIZE = 8192;
        
        short int pcm_buffer[PCM_SIZE*2];
        
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        
        lame_set_VBR(lame, vbr_default);
        
        lame_set_num_channels(lame,2);//默认为2双通道
        
        lame_set_in_samplerate(lame, 20000);//11025.0
        
        lame_set_brate(lame,8);
        
        lame_set_mode(lame,3);
        
        lame_set_quality(lame,5); /* 2=high 5 = medium 7=low 音质*/
        
        lame_init_params(lame);
        
        do {
            
            read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            
            if (read == 0)
                
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            
            else
                
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        
        fclose(mp3);
        
        fclose(pcm);
        
    }
    
    @catch (NSException *exception) {
        
        NSLog(@"%@",[exception description]);
        
    }
    
    @finally {
        
        NSLog(@"mp3 build success!");
        
        if (false) {
            
            NSError *error;
            
            [fm removeItemAtPath:sourcePath error:&error];
            
            if (error == nil){
                
                NSLog(@"source file is deleted!");
                
            }
            
        }
        
        [self convertMp3Finish:nil withPath:mp3FilePath];
        
        long mp3size = [self fileSizeAtPath:mp3FilePath];
        NSLog(@"***mp3 size:%ld",mp3size);
        
        //return outPath;
        
    }
    
}

/*
-(BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(PHAsset *)asset

{
    
        NSInteger max =9;
    
        if (picker.selectedAssets.count >= max) {
        
                UIAlertController *alert = [UIAlertControlleralertControllerWithTitle:@"提示"message:[NSStringstringWithFormat:@"最多选择%zd张图片", max] preferredStyle:UIAlertControllerStyleAlert];
        
                [alert addAction:[UIAlertActionactionWithTitle:@"好的"style:UIAlertActionStyleDefaulthandler:nil]];
        
                [picker presentViewController:alertanimated:YEScompletion:nil];
        
                // 这里不能使用self来modal别的控制器，因为此时self.view不在window上
        
                returnNO;
        
            }
    
        returnYES;
    
}
*/


-(void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets

{
    
        PHAssetMediaType * mediaType=nil;
    
        NSArray *array =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    
        NSString *documents = [array lastObject];
    
        NSString *documentPath = [documents stringByAppendingPathComponent:@"arrayXML.xml"];
    
        
    
        NSArray *dataArray = [NSArray arrayWithArray:assets];
    
        
    
        
    
        [dataArray writeToFile:documentPath atomically:YES];
    
        
    
        
    
        
    
        NSArray *resultArray = [NSArray arrayWithContentsOfFile:documentPath];
    
        NSLog(@"%@", documentPath);
    
        
    
        
    
        // 关闭图片选择界面
    
        [picker dismissViewControllerAnimated:YES completion:nil];
    
        
    
        // 遍历选择的所有图片
    
       // self.plCollection.photoArray = assets;
    
        for (NSInteger i =0; i < assets.count; i++) {
        
                // 基本配置
        
                CGFloat scale = [UIScreen mainScreen].scale;
        
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        
                options.resizeMode   =PHImageRequestOptionsResizeModeExact;
        
                options.deliveryMode =PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
                
        
                PHAsset *asset = assets[i];
        
        __block NSString *path = nil;

        //
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info)
         {
             if ([asset isKindOfClass:[AVURLAsset class]])
             {
                 NSURL *url = [(AVURLAsset*)asset URL];
                 path = [url path];
             }
         }];
        //
        
        //判断是否gif图片
        __block NSData *gifData = nil;
        __block NSString *detectedComplete = nil;
        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil  resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            NSString *t = [self sd_contentTypeForImageData:imageData];
            NSLog(@"%@",t);
            if([t isEqualToString:@"image/gif"]){
                gifData = imageData;
            }
            detectedComplete = @"1";
//            dispatch_async(dispatch_get_main_queue(), ^{
//                CIImage *ciImage = [CIImage imageWithData:imageData];
//                if(completion) completion(imageData, dataUTI, orientation, info, ciImage.properties);
//            });
            
            
            
            
            
        }];
        
        
        do{
            //等待直到detected gif 完成
             [NSThread sleepForTimeInterval:0.1];
        }while(detectedComplete != nil);
        
//        NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
//        NSString *orgFilename = ((PHAssetResource*)resources[0]).originalFilename;
//
//        path = orgFilename;
            // path = savePath;
        
        mediaType = asset.mediaType;
        
                CGSize size =CGSizeMake(asset.pixelWidth / scale, asset.pixelHeight / scale);
        
        //        // 获取图片
        
                [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage *_Nullable image,NSDictionary *_Nullable info) {
            
//                        NSData *imageData =UIImageJPEGRepresentation([self imageWithImageSimple:resultscaledToSize:CGSizeMake(200,200)], 0.5);
//
                       // [self ossUpload:imageData];
            
            
            
            
            // 销毁控制器
            [picker dismissViewControllerAnimated:YES completion:nil];
            
            // 获得图片
           // UIImage *image = info[UIImagePickerControllerOriginalImage];
            
            // 显示图片
            //imageView.image = image;
            //    UIImageView *v = [[UIImageView alloc] init];
            //
            //    //[v height];
            //
            //    [preStackView addArrangedSubview:v];
            
            //NSString *path = [info objectForKey:@"UIImagePickerControllerImageURL"];
            
            NSString *videoPath = nil;
            
//            if(path==nil&&![[info objectForKey:@"UIImagePickerControllerMediaType"] isEqualToString:@"public.image"]){
//                path = [info objectForKey:@"UIImagePickerControllerMediaURL"];
//                
//                NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
//                NSString *moviePath = [videoUrl path];
//                //这里利用MPMoviePlayerController来获取
//                MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:videoUrl] ;
//                UIImage  *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
//                
//                //test
//                // playerVc = [[MPMoviePlayerController alloc]initWithContentURL:videoUrl] ;
//                //[playerVc play];
//                
//                //end test
//                
//                image = thumbnail;
//                player = nil;//释放player
//                
//                videoPath = moviePath;
//            }
            
            
            UIImageView* imageview=[[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 45, 45)];
            UIImageView* playview=[[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 45, 45)];
            
            if(pre1.image ==nil){
                pre1.image = image;
                //[SJAvatarBrowser showImage:pre1];
                pre1.userInteractionEnabled = YES;
                //添加手势
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTapAction:)];
                [pre1 addGestureRecognizer:tap];
                tap.view.tag=1;
                
                [self putPath:path videoPath:videoPath withKey:@"1"];
                
                
                
                //添加删除按钮
                UIImage *delimg = [UIImage imageNamed:@"closebt.png"];
                UIImageView *delimgview = [[UIImageView alloc] init];
                delimgview.alpha = 1;
                delimgview.image = delimg;
                delimgview.frame = CGRectMake(65, -0, 22,22);
                
                [pre1 addSubview:delimgview];
                
                UITapGestureRecognizer *delImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delImg:)];
                delImgTap.numberOfTapsRequired = 1;
                [delimgview setUserInteractionEnabled:YES];
                [delimgview addGestureRecognizer:delImgTap];
                
                
                //添加视频标志
                if(videoPath !=nil||mediaType==2){
                    UIImage *playimg = [UIImage imageNamed:@"play.png"];
                    playview.image=playimg;
                    [pre1 addSubview:playview];
                }
                
                //上传进度条
                //        UIProgressView *progressView;
                //        progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
                //        progressView.progressTintColor = [UIColor colorWithRed:187.0/255 green:160.0/255 blue:209.0/255 alpha:1.0];
                //        [[progressView layer]setFrame:CGRectMake(20, 20, 50, 50)];
                //        [[progressView layer]setBorderColor:[UIColor redColor].CGColor];
                //        progressView.trackTintColor = [UIColor clearColor];
                //        [progressView setProgress:(float)(50/100) animated:YES];  ///15
                //
                //        [[progressView layer]setCornerRadius:progressView.frame.size.width / 2];
                //        [[progressView layer]setBorderWidth:3];
                //        [[progressView layer]setMasksToBounds:TRUE];
                //        progressView.clipsToBounds = YES;
                
                NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"progress" withExtension:@"gif"];
                //加载GIF图片
                CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);
                //将GIF图片转换成对应的图片源
                size_t frameCout=CGImageSourceGetCount(gifSource);
                //获取其中图片源个数，即由多少帧图片组成
                NSMutableArray* frames=[[NSMutableArray alloc] init];
                //定义数组存储拆分出来的图片
                for (size_t i=0; i<frameCout;i++){
                    CGImageRef imageRef=CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
                    //从GIF图片中取出源图片
                    UIImage* imageName=[UIImage imageWithCGImage:imageRef];
                    //将图片源转换成UIimageView能使用的图片源
                    [frames addObject:imageName];//将图片加入数组中
                    CGImageRelease(imageRef);
                    
                }
                imageview.animationImages=frames;
                //将图片数组加入UIImageView动画数组中
                imageview.animationDuration=3;
                //每次动画时长
                [imageview startAnimating];
                //开启动画，此处没有调用播放次数接口，UIImageView默认播放次数为无限次，故这里不做处理
                [pre1 addSubview:imageview];
                
                
            }else if(pre2.image ==nil){
                pre2.image = image;
                //[SJAvatarBrowser showImage:pre2];
                pre2.userInteractionEnabled = YES;
                //添加手势
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTapAction:)];
                [pre2 addGestureRecognizer:tap];
                //[tap setValue:videoPath forKey:@"videoPath"];
                tap.view.tag=2;
                [self putPath:path videoPath:videoPath withKey:@"2"];
                
                //添加删除按钮
                UIImage *delimg = [UIImage imageNamed:@"closebt.png"];
                UIImageView *delimgview = [[UIImageView alloc] init];
                delimgview.alpha = 1;
                delimgview.image = delimg;
                delimgview.frame = CGRectMake(65, -0, 22,22);
                
                [pre2 addSubview:delimgview];
                
                UITapGestureRecognizer *delImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delImg:)];
                delImgTap.numberOfTapsRequired = 1;
                [delimgview setUserInteractionEnabled:YES];
                [delimgview addGestureRecognizer:delImgTap];
                
                //添加视频标志
                if(videoPath !=nil||mediaType==2){
                    UIImage *playimg = [UIImage imageNamed:@"play.png"];
                    playview.image=playimg;
                    [pre2 addSubview:playview];
                }
                
                
                NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"progress" withExtension:@"gif"];
                //加载GIF图片
                CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);
                //将GIF图片转换成对应的图片源
                size_t frameCout=CGImageSourceGetCount(gifSource);
                //获取其中图片源个数，即由多少帧图片组成
                NSMutableArray* frames=[[NSMutableArray alloc] init];
                //定义数组存储拆分出来的图片
                for (size_t i=0; i<frameCout;i++){
                    CGImageRef imageRef=CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
                    //从GIF图片中取出源图片
                    UIImage* imageName=[UIImage imageWithCGImage:imageRef];
                    //将图片源转换成UIimageView能使用的图片源
                    [frames addObject:imageName];//将图片加入数组中
                    CGImageRelease(imageRef);
                    
                }
                
                imageview.animationImages=frames;
                //将图片数组加入UIImageView动画数组中
                imageview.animationDuration=3;
                //每次动画时长
                [imageview startAnimating];
                //开启动画，此处没有调用播放次数接口，UIImageView默认播放次数为无限次，故这里不做处理
                [pre2 addSubview:imageview];
            }else if(pre3.image ==nil){
                pre3.image = image;
                //[SJAvatarBrowser showImage:pre3];
                pre3.userInteractionEnabled = YES;
                //添加手势
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTapAction:)];
                [pre3 addGestureRecognizer:tap];
                //[tap setValue:videoPath forKey:@"videoPath"];
                tap.view.tag=3;
                [self putPath:path videoPath:videoPath withKey:@"3"];
                
                //添加删除按钮
                UIImage *delimg = [UIImage imageNamed:@"closebt.png"];
                UIImageView *delimgview = [[UIImageView alloc] init];
                delimgview.alpha = 1;
                delimgview.image = delimg;
                delimgview.frame = CGRectMake(65, -0, 22,22);
                
                [pre3 addSubview:delimgview];
                
                UITapGestureRecognizer *delImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delImg:)];
                delImgTap.numberOfTapsRequired = 1;
                [delimgview setUserInteractionEnabled:YES];
                [delimgview addGestureRecognizer:delImgTap];
                
                
                //添加视频标志
                if(videoPath !=nil||mediaType==2){
                    UIImage *playimg = [UIImage imageNamed:@"play.png"];
                    playview.image=playimg;
                    [pre3 addSubview:playview];
                }
                
                NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"progress" withExtension:@"gif"];
                //加载GIF图片
                CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);
                //将GIF图片转换成对应的图片源
                size_t frameCout=CGImageSourceGetCount(gifSource);
                //获取其中图片源个数，即由多少帧图片组成
                NSMutableArray* frames=[[NSMutableArray alloc] init];
                //定义数组存储拆分出来的图片
                for (size_t i=0; i<frameCout;i++){
                    CGImageRef imageRef=CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
                    //从GIF图片中取出源图片
                    UIImage* imageName=[UIImage imageWithCGImage:imageRef];
                    //将图片源转换成UIimageView能使用的图片源
                    [frames addObject:imageName];//将图片加入数组中
                    CGImageRelease(imageRef);
                    
                }
                
                imageview.animationImages=frames;
                //将图片数组加入UIImageView动画数组中
                imageview.animationDuration=3;
                //每次动画时长
                [imageview startAnimating];
                //开启动画，此处没有调用播放次数接口，UIImageView默认播放次数为无限次，故这里不做处理
                [pre3 addSubview:imageview];
            }else if(pre4.image ==nil){
                pre4.image = image;
                //[SJAvatarBrowser showImage:pre4];
                pre4.userInteractionEnabled = YES;
                //添加手势
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTapAction:)];
                [pre4 addGestureRecognizer:tap];
                //[tap setValue:videoPath forKey:@"videoPath"];
                tap.view.tag=4;
                [self putPath:path videoPath:videoPath withKey:@"4"];
                
                //添加删除按钮
                UIImage *delimg = [UIImage imageNamed:@"closebt.png"];
                UIImageView *delimgview = [[UIImageView alloc] init];
                delimgview.alpha = 1;
                delimgview.image = delimg;
                delimgview.frame = CGRectMake(65, -0, 22,22);
                
                [pre4 addSubview:delimgview];
                
                UITapGestureRecognizer *delImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delImg:)];
                delImgTap.numberOfTapsRequired = 1;
                [delimgview setUserInteractionEnabled:YES];
                [delimgview addGestureRecognizer:delImgTap];
                
                //添加视频标志
                if(videoPath !=nil||mediaType==2){
                    UIImage *playimg = [UIImage imageNamed:@"play.png"];
                    playview.image=playimg;
                    [pre4 addSubview:playview];
                }
                
                NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"progress" withExtension:@"gif"];
                //加载GIF图片
                CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);
                //将GIF图片转换成对应的图片源
                size_t frameCout=CGImageSourceGetCount(gifSource);
                //获取其中图片源个数，即由多少帧图片组成
                NSMutableArray* frames=[[NSMutableArray alloc] init];
                //定义数组存储拆分出来的图片
                for (size_t i=0; i<frameCout;i++){
                    CGImageRef imageRef=CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
                    //从GIF图片中取出源图片
                    UIImage* imageName=[UIImage imageWithCGImage:imageRef];
                    //将图片源转换成UIimageView能使用的图片源
                    [frames addObject:imageName];//将图片加入数组中
                    CGImageRelease(imageRef);
                    
                }
                
                imageview.animationImages=frames;
                //将图片数组加入UIImageView动画数组中
                imageview.animationDuration=3;
                //每次动画时长
                [imageview startAnimating];
                //开启动画，此处没有调用播放次数接口，UIImageView默认播放次数为无限次，故这里不做处理
                [pre4 addSubview:imageview];
            }else{
                NSString *alertTitle = @"";
                NSString *alertMsg = @"最多只能发4个附件";
                NSString *alertOk = @"确认";
                NSString *alertCancel = @"取消";
                
                UIAlertView *alert= [[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg
                                                              delegate:self
                                                     cancelButtonTitle:alertCancel otherButtonTitles:alertOk, nil];
                [alert show];
            }
            
            
            
            
            
            if(path == nil){//总是path==nil?
                [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info)
                 {
                     if ([asset isKindOfClass:[AVURLAsset class]])
                     {
                         NSURL *url = [(AVURLAsset*)asset URL];
                         path = [url path];
                         
                         [self upload:path withProgress:imageview withImage:image withMedia:info withMediaType:mediaType withGifNsData:nil];

                     }
                     else{
                         [self upload:path withProgress:imageview withImage:image withMedia:info withMediaType:mediaType withGifNsData:gifData];
                     }
                 }];
            }else{
                [self upload:path withProgress:imageview withImage:image withMedia:info withMediaType:mediaType withGifNsData:nil];

            }
            
            
        
            
            
            
            
            
                    }];
        
            }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    /*
     * 不能输入.0-9以外的字符。
     * 设置输入框输入的内容格式
     * 只能有一个小数点
     * 小数点后最多能输入两位
     * 如果第一位是.则前面加上0.
     * 如果第一位是0则后面必须输入点，否则不能输入。
     */
    
    // 判断是否有小数点
    if ([textField.text containsString:@"."]) {
        self->isHaveDian = YES;
    }else{
        self->isHaveDian = NO;
    }
    
    if (string.length > 0) {
        
        //当前输入的字符
        unichar single = [string characterAtIndex:0];
       // BXLog(@"single = %c",single);
        
        // 不能输入.0-9以外的字符
        if (!((single >= '0' && single <= '9') || single == '.'))
        {
          //  [MBProgressHUD bwm_showTitle:@"您的输入格式不正确" toView:self hideAfter:1.0];
            return NO;
        }
        
        // 只能有一个小数点
        if (self->isHaveDian && single == '.') {
            //[MBProgressHUD bwm_showTitle:@"最多只能输入一个小数点" toView:self hideAfter:1.0];
            return NO;
        }
        
        // 如果第一位是.则前面加上0.
        if ((textField.text.length == 0) && (single == '.')) {
            textField.text = @"0";
        }
        
        // 如果第一位是0则后面必须输入点，否则不能输入。
        if ([textField.text hasPrefix:@"0"]) {
            if (textField.text.length > 1) {
                NSString *secondStr = [textField.text substringWithRange:NSMakeRange(1, 1)];
                if (![secondStr isEqualToString:@"."]) {
//                    [MBProgressHUD bwm_showTitle:@"第二个字符需要是小数点" toView:self hideAfter:1.0];
                    return NO;
                }
            }else{
                if (![string isEqualToString:@"."]) {
//                    [MBProgressHUD bwm_showTitle:@"第二个字符需要是小数点" toView:self hideAfter:1.0];
                    return NO;
                }
            }
        }
        
        // 小数点后最多能输入两位
        if (self->isHaveDian) {
            NSRange ran = [textField.text rangeOfString:@"."];
            // 由于range.location是NSUInteger类型的，所以这里不能通过(range.location - ran.location)>2来判断
            if (range.location > ran.location) {
                if ([textField.text pathExtension].length > 1) {
//                    [MBProgressHUD bwm_showTitle:@"小数点后最多有两位小数" toView:self hideAfter:1.0];
                    return NO;
                }
            }
        }
        
    }
    
    return YES;
}
+(UIColor*)hexToColor:(NSInteger)hex{
    return [UIColor colorWithRed:(hex>>16&0xff)/255.f green:(hex>>8&0xff)/255.f blue:(hex&0xff)/255.f alpha:1];
}


-(NSString *)encodeWithEscape:(NSString *)str
{
    NSArray *hex = [NSArray arrayWithObjects:
                    @"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"0A",@"0B",@"0C",@"0D",@"0E",@"0F",
                    @"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"1A",@"1B",@"1C",@"1D",@"1E",@"1F",
                    @"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"2A",@"2B",@"2C",@"2D",@"2E",@"2F",
                    @"30",@"31",@"32",@"33",@"34",@"35",@"36",@"37",@"38",@"39",@"3A",@"3B",@"3C",@"3D",@"3E",@"3F",
                    @"40",@"41",@"42",@"43",@"44",@"45",@"46",@"47",@"48",@"49",@"4A",@"4B",@"4C",@"4D",@"4E",@"4F",
                    @"50",@"51",@"52",@"53",@"54",@"55",@"56",@"57",@"58",@"59",@"5A",@"5B",@"5C",@"5D",@"5E",@"5F",
                    @"60",@"61",@"62",@"63",@"64",@"65",@"66",@"67",@"68",@"69",@"6A",@"6B",@"6C",@"6D",@"6E",@"6F",
                    @"70",@"71",@"72",@"73",@"74",@"75",@"76",@"77",@"78",@"79",@"7A",@"7B",@"7C",@"7D",@"7E",@"7F",
                    @"80",@"81",@"82",@"83",@"84",@"85",@"86",@"87",@"88",@"89",@"8A",@"8B",@"8C",@"8D",@"8E",@"8F",
                    @"90",@"91",@"92",@"93",@"94",@"95",@"96",@"97",@"98",@"99",@"9A",@"9B",@"9C",@"9D",@"9E",@"9F",
                    @"A0",@"A1",@"A2",@"A3",@"A4",@"A5",@"A6",@"A7",@"A8",@"A9",@"AA",@"AB",@"AC",@"AD",@"AE",@"AF",
                    @"B0",@"B1",@"B2",@"B3",@"B4",@"B5",@"B6",@"B7",@"B8",@"B9",@"BA",@"BB",@"BC",@"BD",@"BE",@"BF",
                    @"C0",@"C1",@"C2",@"C3",@"C4",@"C5",@"C6",@"C7",@"C8",@"C9",@"CA",@"CB",@"CC",@"CD",@"CE",@"CF",
                    @"D0",@"D1",@"D2",@"D3",@"D4",@"D5",@"D6",@"D7",@"D8",@"D9",@"DA",@"DB",@"DC",@"DD",@"DE",@"DF",
                    @"E0",@"E1",@"E2",@"E3",@"E4",@"E5",@"E6",@"E7",@"E8",@"E9",@"EA",@"EB",@"EC",@"ED",@"EE",@"EF",
                    @"F0",@"F1",@"F2",@"F3",@"F4",@"F5",@"F6",@"F7",@"F8",@"F9",@"FA",@"FB",@"FC",@"FD",@"FE",@"FF", nil];
    
    NSMutableString *result = [NSMutableString stringWithString:@""];
    int strLength = (int)str.length;
    for (int i=0; i<strLength; i++) {
        int ch = [str characterAtIndex:i];
        if (ch == ' ')
        {
            [result appendFormat:@"%c",'+'];
        }
        else if ('A' <= ch && ch <= 'Z')
        {
            [result appendFormat:@"%c",(char)ch];
            
        }
        else if ('a' <= ch && ch <= 'z')
        {
            [result appendFormat:@"%c",(char)ch];
        }
        else if ('0' <= ch && ch<='9')
        {
            [result appendFormat:@"%c",(char)ch];
        }
        else if (ch == '-' || ch == '_'
                 || ch == '.' || ch == '!'
                 || ch == '~' || ch == '*'
                 || ch == '\'' || ch == '('
                 || ch == ')')
        {
            [result appendFormat:@"%c",(char)ch];
        }
        else if (ch <= 0x007F)
        {
            [result appendFormat:@"%%"];
            [result appendString:[hex objectAtIndex:ch]];
        }
        else
        {
            [result appendFormat:@"%%"];
            [result appendFormat:@"%c",'u'];
            [result appendString:[hex objectAtIndex:ch>>8]];
            [result appendString:[hex objectAtIndex:0x00FF & ch]];
        }
    }
    return result;
}

- (NSString *)URLEncodedString:(NSString *)str {
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)str,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    return encodedString;
}

- (NSString *)avatarString:(NSString *)aid{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    int appid = [f numberFromString:aid].intValue;
    
    int imgid1 = appid % 100;
    int userid2 = (appid - imgid1) / 100;
    int imgid2 = userid2 % 100;
    int userid3 = (userid2 - imgid2) / 100;
    int imgid3 = userid3 % 100;
    int userid4 = (userid3 - imgid3) / 100;
    int imgid4 = userid4 % 100;
    int userid5 = (userid4 - imgid4) / 100;
    int imgid5 = userid5 % 100;
    
    NSString *avatarURL = [[[[[[[[[[@"https://www.veivo.com/userimages/custom/" stringByAppendingString:[NSString stringWithFormat:@"%d",imgid5]] stringByAppendingString:@"/"]
                           stringByAppendingString:[NSString stringWithFormat:@"%d",imgid4]]
                           stringByAppendingString:@"/"]
                           stringByAppendingString:[NSString stringWithFormat:@"%d",imgid3]]
                           stringByAppendingString:@"/"]
                           stringByAppendingString:[NSString stringWithFormat:@"%d",imgid2]]
                           stringByAppendingString:@"/"]
                           stringByAppendingString:[NSString stringWithFormat:@"%d",imgid1]]
                           stringByAppendingString:@"/avatar.gif"];
    
    return avatarURL;
}

-(UIImage *) getImageFromURL:(NSString *)fileURL

{
    
    
    
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    
    result = [UIImage imageWithData:data];
    
    return result;
    
}

+ (NSString *)typeForImageData:(NSData *)data {
    
    
    
    uint8_t c;
    
    [data getBytes:&c length:1];
    
    
    
    switch (c) {
            
        case 0xFF:
            
            return @"image/jpeg";
            
        case 0x89:
            
            return @"image/png";
            
        case 0x47:
            
            return @"image/gif";
            
        case 0x49:
            
        case 0x4D:
            
            return @"image/tiff";
            
    }
    
    return nil;
    
}
-(void)m_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 逻辑处理
    NSLog(@"tableview cell tap...");
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    appid = [appid_dic objectForKey:indexPath];
    
    writetovalue = [writeto_dic objectForKey:indexPath];
    //update avatar...
    
    
//    NSString *avatarUrl = [self avatarString:appid];
//    NSLog(@"avatar=%@",avatarUrl);
//
//    UIImage * avatarImg = [self getImageFromURL:avatarUrl];
//
//    [avatar setImage:avatarImg];
    //不显示头像，而改用文字
    
    [writeto setText:writetovalue];
    
    //hide
    first.hidden = YES;
}
#pragma mark - 点击事件
- (void)myTableViewClick:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:tableView];
    NSIndexPath *indexpath = [tableView indexPathForRowAtPoint:point];
    if ([self respondsToSelector:@selector(m_tableView:didSelectRowAtIndexPath:)]) {
        [self m_tableView:tableView didSelectRowAtIndexPath:indexpath];
    }
}
-(UITableView *)makeTableView
{
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = 300;
    CGFloat height = 135;
    CGRect tableFrame = CGRectMake(x, y, width, height);
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];
    
    tableView.rowHeight = 45;
    tableView.sectionFooterHeight = 22;
    tableView.sectionHeaderHeight = 22;
    tableView.scrollEnabled = YES;
    tableView.showsVerticalScrollIndicator = YES;
    tableView.userInteractionEnabled = YES;
    tableView.bounces = YES;
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    return tableView;
}



- (NSInteger)numberOfRowsInSection:(NSInteger)section{
    return 5;
}
- (void)initdata {
    NSLog(@"initData appid=%@",appid);
    
    //1.创建NSURLSession对象（可以获取单例对象）
    NSURLSession *session = [NSURLSession sharedSession];
    //https://en.veivo.com/info?atx=ownapps
    NSString *urlString = @"https://en.veivo.com/info?atx=ownapps";
    
    //创建一个请求对象，并这是请求方法为POST，把参数放在请求体中传递
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    //[request setURL:[NSURL URLWithString:urlString]];
    
    [request setHTTPMethod:@"GET"];
    
    NSString *contentType = [NSString stringWithFormat:@"text/plain"];
    
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
   
    
    [request setValue:((AppDelegate*)([UIApplication sharedApplication].delegate)).veivoCookie forHTTPHeaderField:@"Cookie"];
    
    
    NSString *userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 16_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.2 Mobile/15E148 Safari/604.1 veivo22 veivowk v202";

    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    //请求头
    
//    UserEntity *entity1 = [[UserEntity alloc] initWithName:@"user1" appid:appid];
//    UserEntity *entity2 = [[UserEntity alloc] initWithName:@"user1" appid:appid];
//
    UserGroup *group1 = [[UserGroup alloc] initWithEntities:[NSMutableArray arrayWithObjects: nil] GroupIdentifier:@"" GroupIntro:@""];
    _dataSource = [NSMutableArray arrayWithObjects:group1, nil];

    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error) {
        
        if (error == nil) {
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"obj=%@",responseObject);
            

//            for (int i=0;i<responseObject.count;i++){
//                //responseObject[i];
//                NSLog(@"%@",responseObject[i]);
//            }
            
           
            for (NSDictionary *key in responseObject) {
                
//                NSLog(@"name:%@",[key objectForKey:@"name" ]);
//                NSLog(@"appid:%@",[key objectForKey:@"id" ]);
                //NSLog(@"key: %@ value: %@", key, responseObject[key]);
                
                UserEntity *entity = [[UserEntity alloc] initWithName:[key objectForKey:@"name" ] appid:[key objectForKey:@"id" ]];
                
                [group1 addEntity:entity];
                
                NSLog(@"name=%@,appid=%@",entity.name,entity.appid);
                
               // [appid_dic setObject:appid forKey:NSIndexPath];
                
            }
            
           
            
               [self performSelectorOnMainThread:@selector(updateWithResults:) withObject:nil waitUntilDone:NO];
           

//            NSLog(@"name=%@",[responseObject objectForKey:@"name"]);
//            NSLog(@"appid=%@",[responseObject objectForKey:@"id"]);
            //success(responseObject);
        }else{
            NSLog(@"%@",error);
            //failure(error);
        }
        
        canBack = YES;
        
    }];
    
    //3.执行Task
    //注意：刚创建出来的task默认是挂起状态的，需要调用该方法来启动任务（执行任务）
    [dataTask resume];
    
    
    
    
   
}

- (void)updateWithResults:(NSArray*)theResults
{
    [tableView reloadData];
}

//返回列表分组数，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_dataSource count];
}

//返回列表每个分组section拥有cell行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [((UserGroup *)_dataSource[section]).userEntities count];
}

//配置每个cell，随着用户拖拽列表，cell将要出现在屏幕上时此方法会不断调用返回cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"mycell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    UserGroup *group = _dataSource[indexPath.section];
    UserEntity *entity = group.userEntities[indexPath.row];
    //cell.detailTextLabel.text = entity.appid;
    cell.textLabel.text = entity.name;
    
    [appid_dic setObject:entity.appid forKey:indexPath];
    [writeto_dic setObject:entity.name
                    forKey:indexPath];
    
    NSString *avatarUrl = [self avatarString:entity.appid];
    NSLog(@"avatar=%@",avatarUrl);
    
//    UIImage * avatarImg = [self getImageFromURL:avatarUrl];
//    cell.imageView.image =avatarImg;
    
    //给cell设置accessoryType或者accessoryView
    //也可以不设置，这里纯粹为了展示cell的常用可设置选项
    if (indexPath.section == 0 && indexPath.row == 0) {
        //cell.accessoryType = UITableViewCellAccessoryDetailButton;
    }else if (indexPath.section == 0 && indexPath.row == 1) {
        //cell.accessoryView = [[UISwitch alloc] initWithFrame:CGRectZero];
    } else {
        //cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    //设置cell没有选中效果
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

//返回列表每个分组头部说明
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [_dataSource[section] groupIdentifier];
}

//返回列表每个分组尾部说明
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [_dataSource[section] groupIntro];
}

- (void)textFieldDidChange:(UITextField *)sender {
//    self.textLabel.text = sender.text;
//    self.emojiEncodeLabel.text = [sender.text emojiEncode];
//    self.emojiDecodeLabel.text = [[sender.text emojiEncode]emojiDecode];
}


//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    //退出键盘
//    [textField endEditing:YES];
//}
/*
- (void)requestPUTWithURLStr:(NSString *)urlStr paramDic:(NSDictionary *)paramDic finish:(void(^)(id responseObject))finish enError:(void(^)(NSError *error))enError{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/javascript",@"text/json",@"text/plain", nil];
    
    // 设置请求头
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager PUT:urlStr parameters:paramDic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *errcode = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"errcode"]];
        
        if ([errcode isEqualToString:@"0"]) {
            
            finish(responseObject);
            
        }else{
            NSString *errmsg = [responseObject objectForKey:@"errmsg"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        enError(error);
    }];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
