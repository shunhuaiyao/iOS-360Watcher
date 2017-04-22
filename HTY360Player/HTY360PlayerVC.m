//
//  HTY360PlayerVC.m
//  HTY360Player
//
//  Created by  on 11/8/15.
//  Copyright © 2015 Hanton. All rights reserved.
//

#import "HTY360PlayerVC.h"
#import "HTYGLKVC.h"
#import "HomepageVC.h"
#import "NaviVC.h"
#import "CommentVC.h"
#import "EarthVC.h"
#import "MoodEvaluater.h"
#import <AudioToolbox/AudioToolbox.h>

#define ONE_FRAME_DURATION 0.033
#define HIDE_CONTROL_DELAY 3.0
#define DEFAULT_VIEW_ALPHA 0.6

NSString * const kTracksKey = @"tracks";
NSString * const kPlayableKey = @"playable";
NSString * const kRateKey = @"rate";
NSString * const kCurrentItemKey = @"currentItem";
NSString * const kStatusKey = @"status";
NSString * const kDurationKey = @"duration";

static void *AVPlayerDemoPlaybackViewControllerRateObservationContext = &AVPlayerDemoPlaybackViewControllerRateObservationContext;
static void *AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext = &AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;
static void *AVPlayerItemStatusContext = &AVPlayerItemStatusContext;

@interface HTY360PlayerVC ()

@property (strong, nonatomic) IBOutlet UIView *playerControlBackgroundView;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UISlider *progressSlider;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *gyroButton;
@property (strong, nonatomic) HTYGLKVC *glkViewController;
@property (strong, nonatomic) AVPlayerItemVideoOutput* videoOutput;
@property (strong, nonatomic) AVPlayer* player;
@property (strong, nonatomic) AVPlayerItem* playerItem;
@property (strong, nonatomic) id timeObserver;
@property (assign, nonatomic) CGFloat mRestoreAfterScrubbingRate;
@property (assign, nonatomic) BOOL seekToZeroBeforePlay;

@property (assign, nonatomic) BOOL readyToPlayState;
@property NSTimer *timer;
@property MoodEvaluater *moodEvaluater;

//音效相關
@property SystemSoundID soundID;


@end

@implementation HTY360PlayerVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSURL*)url {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setVideoURL:url];
        
        _readyToPlayState=NO;
        _currentMood=[[NSString alloc]init];
        _currentType=[[NSString alloc]init];
        _moodEvaluater=[[MoodEvaluater alloc]init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
        [self setupVideoPlaybackForURL:_videoURL];
        [self configureGLKView];
        [self configurePlayButton];
        [self configureProgressSlider];
        [self configureControleBackgroundView];
        [self configureBackButton];
        [self configureGyroButton];
        [self audioSetting];
    
#if SHOW_DEBUG_LABEL
    self.debugView.hidden = NO;
#endif
    }
    return self;
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    [self pause];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self updatePlayButton];
    [self.player seekToTime:[self.player currentTime]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.playerControlBackgroundView = nil;
    self.playButton = nil;
    self.progressSlider = nil;
    self.backButton = nil;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    @try {
        [self removePlayerTimeObserver];
        [self.playerItem removeObserver:self forKeyPath:kStatusKey];
        [self.playerItem removeOutput:self.videoOutput];
        [self.player removeObserver:self forKeyPath:kCurrentItemKey];
        [self.player removeObserver:self forKeyPath:kRateKey];
    } @catch(id anException) {
        //do nothing
    }
    
    self.videoOutput = nil;
    self.playerItem = nil;
    self.player = nil;
}

#pragma mark - 播放控制

-(void) viewWillAppear:(BOOL)animated
{
    NSLog(@"viewDidLoad");
    
    //直接播放影片
    self.playerControlBackgroundView.hidden = YES;
    [self initializeTimer];
    [self swipeSetting];
    
    _YesLabel.userInteractionEnabled=NO;
    UITapGestureRecognizer *YesTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Exit360video)];
    YesTap.numberOfTapsRequired = 1;
    [self.YesLabel addGestureRecognizer:YesTap];
    
    _NoLabel.userInteractionEnabled=NO;
    UITapGestureRecognizer *NoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Back360video)];
    NoTap.numberOfTapsRequired = 1;
    [self.NoLabel addGestureRecognizer:NoTap];
}

-(void) viewDidAppear:(BOOL)animated
{
    if (_readyToPlayState){ //已經可以播了
        NSLog(@"play when entered");
        [self play];
        [self reloadToAvoidRenderFailure];
    }
    NSLog(@"moodStr:%@",self.currentMood);
}

-(void) reloadToAvoidRenderFailure
{
    [self.player seekToTime:[self.player currentTime]];
}

-(void)initializeTimer {
    
    //20秒後隱藏黑框Mask
    float hideInterval = 20.0;
    [NSTimer scheduledTimerWithTimeInterval:hideInterval
                                     target:self
                                   selector:@selector(dismissMask)
                                   userInfo:nil
                                    repeats:NO];
    
    //40秒後顯示更新報告字樣
    float updateInterval = 40.0;
    [NSTimer scheduledTimerWithTimeInterval:updateInterval
                                     target:self
                                   selector:@selector(showUpdateReport)
                                   userInfo:nil
                                    repeats:NO];
}

-(void) showUpdateReport
{
    [self showUpdateWithDuration:2];
}

- (void)showUpdateWithDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
                         self.updateView.alpha = 1.0f;
                     }
                     completion:^(BOOL finished){
                         if(finished)
                         [self hideUpdateWithDuration:2];
                     }];
}

- (void)hideUpdateWithDuration:(NSTimeInterval)duration
{
    self.updateView.alpha = 1;
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
                         self.updateView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         if(finished)
                             self.updateView.hidden=YES;
                     }];
}

-(void)dismissMask
{
    [self hideMaskWithDuration:1];
}

- (void)hideMaskWithDuration:(NSTimeInterval)duration {
    self.maskFrameView.alpha = 1;
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
                         self.maskFrameView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         if(finished)
                             [self.maskFrameView removeFromSuperview];
                     }];
    
}

#pragma mark - 按鈕控制

- (IBAction)tappedExitBtn:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self pause];
    
    _robotFrame.alpha = 1;
    _HintLabel.alpha = 1;
    _NoLabel.alpha = 1;
    _SlashLabel.alpha = 1;
    _YesLabel.alpha = 1;
    _YesLabel.userInteractionEnabled = YES;
    _NoLabel.userInteractionEnabled = YES;
    
}

-(void) Exit360video
{
    if(!_onlyForBrowse) //探索模式跳轉到詢問評價頁面
    {
        CommentVC *commentVC = [[CommentVC alloc] initWithNibName:@"CommentVC" bundle:[NSBundle mainBundle]];
        commentVC.currentVideoInfo=[self.currentVideoInfo copy];
        commentVC.currentMood=[self.currentMood copy];
    
        for(NSString *key in [self.currentVideoInfo allKeys]) {
            NSLog(@"video key %@ info %@", key, [self.currentVideoInfo objectForKey:key]);
        }
    
        //處於未觀看完畢的狀態，把字典加上"狀態的key值"後存入VideoRecord
        [_currentVideoInfo setObject:[NSNumber numberWithBool:YES] forKey:@"FinishStatus"];
        [_moodEvaluater storeVideoInfo:_currentVideoInfo withType:self.currentType];
    
        NaviVC *naviVC=self.navigationController;
        [naviVC pushViewController:commentVC animated:NO];
    }
    else{
        EarthVC *earthVC = [[EarthVC alloc] initWithNibName:@"EarthVC" bundle:[NSBundle mainBundle]];
        NaviVC *naviVC=self.navigationController;
        [naviVC pushViewController:earthVC animated:NO];
    }
}

-(void) Back360video
{
    _robotFrame.alpha = 0;
    _HintLabel.alpha = 0;
    _NoLabel.alpha = 0;
    _SlashLabel.alpha = 0;
    _YesLabel.alpha = 0;
    _YesLabel.userInteractionEnabled = NO;
    _NoLabel.userInteractionEnabled = NO;

    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self play];
}

-(void) swipeSetting
{
    //除了點選按鈕，滑動的手指指令也可切換頁面
    //前往下
    UISwipeGestureRecognizer *downSwiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler)];
    [downSwiper setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self.view addGestureRecognizer:downSwiper];
}

-(void) swipeHandler
{
     //[self goBackToEarth];
}

- (IBAction)tappedModeBtn:(id)sender
{
    //變更移動或固定模式
    if(self.glkViewController.isUsingMotion) {
        [self.glkViewController stopDeviceMotion];
    } else {
        [self.glkViewController startDeviceMotion];
    }
    
}

- (IBAction)tappedCameraBtn:(id)sender
{
    //播放音效
    AudioServicesPlaySystemSound(_soundID);
    
    //進行畫面截圖
    //UIView *screenshotView = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:NO];
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0.0);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //存入相簿中
    UIImageWriteToSavedPhotosAlbum(snapshotImage, self, nil, nil);
}

- (IBAction)tappedPauseBtn:(id)sender {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if ([self isPlaying]) {
        [self pause];
    } else {
        [self play];
    }
}

-(void) audioSetting
{
    //設定音檔位置
    NSURL *sound_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"screenshot" ofType:@"mp3"]];
    //將音效檔轉換成SystemSoundID型態
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)sound_url, &_soundID);
}

#pragma mark - video communication

- (CVPixelBufferRef)retrievePixelBufferToDraw {
    CVPixelBufferRef pixelBuffer = [self.videoOutput copyPixelBufferForItemTime:[self.playerItem currentTime] itemTimeForDisplay:nil];
    return pixelBuffer;
}

#pragma mark - video setting

- (void)setupVideoPlaybackForURL:(NSURL*)url {
    NSDictionary *pixelBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
    self.videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixelBuffAttributes];
    
    self.player = [[AVPlayer alloc] init];
    
    // Do not take mute button into account
    NSError *error = nil;
    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                                          error:&error];
    if (!success) {
        NSLog(@"Could not use AVAudioSessionCategoryPlayback", nil);
    }
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:[[asset URL] path]]) {
        //NSLog(@"file does not exist");
    }
    
    NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey, kPlayableKey, kDurationKey, nil];
    
    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
        
        dispatch_async( dispatch_get_main_queue(),
                       ^{
                           /* Make sure that the value of each key has loaded successfully. */
                           for (NSString *thisKey in requestedKeys) {
                               NSError *error = nil;
                               AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
                               if (keyStatus == AVKeyValueStatusFailed) {
                                   [self assetFailedToPrepareForPlayback:error];
                                   return;
                               }
                           }
                           
                           NSError* error = nil;
                           AVKeyValueStatus status = [asset statusOfValueForKey:kTracksKey error:&error];
                           if (status == AVKeyValueStatusLoaded) {

                               
                               self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
                               [self.playerItem addOutput:self.videoOutput];
                               [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
                               [self.videoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:ONE_FRAME_DURATION];
                               
                               /* When the player item has played to its end time we'll toggle
                                the movie controller Pause button to be the Play button */
                               [[NSNotificationCenter defaultCenter] addObserver:self
                                                                        selector:@selector(playerItemDidReachEnd:)
                                                                            name:AVPlayerItemDidPlayToEndTimeNotification
                                                                          object:self.playerItem];
                               
                               self.seekToZeroBeforePlay = NO;
                               
                               [self.playerItem addObserver:self
                                                 forKeyPath:kStatusKey
                                                    options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                                    context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
                               
                               [self.player addObserver:self
                                             forKeyPath:kCurrentItemKey
                                                options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                                context:AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext];
                               
                               [self.player addObserver:self
                                             forKeyPath:kRateKey
                                                options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                                context:AVPlayerDemoPlaybackViewControllerRateObservationContext];
                               
                               
                               [self initScrubberTimer];
                               [self syncScrubber];
                               NSLog(@"AVKeyValueStatusLoaded");
                           } else {
                               NSLog(@"%@ Failed to load the tracks.", self);
                           }
                       });
    }];
}

#pragma mark - rendering glk view management

- (void)configureGLKView {
    self.glkViewController = [[HTYGLKVC alloc] init];
    self.glkViewController.videoPlayerController = self;
    self.glkViewController.view.frame = self.view.bounds;
    [self.view insertSubview:self.glkViewController.view belowSubview:self.playerControlBackgroundView];
    [self addChildViewController:self.glkViewController];
    [self.glkViewController didMoveToParentViewController:self];
}

#pragma mark - play button management

- (void)configurePlayButton{
    self.playButton.backgroundColor = [UIColor clearColor];
    self.playButton.showsTouchWhenHighlighted = YES;
    
    [self disablePlayerButtons];
    [self updatePlayButton];
}

- (IBAction)playButtonTouched:(id)sender {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if ([self isPlaying]) {
        [self pause];
    } else {
        [self play];
    }
}

- (void)updatePlayButton {
    [self.playButton setImage:[UIImage imageNamed:[self isPlaying] ? @"playback_pause" : @"playback_play"]
                     forState:UIControlStateNormal];
}

- (void)play {
    NSLog(@"play");
    if ([self isPlaying])
        return;
    /* If we are at the end of the movie, we must seek to the beginning first
     before starting playback. */
    if (YES == self.seekToZeroBeforePlay) {
        self.seekToZeroBeforePlay = NO;
        [self.player seekToTime:kCMTimeZero];
    }
    
    //[self updatePlayButton];
    [self.player play];
    
    [self scheduleHideControls];
}

- (void)pause {
    NSLog(@"pause");
    if (![self isPlaying])
        return;
    
    [self updatePlayButton];
    [self.player pause];
    
    [self scheduleHideControls];
}

#pragma mark - progress slider management

- (void)configureProgressSlider {
    self.progressSlider.continuous = NO;
    self.progressSlider.value = 0;
    
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateNormal];
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateHighlighted];
}

#pragma mark - back and gyro button management

- (void)configureBackButton {
    self.backButton.backgroundColor = [UIColor clearColor];
    self.backButton.showsTouchWhenHighlighted = YES;
}

- (void)configureGyroButton {
    self.gyroButton.backgroundColor = [UIColor clearColor];
    self.gyroButton.showsTouchWhenHighlighted = YES;
}

#pragma mark - controls management

- (void)enablePlayerButtons {
    self.playButton.enabled = YES;
}

- (void)disablePlayerButtons {
    self.playButton.enabled = NO;
}

- (void)configureControleBackgroundView {
    self.playerControlBackgroundView.layer.cornerRadius = 8;
}

- (void)toggleControls {
    if(self.playerControlBackgroundView.hidden){
        //[self showControlsFast];
    }else{
        //[self hideControlsFast];
    }
    
    [self scheduleHideControls];
}

- (void)scheduleHideControls {
    if(!self.playerControlBackgroundView.hidden) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(hideControlsSlowly) withObject:nil afterDelay:HIDE_CONTROL_DELAY];
    }
}

- (void)hideControlsWithDuration:(NSTimeInterval)duration {
    self.playerControlBackgroundView.alpha = DEFAULT_VIEW_ALPHA;
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
                         self.playerControlBackgroundView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         if(finished)
                             self.playerControlBackgroundView.hidden = YES;
                     }];
    
}

- (void)hideControlsFast {
    [self hideControlsWithDuration:0.2];
}

- (void)hideControlsSlowly {
    [self hideControlsWithDuration:1.0];
}

- (void)showControlsFast {
    self.playerControlBackgroundView.alpha = 0.0;
    self.playerControlBackgroundView.hidden = NO;
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
                         self.playerControlBackgroundView.alpha = DEFAULT_VIEW_ALPHA;
                     }
                     completion:nil];
}

- (void)removeTimeObserverForPlayer {
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

#pragma mark - slider progress management

- (void)initScrubberTimer {
    double interval = .1f;
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)) {
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)) {
        CGFloat width = CGRectGetWidth([self.progressSlider bounds]);
        interval = 0.5f * duration / width;
    }
    
    __weak HTY360PlayerVC* weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                         /* If you pass NULL, the main queue is used. */
                                                                  queue:NULL
                                                             usingBlock:^(CMTime time) {
                                                                 [weakSelf syncScrubber];
                                                             }];
    
}

- (CMTime)playerItemDuration {
    if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
        /*
         NOTE:
         Because of the dynamic nature of HTTP Live Streaming Media, the best practice
         for obtaining the duration of an AVPlayerItem object has changed in iOS 4.3.
         Prior to iOS 4.3, you would obtain the duration of a player item by fetching
         the value of the duration property of its associated AVAsset object. However,
         note that for HTTP Live Streaming Media the duration of a player item during
         any particular playback session may differ from the duration of its asset. For
         this reason a new key-value observable duration property has been defined on
         AVPlayerItem.
         
         See the AV Foundation Release Notes for iOS 4.3 for more information.
         */
        
        return ([self.playerItem duration]);
    }
    
    return (kCMTimeInvalid);
}

- (void)syncScrubber {
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)) {
        self.progressSlider.minimumValue = 0.0;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)) {
        float minValue = [self.progressSlider minimumValue];
        float maxValue = [self.progressSlider maximumValue];
        double time = CMTimeGetSeconds([self.player currentTime]);
        
        [self.progressSlider setValue:(maxValue - minValue) * time / duration + minValue];
    }
}

/* The user is dragging the movie controller thumb to scrub through the movie. */
- (IBAction)beginScrubbing:(id)sender {
    self.mRestoreAfterScrubbingRate = [self.player rate];
    [self.player setRate:0.f];
    
    /* Remove previous timer. */
    [self removeTimeObserverForPlayer];
}

/* Set the player current time to match the scrubber position. */
- (IBAction)scrub:(id)sender {
    if ([sender isKindOfClass:[UISlider class]]) {
        UISlider* slider = sender;
        
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration)) {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration)) {
            float minValue = [slider minimumValue];
            float maxValue = [slider maximumValue];
            float value = [slider value];
            
            double time = duration * (value - minValue) / (maxValue - minValue);
            
            [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
        }
    }
}

/* The user has released the movie thumb control to stop scrubbing through the movie. */
- (IBAction)endScrubbing:(id)sender {
    if (!self.timeObserver) {
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration)) {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration)) {
            CGFloat width = CGRectGetWidth([self.progressSlider bounds]);
            double tolerance = 0.5f * duration / width;
            
            __weak HTY360PlayerVC* weakSelf = self;
            self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC)
                                                                          queue:NULL
                                                                     usingBlock:^(CMTime time) {
                                                                         [weakSelf syncScrubber];
                                                                     }];
        }
    }
    
    if (self.mRestoreAfterScrubbingRate) {
        [self.player setRate:self.mRestoreAfterScrubbingRate];
        self.mRestoreAfterScrubbingRate = 0.f;
    }
}

- (BOOL)isScrubbing {
    return self.mRestoreAfterScrubbingRate != 0.f;
}

- (void)enableScrubber {
    self.progressSlider.enabled = YES;
}

- (void)disableScrubber {
    self.progressSlider.enabled = NO;
}

- (void)observeValueForKeyPath:(NSString*)path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context {
    /* AVPlayerItem "status" property value observer. */
    if (context == AVPlayerDemoPlaybackViewControllerStatusObservationContext) {
        [self updatePlayButton];
        
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status) {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerStatusUnknown: {
                [self removePlayerTimeObserver];
                [self syncScrubber];
                [self disableScrubber];
                [self disablePlayerButtons];
                NSLog(@"VPlayerStatusUnknown");
                break;
            }
            case AVPlayerStatusReadyToPlay: {
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                [self initScrubberTimer];
                [self enableScrubber];
                [self enablePlayerButtons];
                
                //已經可以播放了
                _readyToPlayState=YES;
                if (self.isViewLoaded && self.view.window){ //播放器畫面已載入
                    [self play];
                    [self reloadToAvoidRenderFailure];
                    NSLog(@"play when ready");
                }
                
                
                break;
            }
            case AVPlayerStatusFailed: {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error];
                NSLog(@"Error fail : %@", playerItem.error);
                break;
            }
        }
    } else if (context == AVPlayerDemoPlaybackViewControllerRateObservationContext) {
        [self updatePlayButton];
        // NSLog(@"AVPlayerDemoPlaybackViewControllerRateObservationContext");
    } else if (context == AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext) {
        /* AVPlayer "currentItem" property observer.
         Called when the AVPlayer replaceCurrentItemWithPlayerItem:
         replacement will/did occur. */
        
        //NSLog(@"AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext");
    } else {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}

- (void)assetFailedToPrepareForPlayback:(NSError *)error {
    [self removePlayerTimeObserver];
    [self syncScrubber];
    [self disableScrubber];
    [self disablePlayerButtons];
    
    /* Display the error. */
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:[error localizedDescription]
                                          message:[error localizedFailureReason]
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)isPlaying {
    return self.mRestoreAfterScrubbingRate != 0.f || [self.player rate] != 0.f;
}

/* Called when the player item has played to its end time. */
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    /* After the movie has played to its end time, seek back to time zero
     to play it again. */
    self.seekToZeroBeforePlay = YES;
    
    UIImageView *ending=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ending"]];
    ending.frame=CGRectMake(-1, -1, [[UIScreen mainScreen] bounds].size.width+2, [[UIScreen mainScreen] bounds].size.height+2);
    [self.view addSubview:ending];
    
    //播放完畢，跳載到結束頁面
    NSLog(@"影片播放結束");
    
    if(!_onlyForBrowse) //探索模式跳轉到詢問評價頁面
    {
        CommentVC *commentVC = [[CommentVC alloc] initWithNibName:@"CommentVC" bundle:[NSBundle mainBundle]];
        commentVC.currentVideoInfo=[self.currentVideoInfo copy];
        commentVC.currentMood=[self.currentMood copy];
        
        for(NSString *key in [self.currentVideoInfo allKeys]) {
            NSLog(@"done video key %@ info %@", key, [self.currentVideoInfo objectForKey:key]);
        }
        
        //處於未觀看完畢的狀態，把字典加上"狀態的key值"後存入VideoRecord
        [_currentVideoInfo setObject:[NSNumber numberWithBool:YES] forKey:@"FinishStatus"];
        [_moodEvaluater storeVideoInfo:_currentVideoInfo withType:self.currentType];
    
        //前往結尾頁面
        NaviVC *naviVC=self.navigationController;
        [naviVC pushViewController:commentVC animated:NO];
    }
    else //瀏覽模式直接返回
    {
        //返回memory
        EarthVC *earthVC = [[EarthVC alloc] initWithNibName:@"EarthVC" bundle:[NSBundle mainBundle]];
        NaviVC *naviVC=self.navigationController;
        [naviVC pushViewController:earthVC animated:NO];
    }
}


#pragma mark - gyro button

- (IBAction)gyroButtonTouched:(id)sender {
    if(self.glkViewController.isUsingMotion) {
        [self.glkViewController stopDeviceMotion];
    } else {
        [self.glkViewController startDeviceMotion];
    }
    
    self.gyroButton.selected = self.glkViewController.isUsingMotion;
}

#pragma mark - back button

- (IBAction)backButtonTouched:(id)sender {
    [self removePlayerTimeObserver];
    
    [self.player pause];
    
    [self.glkViewController removeFromParentViewController];
    self.glkViewController = nil;
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

/* Cancels the previously registered time observer. */
- (void)removePlayerTimeObserver {
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) {
        self.view = nil;
    }
}

@end
