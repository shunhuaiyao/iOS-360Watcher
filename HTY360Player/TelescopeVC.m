//
//  TelescopeVC.m
//  360Project
//
//  Created by Rachel Yeh on 2016/12/12.
//  Copyright © 2016年 Hanton. All rights reserved.
//

#import "TelescopeVC.h"
#import "IntercomVC.h"
#import "EarthVC.h"
#import "ExtAudioConverter.h"
#import "HTY360PlayerVC.h"
#import "NaviVC.h"
#import "ApiManager.h"
#import "JsonRetriever.h"
#import "MoodEvaluater.h"
#import "btRippleButtton.h"
#import "QuartzCore/QuartzCore.h"

@interface TelescopeVC () <UIScrollViewDelegate, AVAudioRecorderDelegate>
{
    AVAudioPlayer *_myAudioPlayer;
    HTY360PlayerVC *_videoController;
    AVAudioRecorder *_recorder;
    AVAudioSession *_session;
    
    MoodEvaluater *_moodEvaluater;
    JsonRetriever *_jsonRetriever;
    int _httpSession;
    
    NSTimer *_timer;    //錄音進度條的控制
    NSTimer *_timer2; //控制探索按鈕自轉，令loading時長達5秒
    NSTimer *_timer3; //控制探索按鈕閃爍（按下之前）
    NSTimer *_timer4; //控制探索按鈕閃爍（按下之後，會發光）
    NSTimer *_meterTimer; //repeat calling updateAudioMeter
    BTRippleButtton *rippleButton1;
    
    UISwipeGestureRecognizer *_downSwiper;//滑動手勢控制
    
    int _currentMoodNum;
    int _progressValue;
    BOOL fileBeingSent;
    BOOL exploring;
    BOOL _spinning;
    BOOL secondRecord;
    float _dbLevel;
    BOOL locked; //防止api二次呼叫，造成多重取用影片
    int calledCount;
    NSString *_distributedType;
    NSString *_distributedVideoID;
    NSDictionary *_distributedVideoInfo;
    NSString *_moodGroup;
}
@end

@implementation TelescopeVC

- (void)viewDidLoad {
    [super viewDidLoad];

    _maskView.hidden=YES;
    _progressView.hidden=YES;
    _microBlingView.alpha=0.2;
    
    _moodEvaluater=[[MoodEvaluater alloc]init];
    _jsonRetriever=[[JsonRetriever alloc]init];
    _jsonRetriever.delegate=self;
    
    [self scrollSetting];
    [self audioSetting];
    [self hintLabelTapSetting];
    
    //處理提示標籤
    _hintLabel.tag=5;
    _hintLabel.text=@"選擇一個你喜歡的頻率，透過聲音找回世界的記憶吧！";
    _hintLabel.userInteractionEnabled=YES;
    _triangleView.hidden=NO;
    [self triangleBling];
    
    // init ripple button
    rippleButton1 = [[BTRippleButtton alloc]initWithImage:[UIImage imageNamed:nil] andFrame:CGRectMake(_microBtn.frame.origin.x + _microBtn.frame.size.width/2 - 75/2, _microBtn.frame.origin.y, 75, 75) andTarget:nil andID:self];
    [rippleButton1 setRippeEffectEnabled:YES];
    [rippleButton1 setRippleEffectWithColor:[UIColor colorWithRed:255/255.f green:255/255.f blue:255/255.f alpha:1]];
    [self.view addSubview:rippleButton1];
    [self.view bringSubviewToFront:_microBtn];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [_myAudioPlayer stop];
}

-(void) viewWillAppear:(BOOL)animated
{
    //淡出提示
    _hintLabel.alpha=0;
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ _hintLabel.alpha=1;}
                     completion:^(BOOL finished){
                         if(finished){
                             _hintLabel.alpha=1;
                         }}];
    
    _timer3=[NSTimer scheduledTimerWithTimeInterval:2.2 target:self selector:@selector(decideIntervalByTimer:) userInfo:nil repeats:YES];
    
    locked=NO; //重置鎖
}

# pragma mark - 六大情緒類：背景圖及音樂設定

-(void) audioSetting
{
    //音樂播放設定
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/tender.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    _myAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    _myAudioPlayer.numberOfLoops = -1; //Infinite
    
    [_myAudioPlayer play];
}

-(NSString *) getMoodStr: (int) moodNum
{
    NSString *moodStr=[[NSString alloc]init];
    
    //根據標號得知情緒
    switch (moodNum) {
        case 0:
            moodStr=@"tender";
            break;
            
        case 1:
            moodStr=@"irritated";
            break;
            
        case 2:
            moodStr=@"peaceful";
            break;
            
        case 3:
            moodStr=@"confused";
            break;
            
        case 4:
            moodStr=@"depressed";
            break;
            
        case 5:
            moodStr=@"struggled";
            break;
    }
    
    return moodStr;
}

-(void) setCurrentMood:(int)moodNum
{
    //切換音樂
    [_myAudioPlayer stop];
    
    //設定現在選中的情緒
    _currentMoodNum=moodNum;
    
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/%@.mp3", [[NSBundle mainBundle] resourcePath],[self getMoodStr:moodNum]];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    _myAudioPlayer = [_myAudioPlayer initWithContentsOfURL:soundFileURL error:nil];
    _myAudioPlayer.numberOfLoops = -1; //Infinite
    [_myAudioPlayer play];
}

# pragma mark - 左右滑動控制

-(void) scrollSetting
{
    //獲取螢幕長寬
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    //將圖片依序加入sliderView
    for(int i=0; i<=5 ; i++)
    {
        //獲取圖片
        UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:[self getMoodStr:i]]];
        
        //將圖片加至slider裡
        imageView.frame=CGRectMake(screenWidth*i, 0, screenWidth, screenHeight);
        [_sliderView addSubview:imageView];
    }
    
    //UIScrollView設定
    [_sliderView setContentSize:CGSizeMake(screenWidth*6,screenHeight)];
    [_sliderView setPagingEnabled:YES];
    [_sliderView setShowsHorizontalScrollIndicator:NO];
    [_sliderView setBounces:NO];
    _sliderView.delegate=self;
    
    //[self downSwipeSetting];
    
    _sliderView.scrollEnabled = NO;
    
}

-(void) calculatePageByOffset
{
    //依據目前捲動量來換算出頁數
    CGFloat width = _sliderView.frame.size.width;
    int currentMoodNum = ((_sliderView.contentOffset.x - width / 2) / width) + 1;
    [self setCurrentMood:currentMoodNum];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView  //當使用者進行滑動時呼叫此函式
{
    [self calculatePageByOffset];
}

-(void) downSwipeSetting
{
    //前往上
    _downSwiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [_downSwiper setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self.view addGestureRecognizer:_downSwiper];
}

-(void)swipeHandler:(UISwipeGestureRecognizer *)swiper
{
    [self gotoEarth];
}

- (IBAction)tappedDownBtn:(id)sender
{
    [self gotoEarth];
}

- (IBAction)tappedLeftBtn:(id)sender
{
    if(_sliderView.contentOffset.x>0)
    {
        [UIView animateWithDuration:0.7 animations:^{
            _sliderView.contentOffset=CGPointMake(_sliderView.contentOffset.x-_sliderView.frame.size.width, 0);
        }];
    }
    [self calculatePageByOffset];
}

- (IBAction)tappedRightBtn:(id)sender
{
    if(_sliderView.contentOffset.x<_sliderView.frame.size.width*5)
    {
        [UIView animateWithDuration:0.7 animations:^{
            _sliderView.contentOffset=CGPointMake(_sliderView.contentOffset.x+_sliderView.frame.size.width, 0);
        }];
    }
    [self calculatePageByOffset];
}

- (IBAction)tappedExploreBtn:(id)sender {
    
}

- (IBAction)tappedMemoryBtn:(id)sender {
    EarthVC *earthVC=[[EarthVC alloc] initWithNibName:@"EarthVC" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:earthVC animated:NO];
}

- (IBAction)tappedMessageBtn:(id)sender {
    IntercomVC *intercomVC=[[IntercomVC alloc] initWithNibName:@"IntercomVC" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:intercomVC animated:NO];
}

-(void) gotoEarth
{
    NaviVC *naviVC=self.navigationController;
    [naviVC popToRootViewControllerAnimated:NO];
}

# pragma mark - 探索按鈕閃爍效果

-(void) decideIntervalByTimer: (NSTimer *)timer
{
    if([timer isEqual:_timer3])
        [self strongerEffectWithDuration:0.7 andAlpha:0.2]; //閃爍較慢，時間區間為0.7
    else if([timer isEqual:_timer4])
        [self strongerEffectWithDuration:0.3 andAlpha:0.6]; //閃爍較快，時間區間為0.5
}

-(void) strongerEffectWithDuration:(CGFloat)second andAlpha:(CGFloat) alpha
{
    //透明度變化
    _microBlingView.alpha=alpha;
    [UIView animateWithDuration:second delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ _microBlingView.alpha = 1;}
                     completion:^(BOOL finished){
                         if(finished){
                             _microBlingView.alpha = 1;
                             [self stayingEffectWithDuration:second andAlpha:alpha];
                         }}];
}

-(void) stayingEffectWithDuration:(CGFloat)second andAlpha:(CGFloat) alpha
{
    //透明度變化
    [UIView animateWithDuration:second-0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ _microBlingView.alpha = 1;}
                     completion:^(BOOL finished){
                         if(finished){
                             [self lighterEffectWithDuration:second andAlpha:alpha];
                         }}];
}

-(void) lighterEffectWithDuration:(CGFloat)second andAlpha:(CGFloat) alpha
{
    //透明度變化
    _microBlingView.alpha=1;
    [UIView animateWithDuration:second delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ _microBlingView.alpha = alpha;}
                     completion:^(BOOL finished){
                         if(finished){
                             _microBlingView.alpha = alpha;
                         }}];
}

/*-(void) updateLabel
 {
 //淡出效果
 [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseIn
 animations:^{ _hintLabel.alpha = 0;}
 completion:^(BOOL finished){
 if(finished){
 _hintLabel.alpha = 0;
 }}];
 
 //交替切換提示
 if([_hintLabel.text isEqualToString:@"左右滑動，選擇聯結地球的音訊頻率"])
 _hintLabel.text=@"按下麥克風，請對著裝置說出 HELLO WORLD";
 else if([_hintLabel.text isEqualToString:@"按下麥克風，請對著裝置說出 HELLO WORLD"])
 _hintLabel.text=@"左右滑動，選擇聯結地球的音訊頻率";
 
 //淡入效果
 [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseIn
 animations:^{ _hintLabel.alpha = 1;}
 completion:^(BOOL finished){
 if(finished){
 _hintLabel.alpha = 1;
 }}];
 }*/


# pragma mark - 錄音控制相關

- (IBAction)tappedMicrophone:(id)sender
{
    [_timer3 invalidate];
    _timer3=nil;
    
    //提示更換
    _hintLabel.userInteractionEnabled=NO;
    [_triangleView stopAnimating];
    _triangleView.hidden=YES;
    _hintLabel.text=@"  出聲抒發自己的心情，引起傳播頻率的共振！";
    
    //view變更與控制
    _sliderView.scrollEnabled=NO;
    _microBtn.enabled=NO;
    _microBtn.hidden=YES;
    
    //閃爍效果
    _microBlingView.alpha=1;
    _microBlingView.image=[UIImage imageNamed:@"explore_shine"];
    _timer4=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(decideIntervalByTimer:) userInfo:nil repeats:YES];

    //錄音設定
    [_myAudioPlayer stop];
    [self recordSetting];
    [_recorder record]; //開始錄音
    [_recorder setMeteringEnabled:YES]; // for audio level metering
    [self startAudioMetering];
    
    //更新進度條
    _progressView.hidden=NO;
    _timer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}

// repeat calling updateAudioMeter
- (void)startAudioMetering {
    _meterTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateAudioMeter)userInfo:nil repeats:YES];
}

- (void)stopAudioMetering {
    [_meterTimer invalidate];
}

- (void)updateAudioMeter {
// audioRecorder being your instance of AVAudioRecorder
    [_recorder updateMeters];
    _dbLevel = [_recorder averagePowerForChannel:0];
    NSLog(@"dB: %f\n", _dbLevel);
    if (_dbLevel > -20) {
        [rippleButton1 handleTap:nil];
    }

}

-(void) updateProgress
{
    _microBlingView.alpha=1;
    _microBlingView.image=[UIImage imageNamed:@"explore_shine"];
    
    if (_progressView.progress < 1.0) {
        _progressView.progress = _progressView.progress + 0.07;
    }
    else {
        _progressView.progress=1.0;
        [self finishRecord];
    }
}

-(void) noMoreVideo
{
    //停止動畫
    [_roundView stopAnimating];
    [_timer4 invalidate];
    _timer4=nil;
    _microBlingView.image=[UIImage imageNamed:@"explore_40"];
    
    //外框重新出現
    _maskView.alpha=0;
    _maskView.hidden=NO;
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ _maskView.alpha = 1;
                     _frameView.alpha = 1;}
                     completion:^(BOOL finished){
                         if(finished){
                             _frameView.alpha = 1;
                             _maskView.alpha = 1;
                             _hintLabel.hidden=NO;
                             _hintLabel.text=@"這個頻率閘門被關閉接不上了.....";
                             _hintLabel.tag=3;
                             _hintLabel.userInteractionEnabled=YES;
                             [self triangleBling];
                         }}];
}

-(void) recordFail
{
    //外框重新出現
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ _frameView.alpha = 1;}
                     completion:^(BOOL finished){
                         if(finished){
                             _frameView.alpha = 1;
                             _hintLabel.hidden=NO;
                             _hintLabel.text=@"......真可惜，似乎沒有成功捕捉到記憶";
                             _hintLabel.tag=1;
                             _hintLabel.userInteractionEnabled=YES;
                             [self triangleBling];
                         }}];
}

-(void) finishRecord
{
    //錄音完畢
    [_timer invalidate];
    _timer = nil;
    [_recorder stop];
    [self stopAudioMetering];
    
    //旋轉效果
    _spinning=YES;
    [self spinEffect];
    [self roundRipple];
    
    //view變更
    _progressView.hidden=YES;
    _hintLabel.hidden=YES;
    _roundView.image=[UIImage imageNamed:@"round_shine"]; //強化圓框
    
    //外框淡化消失
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ _frameView.alpha = 0;
                         _downBtn.alpha=0;
                     _rightBtn.alpha=0;
                     _leftBtn.alpha=0;}
                     completion:^(BOOL finished){
                         if(finished){
                             _frameView.alpha = 0;
                             _downBtn.hidden=YES;
                             _rightBtn.hidden=YES;
                             _leftBtn.hidden=YES;
                         }}];
    
    //若為第二次錄音，將進行解鎖
    if(secondRecord)
        locked=NO;
    
    //轉換成wav音檔，並利用API分析情緒
    [self audioConverter];
    [self emotionAnalysis];
}


- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    NSLog(@"finished");
}

# pragma mark - 動畫效果

-(void) dialogShowEffect
{
    //對話切換的間隔，使文字及三角形有重新顯示的效果
    _hintLabel.alpha=0;
    _triangleView.alpha=0;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ _hintLabel.alpha=1;
                         _triangleView.alpha=1;}
                     completion:^(BOOL finished){
                         if(finished){
                             _hintLabel.alpha=1;
                             _triangleView.alpha=1;
                         }}];
}

-(void) hintLabelTapSetting
{
    UITapGestureRecognizer *hintTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedHintLabel)];
    hintTap.numberOfTapsRequired = 1;
    [self.hintLabel addGestureRecognizer:hintTap];
    
    //_hintLabel.userInteractionEnabled=NO; //先關閉互動
    //_triangleView.hidden=YES; //隱藏三角形
}

-(void) tappedHintLabel
{
    //顯示下一句話
    switch (_hintLabel.tag)
    {
        case 1:   //錄音失敗時
        {
            _hintLabel.tag=2;
            _hintLabel.text=@"為了讓記憶情感凝聚在一起，再試著多說一點話吧！";
            [self dialogShowEffect];
            break;
        }
        case 2:   //下一步重新錄音
        {
            _hintLabel.userInteractionEnabled=NO;
            [_triangleView stopAnimating];
            _triangleView.hidden=YES;
        
            //提示更換
            _hintLabel.text=@"  出聲抒發自己的心情，引起傳播頻率的共振！";
        
            //停止旋轉與漣漪，
            _spinning=NO;
            [_roundView stopAnimating];
            [_triangleView stopAnimating];
            _triangleView.hidden=YES;
        
            //圓框閃爍效果
            _microBlingView.alpha=1;
            _microBlingView.image=[UIImage imageNamed:@"explore_shine"];
            _timer4=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(decideIntervalByTimer:) userInfo:nil repeats:YES];
        
            [self recordSetting];
            [_recorder record]; //開始錄音
            [_recorder setMeteringEnabled:YES]; // for audio level metering
            [self startAudioMetering];

        
            //更新進度條
            _progressView.progress=0;
            _progressView.hidden=NO;
            _timer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
            break;
        }
        case 3:   //沒影片可提供時
        {
            //提示更換
            _hintLabel.tag=4;
            _hintLabel.text=@".....沒關係，我們下次再試試吧！別氣餒！";
            [self dialogShowEffect];
            break;
        }
        case 4: //返回首頁
        {
            [_triangleView stopAnimating];
            _triangleView.hidden=YES;
            [self gotoEarth];
            break;
        }
        case 5: //初始話語下句
        {
            _hintLabel.userInteractionEnabled=NO;
            [_triangleView stopAnimating];
            _triangleView.hidden=YES;
            
            //提示更換
            _hintLabel.text=@"點擊中央的記憶探索之鑰，在時間內說說話";
            [self dialogShowEffect];
            break;
        }
    }
}

-(void) triangleBling
{
    _triangleView.hidden=NO;
    
    NSArray *animationArray = [NSArray arrayWithObjects:
                               [UIImage imageNamed:@"triangle_25"],
                               [UIImage imageNamed:@"triangle_75"],
                               nil];
    _triangleView.animationImages      = animationArray;
    _triangleView.animationDuration    = 1;
    _triangleView.animationRepeatCount = 0;
    [_triangleView startAnimating];
}

-(void) spinEffect
{
    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [_microBlingView setTransform:CGAffineTransformRotate(_microBlingView.transform, M_PI_2)];
    } completion:^(BOOL finished) {
        if (finished && !CGAffineTransformEqualToTransform(_microBlingView.transform, CGAffineTransformIdentity)) {
            if(_spinning)
                [self spinEffect];
        }
    }];
}

/*-(void) microphoneBling
{
    NSArray *animationArray = [NSArray arrayWithObjects:
                               [UIImage imageNamed:@"explore_40"],
                               [UIImage imageNamed:@"explore_100"],
                               [UIImage imageNamed:@"explore_40"],
                               nil];
    _microBlingView.animationImages      = animationArray;
    _microBlingView.animationDuration    = 0.3;
    _microBlingView.animationRepeatCount = 0;
    [_microBlingView startAnimating];
}*/

-(void) roundRipple
{
    NSArray *animationArray = [NSArray arrayWithObjects:
                               [UIImage imageNamed:@"ripple1"],
                               [UIImage imageNamed:@"ripple2"],
                               [UIImage imageNamed:@"ripple3"],
                               [UIImage imageNamed:@"ripple4"],
                               [UIImage imageNamed:@"ripple5"],
                               nil];
    _roundView.animationImages      = animationArray;
    _roundView.animationDuration    = 1.5;
    _roundView.animationRepeatCount = 0;
    [_roundView startAnimating];
}

/*-(void) loadingDot
{
    if([_loadLabel.text isEqualToString:@""])
        _loadLabel.text=@"Loading";
    else if([_loadLabel.text isEqualToString:@"Loading"])
        _loadLabel.text=@"Loading.";
    else if([_loadLabel.text isEqualToString:@"Loading."])
        _loadLabel.text=@"Loading..";
    else if([_loadLabel.text isEqualToString:@"Loading.."])
        _loadLabel.text=@"Loading...";
    else if([_loadLabel.text isEqualToString:@"Loading..."])
        _loadLabel.text=@"";
}*/

# pragma mark - 音檔處理及轉檔

-(void) recordSetting
{
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:@"sound.caf"];
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    NSDictionary *recordSettings = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityHigh],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 1],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:11025],
                                    AVSampleRateKey,
                                    nil];
    
    NSError *error = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                        error:nil];
    
    _recorder = [[AVAudioRecorder alloc]
                 initWithURL:soundFileURL
                 settings:recordSettings
                 error:&error];
    
    if (error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        [_recorder prepareToRecord];
    }
}

-(void) audioConverter
{
    NSArray *dirPaths;
    NSString *docsDir;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"sound.caf"];
    NSString *outputFilePath = [docsDir stringByAppendingPathComponent:@"output.wav"];
    
    ExtAudioConverter *converter = [[ExtAudioConverter alloc] init];
    converter.inputFile = soundFilePath;
    converter.outputFile = outputFilePath;
    
    converter.outputSampleRate = 11025;
    converter.outputNumberChannels = 1;
    converter.outputBitDepth = BitDepth_16;
    converter.outputFormatID = kAudioFormatLinearPCM;
    converter.outputFileType = kAudioFileWAVEType;
    
    if([converter convert])
        [self emotionAnalysis];
    else
    {
        NSLog(@"try again");
    }
}

# pragma mark - API情緒識別

-(void) emotionAnalysis
{
    //取得錄音二元資料
    NSArray *dirPaths;
    NSString *docsDir;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    NSString *outputFilePath = [docsDir stringByAppendingPathComponent:@"output.wav"];
    
    //使用官方提供之程式碼，經ApiManager傳送音檔給BeyondVerbal
    
    // 1. Call getAccessToken
    [[ApiManager sharedManager] getAccessTokenSuccess:^(NSData *data) {
        
        // When successful:
        // 2. Call startSession
        [[ApiManager sharedManager] startSessionSuccess:^(NSData *data) {
            
            // When successful:
            // BOOL fileBeingSent is used to stop sending Analysis requests after send file is finished
            fileBeingSent = YES;
            
            // 3. Call sendAudioFile with sample.wav
            [[ApiManager sharedManager] sendAudioFile:outputFilePath fileType:@"wav" success:^(NSData *data)
            {
                fileBeingSent = NO;
                
                if(!locked)
                {
                    locked=YES; //一旦進入便設置為鎖起狀態
                    
                    //從回傳結果中得知user所處情緒id
                    id jsonObj=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                    NSNumber *idNum=[[[[[[[[(NSDictionary *)jsonObj objectForKey:@"result"] objectForKey:@"analysisSegments"]objectAtIndex:0] objectForKey:@"analysis"] objectForKey:@"Mood"] objectForKey:@"Group11"] objectForKey:@"Primary"] objectForKey:@"Id"];
                
                    if([idNum isEqual:[NSNull null]] || !idNum)
                    {
                        NSLog(@"沒能錄好，請做其他處置");
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //locked=NO; //解鎖
                            secondRecord=YES;
                            [self recordFail];//錄音失敗
                        });
                    }
                    else
                    {
                        //查閱plist，找出此id的對應群組
                        NSLog(@"id:%@",idNum);
                        NSArray *moodArray= [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"group11_mood" ofType:@"plist"]];
                    
                        _moodGroup=[NSString string];
                        for(NSDictionary *dict in moodArray){
                            if([[dict objectForKey:@"Id"]intValue]==[idNum intValue]){
                                _moodGroup=[dict objectForKey:@"Group"];
                                break;
                            }
                        }
                        //計算找出下一部應播放之影片類型
                        _distributedType=[NSString stringWithString:[_moodEvaluater getNextVideoAccordingToMoodRecord:_moodGroup]];
                    
                        //檢查該影片類別所有的影片數量是否足夠
                        _httpSession=0;
                        [_jsonRetriever httpGetMethodByURL:[NSString stringWithFormat:@"http://52.185.155.19/watchtower/currentVideoCount.php?VideoType=%@",_distributedType]];
                    }
                }
            }];
            
            // 4. Call sendForAnalysis for the 1st time after 3 seconds
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(sendForAnalysis) withObject:nil afterDelay:3];
            });
        }];
    }];
}

-(void)sendForAnalysis
{
    if(fileBeingSent == YES)
    {
        NSLog(@"getAnalysis started");
            
        [[ApiManager sharedManager] getAnalysisFromMs:[NSNumber numberWithLong:0] success:^(NSData *data)
        {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"getAnalysis responseDictionary:\n%@",responseDictionary);
            
        }];
    }
}

-(void)getJsonData:(id)jsonObject
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"jsonobj:%@",jsonObject);
        
        if(_httpSession==0)
        {
            //獲取該類別的影片數量
            NSNumber *amount=(NSNumber *)jsonObject;
            NSLog(@"amount:%@",amount);
            
            //查看線上影片數量是否還足夠
            if([_moodEvaluater checkIfVideoAmountIsEnough:[amount intValue] withType:_distributedType])
            {
                //足夠則將進一步分配影片
                _httpSession=1;
                [_jsonRetriever httpGetMethodByURL:[NSString stringWithFormat:@"http://52.185.155.19/watchtower/getRandomVideo.php?VideoType=%@",_distributedType]];
            }
            else
            {
                NSLog(@"沒影片了，請做其他處置");
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self noMoreVideo];//沒影片可提供了
                });
            }
        }
        else if(_httpSession==1)
        {
            //隨機獲取影片，去比較是否已看過此影片
            NSDictionary *dict=(NSDictionary *)jsonObject;
            if([_moodEvaluater checkIfAlreadySeenVideoId:[dict objectForKey:@"ID"] withType:_distributedType]){
                //已看過則重新搜尋影片
                _httpSession=1;
                [_jsonRetriever httpGetMethodByURL:[NSString stringWithFormat:@"http://52.185.155.19/watchtower/getRandomVideo.php?VideoType=%@",_distributedType]];
            } else {
                
                //沒看過則確定將播放此影片
                //a.把影片資訊存給下一個控制器，當判定完觀看狀態會再一併存去VideoRecord
                //[_moodEvaluater storeVideoInfo:dict withType:_distributedType];
                _distributedVideoInfo=[NSDictionary dictionaryWithDictionary:dict];
                _distributedVideoID=[dict objectForKey:@"ID"];
                
                //b.準備放映影片
                [self launchVideoWithURL:[dict objectForKey:@"VideoURL"]];
            }
        }
    });
}

# pragma mark - 影片放映

- (void)launchVideoWithURL:(NSString*)videoURL
{
    NSURL *url = [[NSURL alloc] initWithString:videoURL];
    _videoController = [[HTY360PlayerVC alloc] initWithNibName:@"HTY360PlayerVC" bundle:nil url:url];
    
    //傳各種資訊給下一個控制器
    _videoController.onlyForBrowse=NO; //探索模式
    _videoController.currentMood=_moodGroup;
    _videoController.currentVideoInfo=[NSMutableDictionary dictionaryWithDictionary: _distributedVideoInfo];
    _videoController.currentType=_distributedType;
    
    //5秒後再開始播影片
    _timer2 =[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(switchToPlayVideo) userInfo:nil repeats:NO];
}

-(void) switchToPlayVideo
{
    [_roundView stopAnimating];
    [_timer2 invalidate];
    _timer2=nil;
    
    NaviVC *naviVC=self.navigationController;
    naviVC.pushDirection=1;
    [naviVC pushViewController:_videoController animated:NO];
}

# pragma mark - 其他

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) {
        self.view = nil;
    }
}

@end
