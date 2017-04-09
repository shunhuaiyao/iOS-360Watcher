//
//  HomepageVC.m
//  360Project
//
//  Created by Rachel Yeh on 2016/12/12.
//  Copyright © 2016年 Hanton. All rights reserved.
//

#import "HomepageVC.h"
#import "TelescopeVC.h"
#import "LettersVC.h"
#import "IntercomVC.h"
#import "EarthVC.h"
#import "NaviVC.h"

@interface HomepageVC ()
{
    BOOL _isPlayingMusic;
    int _musicTrack;
    AVAudioPlayer *_myAudioPlayer;
}
@end

@implementation HomepageVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadBGM];
    [self loadEarthAnimation];
    
}

-(void) puzzleTest
{
    for(int i=1 ; i<=130 ; i++) //共有130張拼圖
    {
        UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"unfinished_%03d.png",i]]];
        imageView.frame=_earthView.frame;
        [self.view addSubview:imageView];
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [self puzzleTest];
    
    if(!_isPlayingMusic)
    {
        [_myAudioPlayer play];
        _isPlayingMusic=YES;
    }
        
    /*_alreaySentView.hidden=YES;
    NaviVC *naviVC=self.navigationController;
    if(naviVC.withNotification)
    {
        _alreaySentView.hidden=NO;
        [self hideAlreaySentWithDuration:1];
    }*/
}

/*- (void)hideAlreaySentWithDuration:(NSTimeInterval)duration {
    self.alreaySentView.alpha = 1;
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
                         self.alreaySentView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         if(finished)
                             _alreaySentView.hidden=YES;
                     }];
}*/

-(void) loadEarthAnimation
{
    //加載分格圖片
    NSMutableArray *addEarthImages = [[NSMutableArray alloc] init];
    
    for(int i=0 ; i<200 ; i=i+1)
    {
        NSString *imageName=[NSString stringWithFormat:@"GLOBAL 3-01_%05d.png",i];
        UIImage *image = [UIImage imageNamed:imageName];
        
        if(image)
        {
            //NSLog(@"image:%@",imageName);
            [addEarthImages addObject:image];
        }
    }

    //透過地球按鈕圖片的改變製造動畫效果
    _earthBtn.imageView.animationImages = addEarthImages;
    _earthBtn.imageView.animationDuration = 30;
    _earthBtn.imageView.animationRepeatCount = 0;
    //[_earthBtn.imageView startAnimating];
    
}

-(void)loadBGM
{
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/Hotel.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    _myAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    _myAudioPlayer.numberOfLoops = -1; //Infinite
    
    [_myAudioPlayer play];
    _isPlayingMusic=YES;
    _musicTrack=1;
    NSLog(@"played BGM");
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - 物件按鈕事件處理

- (IBAction)tappedMusicbox:(id)sender
{
    if(_isPlayingMusic){
        [_myAudioPlayer stop];
        
        if(_musicTrack==1) //改放第二首
        {
            NSString *soundFilePath = [NSString stringWithFormat:@"%@/Chinatown.mp3", [[NSBundle mainBundle] resourcePath]];
            NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
            _myAudioPlayer = [_myAudioPlayer initWithContentsOfURL:soundFileURL error:nil];
            _myAudioPlayer.numberOfLoops = -1; //Infinite
            [_myAudioPlayer play];
            _musicTrack=2;
            _isPlayingMusic=YES;
        }
        else if(_musicTrack==2) //改放第一首
        {
            NSString *soundFilePath = [NSString stringWithFormat:@"%@/Hotel.mp3", [[NSBundle mainBundle] resourcePath]];
            NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
            _myAudioPlayer = [_myAudioPlayer initWithContentsOfURL:soundFileURL error:nil];
            _myAudioPlayer.numberOfLoops = -1; //Infinite
            [_myAudioPlayer play];
            _musicTrack=1;
            _isPlayingMusic=YES;
        }
    }
}

- (IBAction)tappedEarth:(id)sender
{
    [_myAudioPlayer pause];
    _isPlayingMusic=NO;
    
    [_earthBtn.imageView stopAnimating];
    
    EarthVC *earthVC=[[EarthVC alloc] initWithNibName:@"EarthVC" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:earthVC animated:YES];
}

- (IBAction)tappedTelescope:(id)sender
{
    [_myAudioPlayer pause];
    _isPlayingMusic=NO;
    
    [_earthBtn.imageView stopAnimating];
    
    TelescopeVC *telescopeVC=[[TelescopeVC alloc] initWithNibName:@"TelescopeVC" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:telescopeVC animated:YES];
    //[self presentViewController:telescopeVC animated:YES completion:nil];
}

- (IBAction)tappedIntercom:(id)sender
{
    //[_myAudioPlayer pause];
    //_isPlayingMusic=NO;
    
    [_earthBtn.imageView stopAnimating];
    
    IntercomVC *intercomVC=[[IntercomVC alloc] initWithNibName:@"IntercomVC" bundle:[NSBundle mainBundle]];
    //[self presentViewController:mailboxVC animated:YES completion:nil];
    [self.navigationController pushViewController:intercomVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) {
        self.view = nil;
    }
}

@end
