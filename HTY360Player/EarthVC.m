//
//  EarthVC.m
//  360Project
//
//  Created by Rachel Yeh on 2017/2/6.
//  Copyright © 2017年 Hanton. All rights reserved.
//

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "NaviVC.h"
#import "EarthVC.h"
#import "HTY360PlayerVC.h"
#import "TelescopeVC.h"
#import "IntercomVC.h"
#import "PlistAccessManager.h"
#import "MoodEvaluater.h"

@interface EarthVC () <UIScrollViewDelegate>
{
    UIButton *_tagBtn;
    UIImageView *_videoInfo;
    UIButton *_playBtn;
    
    //音樂播放相關
    BOOL _isPlayingMusic;
    AVAudioPlayer *_myAudioPlayer;
    
    //影片播放
    BOOL _tutorialIsPlaying;
    //MPMoviePlayerController *_theMoviePlayer;
    AVPlayer *avPlayer;
    AVPlayerItem *avPlayerItem;
    AVPlayerViewController *avPlayerVC;
    
    //360影片播放
    HTY360PlayerVC *_360Player;
    NSString *_chosenVideoId;
    NSString *_chosenVideoURL;
    NSTimer *_timer; //等一段時間給影片先加載
    
    //滑動手勢控制
    UISwipeGestureRecognizer *_rightSwiper;
    UISwipeGestureRecognizer *_upSwiper;
    
    //拼圖圖片控制相關
    NSMutableArray *_puzzleArray;
    int _selectedId;
    MoodEvaluater *_moodEvaluater;
    
    //音效相關
    SystemSoundID soundID;
    NSURL *_sound_url1;
    NSURL *_sound_url2;
    
    //UFO動畫相關
    CGRect ufo1Rect;
    CGRect ufo2Rect;
    CGRect ufo3Rect;
    CGRect ufo4Rect;
    UIImageView *_ufo1;
    UIImageView *_ufo2;
    UIImageView *_ufo3;
    UIImageView *_ufo4;
    BOOL _playingUFOAnimation;
    
    PlistAccessManager *_plistManager;
}
@end

@implementation EarthVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _plistManager=[[PlistAccessManager alloc]init];
    _chosenVideoId=[NSString string];
    _chosenVideoURL=[NSString string];
    
    self.scrollView.delegate=self;
    self.scrollView.minimumZoomScale=1.0;
    self.scrollView.maximumZoomScale=3.0;
    self.scrollView.contentSize = self.contentView.frame.size;
    self.scrollView.scrollEnabled=YES;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedTelescopeBtn)];
    singleTap.numberOfTapsRequired = 1;
    [self.thumbnailView setUserInteractionEnabled:NO];
    [self.thumbnailView addGestureRecognizer:singleTap];
    self.thumbnailView.hidden=YES;

    self.titleLabel.hidden=YES;
    self.locationLabel.hidden=YES;
    /*self.sup.hidden=YES;
    self.sdown.hidden=YES;
    self.sright.hidden=YES;
    self.sleft.hidden=YES;*/
    
    if(_playTutorialAtFirst)
    {   //第一次登入播放影片
        _tutorialIsPlaying=YES;
        [self loadOpeningAnimation];
    }
    else
    {
        _tutorialIsPlaying=NO;
    }
    
    [self loadBGM];
    [self swipeSetting];
    [self loadHintLabelSetting];
    [self loadMascotSetting];
    [self audioSetting];
    
    //self.scrollView.delaysContentTouches = NO;
    
    /*
    //新增標的位置
    _tagBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _tagBtn.frame=CGRectMake(335, 65, 15, 20);
    _tagBtn.enabled=YES;
    [_tagBtn setImage:[UIImage imageNamed:@"tag"] forState:UIControlStateNormal];
    [_tagBtn addTarget:self action:@selector(tagBtnHit) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_tagBtn];*/
}

-(void) viewWillAppear:(BOOL)animated
{
    //把既有拼圖刪掉，重新整理拼圖
    [self clearAllPuzzle];
    [self updatePuzzle];
    
    //隱藏詳細影片資訊，恢復瀏覽按鈕可互動
    self.thumbnailView.hidden=YES;
    self.titleLabel.hidden=YES;
    self.locationLabel.hidden=YES;
    
    if(!_isPlayingMusic && !_tutorialIsPlaying)
    {
        [_myAudioPlayer play];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"playBGM"];
        _isPlayingMusic=YES;
        _playingUFOAnimation=YES;
    }
    //[self ufo1Default];
    //[self floatingEffect];
    //[self slowRotate];
}

-(void) viewDidDisappear:(BOOL)animated
{
    //不讓UFO持續出現
    //_playingUFOAnimation=NO;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [_myAudioPlayer stop];
}


-(void) clearAllPuzzle
{
    //透過puzzleArray把現有的拼圖給移除
    for(NSDictionary *dict in _puzzleArray)
    {
        UIImageView *imageView=[dict objectForKey:@"puzzleView"];
        imageView.image=nil;
    }
    [_puzzleArray removeAllObjects];
}

-(void) loadMascotSetting
{
    _mascotView.userInteractionEnabled=YES;
    
    //加入長壓識別
    UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(resetVideoRecord)];
    [longPressGesture setMinimumPressDuration:5.0];
    [self.mascotView addGestureRecognizer:longPressGesture];
}

-(void) audioSetting
{
    //設定音檔位置
    _sound_url1 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tapPuzzle" ofType:@"mp3"]];
    _sound_url2 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tapArrow" ofType:@"mp3"]];
}

-(void) resetVideoRecord
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"reset puzzle");
    
        //清除videoRecord.plist的紀錄
        BOOL checkplist = [_plistManager saveAndCoverArray:[NSArray array] intoPlist:@"VideoRecord" underFolder:@"watchtower"];
        NSLog(@"check plist : %d",checkplist);
    
        //透過puzzleArray把現有的拼圖給移除
        [self clearAllPuzzle];
    });
}

-(void) updatePuzzle
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //從plist獲取影片紀錄
        NSArray *typeArray=[NSArray arrayWithArray:[_plistManager getRootArrayOfPlist:@"VideoRecord" underFolder:@"watchtower"]];
    
        //初始化puzzleArray
        _puzzleArray=[NSMutableArray array];
        _selectedId=-1; //初始值先設為負
    
        //找出影片類別為type的陣列
        for(NSDictionary *dict in typeArray)
        {
            NSArray *videoList=[dict objectForKey:@"videoList"];
            for(NSDictionary *dict2 in videoList)
            {
                //1. 加上隱形按鈕，計算對應的位置
                int i=[[dict2 objectForKey:@"PuzzleNum"]intValue];
                //計算x,y位置
                CGFloat x=_earthView.frame.origin.x+37+(i%13-1)*21.5; //由餘數來看橫排
                CGFloat y=_earthView.frame.origin.y+25+(i/13)*21; //由商數來看直列
            
                UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(x, y, 22, 21)];
                //UIImage *image=[UIImage imageNamed:@"helper"];
                //[button setImage:image forState:UIControlStateNormal];
                button.tag=i;
                [button addTarget:self.navigationController.parentViewController
                       action:@selector(detectWhichButtonIsTapped:)
             forControlEvents:UIControlEventTouchUpInside];
                [self.contentView addSubview:button];
            
                //2. 顯示拼圖：透過puzzleArray存下圖片
                //得知影片觀看狀態
                UIImage *image;
                if([[dict2 objectForKey:@"FinishStatus"]boolValue]){
                    //有看完，加載finished圖片
                    image=[UIImage imageNamed:[NSString stringWithFormat:@"finished_%03d.png",i]];
                }else{
                    //沒看完，加載unfinished圖片
                    image=[UIImage imageNamed:[NSString stringWithFormat:@"unfinished_%03d.png",i]];
                }
            
                //初始化並加入拼圖
                UIImageView *puzzleView=[[UIImageView alloc] initWithImage:image];
                puzzleView.frame=_earthView.frame;
                [self.contentView addSubview:puzzleView];
            
                //將圖片跟拼圖編號等資訊編輯成字典，存入陣列中
                NSMutableDictionary *tempDict=[NSMutableDictionary dictionary];
                [tempDict setObject:[NSNumber numberWithInt:i] forKey:@"puzzleId"];
                [tempDict setObject:puzzleView forKey:@"puzzleView"];
                [tempDict setObject:[dict2 objectForKey:@"FinishStatus"] forKey:@"status"];
                [_puzzleArray addObject:tempDict];
            }
        }
    });
}

-(void) loadHintLabelSetting
{
    //加入碰觸控制
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedHintLabel)];
    tap.numberOfTapsRequired = 1;
    [self.hintLabel addGestureRecognizer:tap];

    _hintLabel.tag=1;
    _hintLabel.text=@"歡迎回來，我一直在等你呢";
    _hintLabel.userInteractionEnabled=YES;
    
    //顯示三角形
    [self triangleBling];
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

-(void) tappedHintLabel
{
    //依序加載下一句
    switch (_hintLabel.tag)
    {
        case 1:
            _hintLabel.tag=2;
            _hintLabel.text=@"希望我們能找到更多回憶，讓渾沌的世界恢復原狀";
            [self dialogShowEffect];
            break;
            
        case 2:
            _hintLabel.tag=3;
            _hintLabel.text=@"不知道過去的世界是怎麼樣的呢……";
            [self dialogShowEffect];
            break;
            
        case 3:
            _hintLabel.tag=4;
            _hintLabel.text=@"⋯⋯⋯⋯";
            [self dialogShowEffect];
            break;
            
        case 4:
            _hintLabel.tag=5;
            _hintLabel.text=@"……今天想做點什麼呢？";
            [self dialogShowEffect];
            break;
        
        case 5:
            _hintLabel.tag=6;
            _hintLabel.text=@"你可以在這裡觀看已經收集到的記憶片段，\n或是往上滑重新尋找新的記憶";
            [self dialogShowEffect];
            break;
            
        case 6:
            _hintLabel.tag=7;
            _hintLabel.text=@"⋯⋯⋯⋯⋯";
            [self dialogShowEffect];
            break;
            
        case 7:
            _hintLabel.tag=8;
            _hintLabel.text=@"⋯⋯⋯⋯⋯⋯⋯⋯⋯";
            [self dialogShowEffect];
            //_hintLabel.userInteractionEnabled=NO;
            //[_triangleView stopAnimating];
            //_triangleView.hidden=YES;
            break;
        case 8:
            _hintLabel.tag=1;
            _hintLabel.text=@"歡迎回來，我一直在等你呢";
            [self dialogShowEffect];
            break;
    }
}

-(void)loadBGM
{
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/BGM.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    _myAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    _myAudioPlayer.numberOfLoops = -1; //Infinite
    _isPlayingMusic=NO;
}

-(void) loadOpeningAnimation
{
    //載入開頭動畫
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *moviePath = [bundle pathForResource:@"tutorial" ofType:@"mp4"];
    NSURL *movieURL = [NSURL fileURLWithPath:moviePath];

    
    avPlayerVC = [[AVPlayerViewController alloc]init];
    //avPlayerVC.showsPlaybackControls = NO;
    AVAsset *avAsset = [AVAsset assetWithURL:movieURL];
    avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
    avPlayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
    avPlayerVC.player = avPlayer;
    [avPlayer seekToTime:kCMTimeZero];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shutAnimation)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:avPlayerItem];
    [self addChildViewController:avPlayerVC];
    [self.view addSubview:avPlayerVC.view];
    avPlayerVC.view.frame = self.view.frame;
    [avPlayer play];
}

-(void) shutAnimation
{
    _tutorialIsPlaying=NO;
    [avPlayerVC dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:avPlayerItem];
    
    //淡出影片
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ avPlayerVC.view.alpha=0;}
                     completion:^(BOOL finished){
                         if(finished){
                             [avPlayerVC.view removeFromSuperview];
                             [avPlayerVC removeFromParentViewController];
                         }}];
    
    if(!_isPlayingMusic && !_tutorialIsPlaying)
    {
        [_myAudioPlayer play];
        _isPlayingMusic=YES;
        _playingUFOAnimation=YES;
    }
    
    //影片結束後，可以開始幽浮動畫
    [self ufoSetting];
    
}

#pragma mark - 星球按鈕測試

/*-(void) puzzleTest
{
    for(int i=0 ; i<=155 ; i++) //共有130張拼圖
    {
        UIImage *image=[UIImage imageNamed:[NSString stringWithFormat:@"finished_%03d.png",i]];
        if(image)
        {
            UIImageView *imageView=[[UIImageView alloc] initWithImage:image];
            imageView.frame=_earthView.frame;
            [self.contentView addSubview:imageView];
        }
    }
}

-(void) loadEarthAnimation
{
    //加載分格圖片
    NSMutableArray *addEarthImages = [[NSMutableArray alloc] init];
    
    for(int i=0 ; i<=155 ; i=i+1)
    {
        NSString *imageName=[NSString stringWithFormat:@"selected_%03d.png",i];
        UIImage *image = [UIImage imageNamed:imageName];
        
        if(image)
        {
            //NSLog(@"image:%@",imageName);
            [addEarthImages addObject:image];
        }
    }
    
    //透過地球按鈕圖片的改變製造動畫效果
    _earthView.animationImages = addEarthImages;
    _earthView.animationDuration = 100;
    _earthView.animationRepeatCount = 0;
    [_earthView startAnimating];
}


-(void) frameTest
{
    //地球面積為13*12的矩形排列而長，每一小格為長21單位，寬22單位（總長273，總寬264）
    for(int i=0 ; i<156 ; i++) //共有156個按鈕
    {
        //計算x,y位置
        CGFloat x=_earthView.frame.origin.x+37+(i%13-1)*21.5; //由餘數來看橫排
        CGFloat y=_earthView.frame.origin.y+25+(i/13)*21; //由商數來看直列
        
        UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(x, y, 22, 21)];
        UIImage *image=[UIImage imageNamed:@"helper"];
        [button setImage:image forState:UIControlStateNormal];
        button.tag=i;
        [button addTarget:self.navigationController.parentViewController
                   action:@selector(showWho:)
         forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
    }
}*/

-(void)detectWhichButtonIsTapped: (UIButton *) button
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //先播放音效
        //將音效檔轉換成SystemSoundID型態
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)_sound_url1, &soundID);
        AudioServicesPlaySystemSound(soundID);
        
        int i=(int)button.tag;
        NSLog(@"button: %ld",(long)button.tag);
    
        for(NSDictionary *dict in _puzzleArray)
        {
            BOOL foundOld=NO;
            BOOL foundNew=NO;
            BOOL foundSelf=NO;
            int tempId=[[dict objectForKey:@"puzzleId"]intValue];
            
            //a.若選擇的拼圖跟上一個一樣（重複按了拼圖 ），直接把圖片變成selected
            if(i==_selectedId)
            {
                //把圖片改回selected
                UIImageView *imageView=[dict objectForKey:@"puzzleView"];
                imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"selected_%03d.png",tempId]];
                    
                //變更狀態
                foundSelf=YES;
            }
            //b.找出舊的拼圖，把圖片改回unfinished/finished
            else if(tempId==_selectedId)
            {
                UIImageView *imageView=[dict objectForKey:@"puzzleView"];
                if([[dict objectForKey:@"status"]boolValue])
                    imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"finished_%03d.png",tempId]];
                else
                    imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"unfinished_%03d.png",tempId]];
                foundOld=YES;
            }
            //c.找出新選擇的拼圖，把圖片變成selected
            else if(tempId==i)
            {
                UIImageView *imageView=[dict objectForKey:@"puzzleView"];
                imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"selected_%03d.png",tempId]];
                foundNew=YES;
            }
            
            if(foundSelf) //若a已改完了，則可先跳出迴圈
                break;
            
            if(foundNew && foundOld) //若b.c兩者都改完了，則可先跳出迴圈
                break;
            
        }
        //設定新的id值
        _selectedId=i;
        
        //查閱詳細影片資訊
        _moodEvaluater=[[MoodEvaluater alloc]init];
        NSDictionary *dict=[_moodEvaluater getVideoInfoByPuzzleNum:_selectedId];
        
        NSMutableDictionary *mutableRetrievedDictionary = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%ld", (long)button.tag]] mutableCopy];
        
        //獲取標題及經緯度
        _titleLabel.text=[mutableRetrievedDictionary objectForKey:@"Title"];
        _titleLabel.font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:20.0f];
        _locationLabel.text=[mutableRetrievedDictionary objectForKey:@"Location"];
        _locationLabel.font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:14.0f];
        
        //設定縮圖
        NSURL *url = [NSURL URLWithString:[mutableRetrievedDictionary objectForKey:@"ThumbnailURL"]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [[UIImage alloc] initWithData:data];
        _thumbnailView.image=img;
        
        //設置影片ID及網址
        _chosenVideoId=[mutableRetrievedDictionary objectForKey:@"ID"];
        _chosenVideoURL=[mutableRetrievedDictionary objectForKey:@"VideoURL"];
        
        //原本隱藏轉為顯示
        _thumbnailView.hidden=NO;
        [self.thumbnailView setUserInteractionEnabled:YES];
        _titleLabel.hidden=NO;
        _locationLabel.hidden=NO;
        
        //star
        NSLog(@"star: %@~~", [mutableRetrievedDictionary objectForKey:@"star"]);
    });
}

- (void)tappedTelescopeBtn
{
    //禁止反覆按到
    [self.thumbnailView setUserInteractionEnabled:NO];
    
    //將音效檔轉換成SystemSoundID型態
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)_sound_url2, &soundID);
    AudioServicesPlaySystemSound(soundID);
    
    //切換提示
    _hintLabel.text=@"我們即將潛入這段記憶中，請稍候........";
    _hintLabel.userInteractionEnabled=NO;
     [self dialogShowEffect];
    [_triangleView stopAnimating];
    _triangleView.hidden=YES;
    
    //準備播放影片
    NSURL *url = [[NSURL alloc] initWithString:_chosenVideoURL];
    _360Player = [[HTY360PlayerVC alloc] initWithNibName:@"HTY360PlayerVC"
                                                        bundle:nil
                                                           url:url];
    _360Player.onlyForBrowse=YES; //暫時瀏覽模式
    
    //5秒後再開始播影片
    _timer =[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(switchToPlayVideo) userInfo:nil repeats:NO];
}

-(void) switchToPlayVideo
{
    [_timer invalidate];
    _timer=nil;
    
    //暫停音樂
    [_myAudioPlayer pause];
    _isPlayingMusic=NO;
    
    NaviVC *naviVC=self.navigationController;
    [naviVC pushViewController:_360Player animated:NO];
    
    _hintLabel.tag=1;
    _hintLabel.text=@"歡迎回來，我一直在等你呢";
    _hintLabel.userInteractionEnabled=YES;
    _triangleView.hidden=NO;
    [_triangleView startAnimating];
}

#pragma mark - 頁面跳轉相關

-(void) gotoTelescope
{
    [_myAudioPlayer stop];
    _isPlayingMusic=NO;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"playBGM"];
    TelescopeVC *telescopeVC=[[TelescopeVC alloc] initWithNibName:@"TelescopeVC" bundle:[NSBundle mainBundle]];
    NaviVC *naviVC=self.navigationController;
    naviVC.pushDirection=1;
    [naviVC pushViewController:telescopeVC animated:NO];
}

-(void) gotoIntercom
{
    //[_myAudioPlayer pause];
    //_isPlayingMusic=NO;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"playBGM"];
    IntercomVC *intercomVC=[[IntercomVC alloc] initWithNibName:@"IntercomVC" bundle:[NSBundle mainBundle]];
    NaviVC *naviVC=self.navigationController;
    naviVC.pushDirection=4;
    [naviVC pushViewController:intercomVC animated:NO];
}

- (IBAction)tappedUpBtn:(id)sender
{
    [self gotoTelescope];
}

- (IBAction)tappedRightBtn:(id)sender
{
    [self gotoIntercom];
}

- (IBAction)tappedExploreBtn:(id)sender {
    [self gotoTelescope];
}

- (IBAction)tappedMemoryBtn:(id)sender {
}

- (IBAction)tappedMessageBtn:(id)sender {
    [self gotoIntercom];
}

-(void) swipeSetting
{
    //除了點選按鈕，滑動的手指指令也可切換頁面
    
    //前往右
    _rightSwiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [_rightSwiper setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:_rightSwiper];
    
    //前往上
    _upSwiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [_upSwiper setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.view addGestureRecognizer:_upSwiper];
}

-(void)swipeHandler:(UISwipeGestureRecognizer *)swiper
{
    if([swiper isEqual:_rightSwiper])
        [self gotoIntercom];
    else if([swiper isEqual:_upSwiper])
        [self gotoTelescope];
}

#pragma mark - ＵＦＯ飄浮

-(void) ufoSetting
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    //畫面上共有三個ufo，皆由右至左旋轉＆移動
    //初始位置是在邊框右側（x=螢幕尺寸長），y軸分為是50,150,250的位置
    _ufo1=[[UIImageView alloc]initWithFrame:CGRectMake(screenWidth, 25, 50, 50)];
    _ufo2=[[UIImageView alloc]initWithFrame:CGRectMake(screenWidth, 125, 50, 50)];
    _ufo3=[[UIImageView alloc]initWithFrame:CGRectMake(screenWidth, 225, 50, 50)];
    _ufo4=[[UIImageView alloc]initWithFrame:CGRectMake(screenWidth, 325, 50, 50)];
    
    //存下初始的frame，方便日後重置
    ufo1Rect=_ufo1.frame;
    ufo2Rect=_ufo2.frame;
    ufo3Rect=_ufo3.frame;
    ufo4Rect=_ufo4.frame;
    
    //加到最下層srollview的內層
    [self.contentView addSubview:_ufo1];
    [self.contentView addSubview:_ufo2];
    [self.contentView addSubview:_ufo3];
    [self.contentView addSubview:_ufo4];
    
    //設定圖片
    _ufo1.image=[UIImage imageNamed:[self getRandomUFOImage]];
    _ufo2.image=[UIImage imageNamed:[self getRandomUFOImage]];
    _ufo3.image=[UIImage imageNamed:[self getRandomUFOImage]];
    _ufo4.image=[UIImage imageNamed:[self getRandomUFOImage]];
    
    //三者各自呼叫動畫效果的函式（具有不同參數）
    [self playUFO1Animation];
    [self playUFO2Animation];
    [self playUFO3Animation];
    [self playUFO4Animation];
    
    //間隔4秒後在呼叫UFO2
    //_timer2 =[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(playUFO2Animation) userInfo:nil repeats:NO];
    
    //間隔10秒後在呼叫UFO2
    //_timer3 =[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(playUFO2Animation) userInfo:nil repeats:NO];
}

-(void) playUFO1Animation
{
    _ufo1.frame=ufo1Rect; //重置回起始位置
    _ufo1.image=[UIImage imageNamed:[self getRandomUFOImage]]; //隨機獲取一UFO圖片
    [self rotateUFOView:_ufo1 withNum:1];
}

-(void) playUFO2Animation
{
    _ufo2.frame=ufo2Rect; //重置回起始位置
    _ufo2.image=[UIImage imageNamed:[self getRandomUFOImage]]; //隨機獲取一UFO圖片
    [self rotateUFOView:_ufo2 withNum:2];
}

-(void) playUFO3Animation
{
    _ufo3.frame=ufo3Rect; //重置回起始位置
    _ufo3.image=[UIImage imageNamed:[self getRandomUFOImage]]; //隨機獲取一UFO圖片
    [self rotateUFOView:_ufo3 withNum:3];
}

-(void) playUFO4Animation
{
    _ufo4.frame=ufo4Rect; //重置回起始位置
    _ufo4.image=[UIImage imageNamed:[self getRandomUFOImage]]; //隨機獲取一UFO圖片
    [self rotateUFOView:_ufo4 withNum:4];
}

-(NSString *) getRandomUFOImage
{
    //隨機獲取圖片，值需為1~11
    int i = arc4random() % 13 +1;
    NSString *imageName=[NSString stringWithFormat:@"UFO_%d",i];
    //NSLog(@"random:%d",i);
    return imageName;
}

-(void) rotateUFOView:(UIImageView *)ufoView withNum:(int) number
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    int angle=arc4random() % 181 ; //轉角在0~180度間
    int yOffset = arc4random() % 601 -300; //垂直偏移量在-150~+150
    int duration = arc4random() % 6 +10; //飄移完成的秒數，越短速度越快，值在10-15秒間
    int delay = arc4random() % 6; //延遲秒數
    
    CGAffineTransform translate = CGAffineTransformMakeTranslation(-screenWidth-50,yOffset);//設定位移路徑
    CGAffineTransform scale = CGAffineTransformMakeScale(1, 1); //設定尺寸是否縮放
    CGAffineTransform transform =  CGAffineTransformConcat(translate, scale);
    transform = CGAffineTransformRotate(transform,angle*M_PI/180);//設定旋轉角度

    // animation using block code
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^
                    {
                        ufoView.transform = transform; //設定動畫變量
                    }
                    completion:^(BOOL finished)
                    {
                        //完成動畫，已移出螢幕左邊界外
                        ufoView.transform=CGAffineTransformIdentity; //把transform重置
                        
                        if(_playingUFOAnimation)//再度呼叫動畫，形成反覆的動畫
                        {
                            switch (number) {
                                case 1:
                                    [self playUFO1Animation];
                                    break;
                                case 2:
                                    [self playUFO2Animation];
                                    break;
                                case 3:
                                    [self playUFO3Animation];
                                    break;
                                case 4:
                                    [self playUFO4Animation];
                                    break;
                            }
                            
                        }
                     }];
}


#pragma mark - 影片放映相關

/*-(void) tagBtnHit
{
    //放大
    [self.scrollView zoomToRect:CGRectMake(300, 30, 150, 150) animated:YES];
    
    //顯示影片資訊
    _videoInfo=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"videoInfo"]];
    _videoInfo.frame=CGRectMake(370, 60, 80, 65);
    [_contentView addSubview:_videoInfo];
    
    //播放圖標
    _playBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _playBtn.frame=CGRectMake(397, 130, 25, 22);
    [_playBtn setImage:[UIImage imageNamed:@"playBtn"] forState:UIControlStateNormal];
    [_playBtn addTarget:self action:@selector(playBtnHit) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_playBtn];
}*/



#pragma mark - 其他

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.contentView;
}

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
