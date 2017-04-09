//
//  CommentVC.m
//  360Project
//
//  Created by Rachel Yeh on 2017/3/22.
//  Copyright © 2017年 Hanton. All rights reserved.
//

#import "CommentVC.h"
#import "NaviVC.h"

@interface CommentVC ()
{
    NSTimer *_timer;
}
@end

@implementation CommentVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self hintLabelTapSetting];
    
    //獲取標題及經緯度
    _titleLabel.text=[_currentVideoInfo objectForKey:@"Title"];
    _titleLabel.font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:23.0f];
    _locationLabel.text=[_currentVideoInfo objectForKey:@"Location"];
    _locationLabel.font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:17.0f];
    
    //獲取截圖
    NSURL *url = [NSURL URLWithString:[[_currentVideoInfo objectForKey:@"ThumbnailURL"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [UIImage imageWithData:data];
    if(img)
        _thumbnailView.image=img;
    
    //拼圖閃爍效果
    _puzzleView.alpha=0.4;
    _timer=[NSTimer scheduledTimerWithTimeInterval:2.2 target:self selector:@selector(decideIntervalByTimer:) userInfo:nil repeats:YES];
    
    //吉祥物詢問對話
    _hintLabel.text=@"你喜歡這個記憶帶給你的感受嗎？";
    
    //第一個回答選項
    _option1.text=@"不錯啊";
    _option1.tag=1;
    _option1.userInteractionEnabled=YES;
    UITapGestureRecognizer *option1Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseOption1)];
    option1Tap.numberOfTapsRequired = 1;
    [self.option1 addGestureRecognizer:option1Tap];
    
    //第二個回答選項
    _option2.text=@"沒特別感覺";
    _option2.tag=2;
    _option2.userInteractionEnabled=YES;
    UITapGestureRecognizer *option2Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseOption2)];
    option2Tap.numberOfTapsRequired = 1;
    [self.option2 addGestureRecognizer:option2Tap];
}

# pragma mark - 選擇回答選項

-(void) hintLabelTapSetting
{
    UITapGestureRecognizer *hintTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedHintLabel)];
    hintTap.numberOfTapsRequired = 1;
    [self.hintLabel addGestureRecognizer:hintTap];
    
    _hintLabel.userInteractionEnabled=NO; //先關閉互動
    _triangleView.hidden=YES; //隱藏三角形
}

-(void) tappedHintLabel
{
    //停止動畫
    [_puzzleView stopAnimating];
    [_triangleView stopAnimating];
    
    //返回首頁
    NaviVC *naviVC=self.navigationController;
    naviVC.pushDirection=1;
    [naviVC popToRootViewControllerAnimated:YES];
}

-(void) chooseOption1 //正面評價
{
    [self endingWord];
}

-(void) chooseOption2 //負面評價
{
    [self endingWord];
}

-(void) endingWord
{
    //隱藏選擇
    _positive.hidden=YES;
    _negative.hidden=YES;
    _slash.hidden=YES;
    
    //變更提示
    _trailingConstraint.constant=60;
    _hintLabel.text=@"這樣啊，那等會兒再繼續探索吧！";
    _hintLabel.userInteractionEnabled=YES;
    
    //三角形動畫
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

# pragma mark - 拼圖閃爍效果

-(void) decideIntervalByTimer: (NSTimer *)timer
{
    [self strongerEffectWithDuration:0.7 andAlpha:0.6]; //閃爍較慢，時間區間為0.4
}

-(void) strongerEffectWithDuration:(CGFloat)second andAlpha:(CGFloat) alpha
{
    //透明度變化
    _puzzleView.alpha=alpha;
    [UIView animateWithDuration:second delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ _puzzleView.alpha = 1;}
                     completion:^(BOOL finished){
                         if(finished){
                             _puzzleView.alpha = 1;
                             [self stayingEffectWithDuration:second andAlpha:alpha];
                         }}];
}

-(void) stayingEffectWithDuration:(CGFloat)second andAlpha:(CGFloat) alpha
{
    //透明度變化
    [UIView animateWithDuration:second-0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ _puzzleView.alpha = 1;}
                     completion:^(BOOL finished){
                         if(finished){
                             [self lighterEffectWithDuration:second andAlpha:alpha];
                         }}];
}

-(void) lighterEffectWithDuration:(CGFloat)second andAlpha:(CGFloat) alpha
{
    //透明度變化
    _puzzleView.alpha=1;
    [UIView animateWithDuration:second delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ _puzzleView.alpha = alpha;}
                     completion:^(BOOL finished){
                         if(finished){
                             _puzzleView.alpha = alpha;
                         }}];
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
