//
//  EditNowViewController.m
//  PresentationCreator
//
//  Created by songyang on 15/10/19.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import "EditNowViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface EditNowViewController ()<UIWebViewDelegate,AVAudioRecorderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>
@property (nonatomic ,strong) UIWebView *webView;
@property (nonatomic, strong) NSString *htmlSource;
@property (nonatomic, strong) NSString *imgIndex;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic ,strong) NSString *fullPath;

@property (nonatomic, strong) UIControl *editTextViewControl;
@property (nonatomic, strong) UIControl *aduioViewControl;
@property (nonatomic) BOOL buttonFlag;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, copy)   NSString *audioPath;
@property (nonatomic, strong) NSString *audioName;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;//音频录音机
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件
@property (nonatomic, strong) NSTimer *timer;//录音声波监控（注意这里暂时不对播放进行监控）
@property (nonatomic, strong) UIProgressView *audioPower;//音频波动


@end

@implementation EditNowViewController

-(void)viewWillAppear:(BOOL)animated
{
    self.parentViewController.tabBarController.tabBar.hidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    self.parentViewController.tabBarController.tabBar.hidden = NO;
    //    self.navigationItem.hidesBackButton =NO;//隐藏系统自带导航栏按钮
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title= @"Edit Your Style";
    _fullPath = [[NSString alloc]init];
    _audioPath = [[NSString alloc]init];

    [self addNewWebView];
    [self addAudioButton];
    _buttonFlag = FALSE;
}
-(void)addAudioButton{
    UIButton *audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    audioButton.frame = CGRectMake(2, KScreenHeight - 64 + 16, KScreenWidth-4, 46);
    [audioButton setTitle:@"Record a audio" forState:UIControlStateNormal];
    [audioButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [audioButton setBackgroundColor:[UIColor grayColor]];
   
    [audioButton addTarget:self action:@selector(showAudioView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:audioButton];
}

-(void)showAudioView{
    _aduioViewControl = [[UIControl alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
    _aduioViewControl.backgroundColor = [UIColor lightGrayColor];
    _aduioViewControl.alpha = 0.97;
//    [_aduioViewControl addTarget:self action:@selector(removeView) forControlEvents:UIControlEventTouchUpInside];
    _startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _startButton.frame = CGRectMake(KScreenWidth * 0.25 - 60 , KScreenHeight * 0.5 + 40, 120, 120);
    [_startButton setTitle:@"START" forState:UIControlStateNormal];
    [_startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _startButton.backgroundColor = [UIColor redColor];
    [_startButton.layer setMasksToBounds:YES];
    [_startButton.layer setBorderWidth:5.0];
    [_startButton.layer setCornerRadius:60.0];
    _startButton.titleLabel.font = [UIFont systemFontOfSize:22.0];
    _startButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [_startButton addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchUpInside];
    [_aduioViewControl addSubview:_startButton];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    backButton.frame = CGRectMake(KScreenWidth * 0.75 - 60 , KScreenHeight * 0.5 + 40, 120, 120);
    [backButton setTitle:@"BACK" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backButton.backgroundColor = [UIColor darkGrayColor];
    backButton.titleLabel.font = [UIFont systemFontOfSize:22.0];
    [backButton.layer setMasksToBounds:YES];
    
    [backButton.layer setBorderWidth:5.0];
    [backButton.layer setCornerRadius:60.0];
    backButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [backButton addTarget:self action:@selector(closeAudioView) forControlEvents:UIControlEventTouchUpInside];
    
    // progess bar
    _audioPower = [[UIProgressView alloc]init];
    _audioPower.frame = CGRectMake(30, KScreenHeight * 0.3, KScreenWidth - 60, 30);
    _audioPower.transform = CGAffineTransformMakeScale(1.0f, 13.0f);
    [_aduioViewControl addSubview:_startButton];
    [_aduioViewControl addSubview:backButton];
    [_aduioViewControl addSubview:_audioPower];
    
    [self.view addSubview:_aduioViewControl];
   // [self.view bringSubviewToFront:_aduioViewControl];
   

}

-(void)startRecord{
    
    if(!_buttonFlag){
        _audioName = [[NSString alloc]init];
        _audioName =  [NSString stringWithFormat:@"%d.wav",arc4random() % 1000000];
        if (![self.audioRecorder isRecording]) {
            [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
            self.timer.fireDate=[NSDate distantPast];
        }
      
        [_startButton setTitle:@"STOP" forState:UIControlStateNormal];
        _buttonFlag = TRUE;
    }else{
        [self.audioRecorder stop];
        self.timer.fireDate=[NSDate distantFuture];
        self.audioPower.progress=0.0;
        
        [_startButton setTitle:@"START" forState:UIControlStateNormal];
        _buttonFlag = FALSE;
        
    }
}
-(void)closeAudioView{
    [self editAudioComponent];
    [_aduioViewControl removeFromSuperview];
    _aduioViewControl = nil;
    if(_audioPath == nil || [_audioPath isEqualToString:@""]){
        NSLog(@"exec htmlfunciton");
        _audioPath = nil;
    }else{
        
    }
}
-(void)addNewWebView
{
    UIView *aView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:aView];
    self.webView = [[UIWebView alloc]init];
    self.webView.frame = CGRectMake(0, 64, KScreenWidth, KScreenHeight-64-50);
    self.webView.backgroundColor = [UIColor blackColor];
    NSString *path = [[NSBundle mainBundle]bundlePath];
    NSURL *baseUrl = [NSURL fileURLWithPath:path];
    [self.webView loadHTMLString:self.editNowHtmlCodeStr baseURL:baseUrl];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    [self loadHtmlToWebView];
}
#pragma mark - webview JSContext
//获取webview中section里的heml代码
- (void)getHtmlCodeClick {
    //native  call js 代码
    NSString *jsToGetHtmlSource =  @"document.getElementsByTagName('html')[0].innerHTML";
    //    NSString *htmlSource = @"<section class='swiper-slide swiper-slide2'>";//slide2需要拼接获取正确的索引值
    _htmlSource = @"<!DOCTYPE html><html>";
    _htmlSource = [_htmlSource stringByAppendingString: [_webView stringByEvaluatingJavaScriptFromString:jsToGetHtmlSource]];
    _htmlSource = [_htmlSource stringByAppendingString:@"</html>"];
    //根据summaryid 和templateid查询数据库更换html_code
    //在details表中 根据detailsid 修改html代码
    
    [DBDaoHelper updateDetailsIdWith:self.editNowDetailsIdStr htmlCode:_htmlSource];
    NSLog(@"you got html is:::%@", _htmlSource);
}
-(void)loadHtmlToWebView{
    
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    context[@"clickedText"] = ^() {
        NSLog(@"%ld",(long)self.webView.tag);
        NSLog(@"Begin text");
        NSArray *args = [JSContext currentArguments];
        
        //        NSString *mySt = [args componentsJoinedByString:@","];
        NSLog(@"input mySt:%@", args[0]);
        NSLog(@"input mySt:%@", args[1]);
        NSString *htmlVal = [[NSString alloc]initWithFormat:@"%@",args[0]];
        NSString *htmlIndex =[[NSString alloc]initWithFormat:@"%@",args[1]];
        [self editTextComponent:htmlVal :htmlIndex];
        
        NSLog(@"-------End Text-------");
        
    };
    //点击图片js方法调用native
    context[@"clickedImage"] = ^() {
        NSLog(@"Begin image");
        
        NSArray *args = [JSContext currentArguments];
        
        NSLog(@"input mySt:%@", args[0]);
        _imgIndex = [[NSString alloc]initWithFormat:@"%@",args[0]];
        //[self editImageComponent:_fullPath :_imgIndex];
        //        [self editImageComponent: @"/Users/linlecui/Desktop/10c58PIC2CK_1024.jpg" : imgIndex];//加载本地图片到webview,把图片的索引传给方法
        [self backgroundClick];
        
        NSLog(@"-------End Image-------");
    };
    
}
//修改文字的时候
-(void)editTextComponent:(NSString *)param1 : (NSString *)param2{
    
    _editTextViewControl = [[UIControl alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
    _editTextViewControl.backgroundColor = [UIColor grayColor];
    
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.frame = CGRectMake(20, 20, KScreenWidth, 30);
    titleLabel.text = @"Please type your word:";
    [_editTextViewControl addSubview:titleLabel];
    
    UITextView *txtView = [[UITextView alloc]initWithFrame:CGRectMake(20, 60, KScreenWidth-40, KScreenHeight *0.25)];
   // txtView.delegate = self;
    txtView.backgroundColor = [UIColor whiteColor];
    NSString *textStr = [param1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  //  [txtView setText: textStr];
    
    [_editTextViewControl addSubview:txtView];
    
    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeSystem];
    okButton.frame = CGRectMake(20 , 30 + KScreenHeight*0.25 + 40, KScreenWidth-40, 40);
    [okButton setTitle:@"OK" forState:UIControlStateNormal];
    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    okButton.backgroundColor = [UIColor darkGrayColor];
    okButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [okButton.layer setMasksToBounds:YES];
    
    [okButton.layer setBorderWidth:1.0];
    [okButton.layer setCornerRadius:7.0];
    okButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [_editTextViewControl addSubview:okButton];
    
    
    [self.view addSubview:_editTextViewControl];
    //[self.view bringSubviewToFront:_editTextViewControl];
    
//    UITextView *txtView = [[UITextView alloc]initWithFrame:CGRectMake(20, 160, 200, 300)];
//  
//    txtView.delegate = self;
//    txtView.backgroundColor = [UIColor whiteColor];
//   
//    NSString *textStr = [param1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    //txtView.text=@"ss";
//    [_editTextViewControl addSubview:txtView];
//     [txtView becomeFirstResponder];
//    // 点击OK按钮，保存到summary表中，并返回最大的主键。
//    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    okButton.frame = CGRectMake(20 , 30 + KScreenHeight*0.25 + 40, KScreenWidth-40, 40);
//    [okButton setTitle:@"OK" forState:UIControlStateNormal];
//    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    okButton.backgroundColor = [UIColor darkGrayColor];
//    okButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
//    [okButton.layer setMasksToBounds:YES];
//    
//    [okButton.layer setBorderWidth:1.0];
//    [okButton.layer setCornerRadius:7.0];
//    okButton.layer.borderColor = [UIColor whiteColor].CGColor;
//    [_editTextViewControl addSubview:okButton];
//    
//    [okButton addTarget:self action:@selector(saveSummaryTile) forControlEvents:UIControlEventTouchUpInside];
    
    
    

    
    
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Message Alert" message:@"" preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
//        
//        textField.placeholder = @"please type your message";
//        
//        textField.text = param1;
//        
//    }];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
//    
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        // NSString *getTextMessage = textField.text;
//        UITextField *login = alertController.textFields.firstObject;
//        NSString *newMessage = login.text;
//        NSString *str = @"var field = document.getElementsByClassName('text_element')[";
//        str = [str stringByAppendingString:param2];
//        str = [str stringByAppendingString:@"];"];
//        str = [str stringByAppendingString:@" field.innerHTML='"];
//        str = [str stringByAppendingString:newMessage];
//        str = [str stringByAppendingString:@"';"];
//        
//        NSLog(@"final javascript:%@",str);
//        [_webView stringByEvaluatingJavaScriptFromString:str];
//        [self getHtmlCodeClick];//获取webview中section里的heml代码
//        
//    }];
//    
//    
//    [alertController addAction:cancelAction];
//    [alertController addAction:okAction];
//    
//    [self presentViewController:alertController animated:YES completion:nil];
}
//更改图片
-(void)editImageComponent:(NSString *)imgName : (NSString *)index{
    
    //拼接js字符串，用于替换图片
    NSString *str = @"var field = document.getElementsByClassName('img_element')[";
    str = [str stringByAppendingString:index];
    str = [str stringByAppendingString:@"];"];
    str = [str stringByAppendingString:@" field.src='"];
    str = [str stringByAppendingString:imgName];
    str = [str stringByAppendingString:@"';"];
    
    NSLog(@"final javascript:%@",str);
    [_webView stringByEvaluatingJavaScriptFromString:str];//js字符串通过这个方法传递到webview中的html并执行此js
     [self getHtmlCodeClick];
}
//选择图片
-(void)backgroundClick
{
    UIActionSheet *sheet;
    
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册选择", nil];
    }
    else {
        
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
    }
    
    sheet.tag = 255;
    
    [sheet showInView:self.view];
}
-(void)recordClick
{
    
}
#pragma mark - 保存图片至沙盒
- (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    // 获取沙盒目录
    
    _fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    NSLog(@"%@",_fullPath);
//    [self loadHtmlToWebView];
   
     // 将图片写入文件
    [imageData writeToFile:_fullPath atomically:NO];
    
   
     NSLog(@"_imgIndex_imgIndex:::%@",_imgIndex);
    [self editImageComponent:_fullPath :_imgIndex];
}
#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    NSString *str = [NSString stringWithFormat:@"%d.png",arc4random() % 1000000];
    [self saveImage:image withName:str];
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"currentImage.png"];
    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
    
    
    isFullScreen = NO;
    [self.imageView setImage:savedImage];
    
    self.imageView.tag = 100;
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}
#pragma mark - actionsheet delegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        
        NSUInteger sourceType = 0;
        
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            switch (buttonIndex) {
                case 0:
                    // 取消
                    return;
                case 1:
                    // 相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                    
                case 2:
                    // 相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
            }
        }
        else {
            if (buttonIndex == 0) {
                
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        
        imagePickerController.delegate = self;
        
        imagePickerController.allowsEditing = YES;
        
        imagePickerController.sourceType = sourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }
}

// 把录好的音频，通过native 代码调用js文件，替换当前的
-(void)editAudioComponent{
    NSString *str = @"var field = document.getElementById('audioPlayer');";
    str = [str stringByAppendingString:@" field.src='"];
    str = [str stringByAppendingString:_audioPath];
    str = [str stringByAppendingString:@"'; field.play();"];
    NSLog(@"final javascript:%@",str);
    [_webView stringByEvaluatingJavaScriptFromString:str];
    
    [self getHtmlCodeClick];
}


#pragma mark - 私有方法 - 录音相关方法 -----------------------------
/**
 *  设置音频会话
 */
-(void)setAudioSession{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    
}

/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
-(NSURL *)getSavePath{
    
//    NSString *audioName = [NSString stringWithFormat:@"%d.wav",arc4random() % 1000000];
    NSString *audioName1 = @"myAudio.wav";
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    urlStr=[urlStr stringByAppendingPathComponent:audioName1];
    _audioPath = urlStr;
    NSLog(@"file path:%@",urlStr);
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}

/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
-(AVAudioRecorder *)audioRecorder{
    //创建录音文件保存路径
    NSURL *url=[self getSavePath];
    if (!_audioRecorder) {
       
        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate=self;
        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

/**
 *  创建播放器
 *
 *  @return 播放器
 */
-(AVAudioPlayer *)audioPlayer{
    NSURL *url = [self getSavePath];
    if (!_audioPlayer) {
       
        NSError *error=nil;
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        
        _audioPlayer.numberOfLoops=0;
        [_audioPlayer prepareToPlay];
        if (error) {
            NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}

/**
 *  录音声波监控定制器
 *
 *  @return 定时器
 */
-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _timer;
}

/**
 *  录音声波状态设置
 */
-(void)audioPowerChange{
    [self.audioRecorder updateMeters];//更新测量值
    float power= [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
    CGFloat progress=(1.0/160.0)*(power+160.0);
    [self.audioPower setProgress:progress];
}

#pragma mark - 录音机代理方法
/**
 *  录音完成，录音完成后播放录音
 *
 *  @param recorder 录音机对象
 *  @param flag     是否成功
 */
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if (![self.audioPlayer isPlaying]) {
        [self.audioPlayer play];
        
    }
    NSLog(@"录音完成!");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
