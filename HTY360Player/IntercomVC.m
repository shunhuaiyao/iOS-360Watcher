//
//  MailboxVC.m
//  360Project
//
//  Created by Rachel Yeh on 2016/12/12.
//  Copyright © 2016年 Hanton. All rights reserved.
//

#import "IntercomVC.h"
#import "HomepageVC.h"
#import "TelescopeVC.h"
#import "EarthVC.h"
#import "NaviVC.h"
#import "SendVC.h"
#import "JsonRetriever.h"
#import "PlistAccessManager.h"
#import "BrowseVC.h"
#import "ResponseVC.h"

@interface IntercomVC ()
{
    NaviVC *_naviVC;
    PlistAccessManager *plistManager;
    JsonRetriever *jsonRetriever;
    BOOL getNewMessage;
    BOOL alreadyHave;
    
    //音樂播放相關
    BOOL _isPlayingMusic;
    AVAudioPlayer *_myAudioPlayer;
}
@end

@implementation IntercomVC
@synthesize messageCell = _messageCell;
@synthesize messageTable = _messageTable;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _naviVC=self.navigationController;
    plistManager=[[PlistAccessManager alloc]init];
    jsonRetriever=[[JsonRetriever alloc] init];
    jsonRetriever.delegate=self;
    _messageArray=[[NSArray alloc]init];
    
    //檢查時間以知是否獲取新訊息
    _messageTable.hidden=NO;
    [self checkIfAbleToGetNewMessageByTime];
    
    //其他設定
    _emptyHint.hidden=YES;
    _whetherSend=NO;
    _whetherInspect=NO;
    _actionHint.hidden=YES;

}

-(void) viewWillAppear:(BOOL)animated
{
    //處理取消收藏的信件
    if(_deleteMID!=nil)
    {
        NSLog(@"deleteMID:%@",_deleteMID);
        
        //取出訊息陣列
        NSMutableArray *messageArray=[NSMutableArray arrayWithArray:[plistManager getRootArrayOfPlist:@"receivedMessage" underFolder:@"watchtower"]];
        
        //逐一比較是否已有此則訊息
        for(NSDictionary *dict in messageArray)
        {
            if([[dict objectForKey:@"MID"] isEqual:_deleteMID]){
                [messageArray removeObject:dict];
                break;
            }
        }
        
        //將刪減後的陣列存回去
        [plistManager saveAndCoverArray:messageArray intoPlist:@"receivedMessage" underFolder:@"watchtower"];
        [_messageTable reloadData];
        _deleteMID=nil;
    }
    
    //檢查時間以知是否獲取新訊息
    _messageTable.hidden=NO;
    [self checkIfAbleToGetNewMessageByTime];
    
    //檢查是否有RE
    /*if([[plistManager getRootArrayOfPlist:@"writtenMessage" underFolder:@"watchtower"]count]==0){
        _responseBtn.enabled=NO;
        _responseBtn.alpha=0.4;
    } else {
        _responseBtn.enabled=YES;
        _responseBtn.alpha=1;
    }*/
    
    [self loadBGM];
}

-(void) viewDidAppear:(BOOL)animated
{
    //是否顯示提示字
    if(_whetherSend){
        _actionHint.text=@"訊 息 已 成 功 發 送";
    }
    else if (_whetherInspect) {
        _actionHint.text=@"訊息已舉報，總部將會盡快調查";
    }
    
    if(_whetherSend || _whetherInspect)
    {
        //動畫淡入淡出
        _actionHint.hidden=NO;
        [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ _actionHint.alpha = 0;}
                         completion:^(BOOL finished){
                             if(finished){
                                 _actionHint.alpha = 1;
                                 _actionHint.hidden=YES;
                                 _actionHint.text=@"";
                                 _whetherSend=NO;
                                _whetherInspect=NO;
                             }}];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [_myAudioPlayer stop];
}

-(void)loadBGM
{
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/BGM.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    _myAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    _myAudioPlayer.numberOfLoops = -1; //Infinite
    
    [_myAudioPlayer play];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"playBGM"];
    _isPlayingMusic=YES;
}

-(int)compareStringWithCurrentDate:(NSString *)string
{
    //將string轉為date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *lastTime = [dateFormatter dateFromString:string];
    
    //獲取現在的時間
    NSDate *currentTime = [NSDate date];
    NSLog(@"current:%@",[dateFormatter stringFromDate:currentTime]);
    
    NSTimeInterval distanceBetweenDates = [currentTime timeIntervalSinceDate:lastTime];
    double secondsInMinute = 60;
    int secondsBetweenTime = distanceBetweenDates / secondsInMinute;
    
    return secondsBetweenTime;
}

-(void) checkIfAbleToGetNewMessageByTime
{
    getNewMessage=0;
    
    //1．距離上次關閉app相隔12小時
    NSDictionary *dict=[[plistManager getRootArrayOfPlist:@"TimeRecord" underFolder:@"watchtower"]objectAtIndex:0];
    int offSpan=[self compareStringWithCurrentDate:[dict objectForKey:@"offTime"]];
    
    if(offSpan>=12*60)
        getNewMessage=1;
    
    //2．已開啟app達1分鐘
    NSDictionary *dict2=[[plistManager getRootArrayOfPlist:@"TimeRecord" underFolder:@"watchtower"]objectAtIndex:0];
    int onSpan=[self compareStringWithCurrentDate:[dict2 objectForKey:@"onTime"]];
    
    if(onSpan>=2)
        getNewMessage=1;
    
    //3．上述條件若有一者符合，可領取新訊息
    if(getNewMessage)
    {
        NSString *deviceStr=[[plistManager getRootArrayOfPlist:@"deviceID" underFolder:@"watchtower"] objectAtIndex:0];
        NSString *url=[NSString stringWithFormat:@"http://52.185.155.19/watchtower/getRandomMessage.php?DeviceID=%@",deviceStr];
        [jsonRetriever httpGetMethodByURL:url];
    }
}

-(void)getJsonData:(id)jsonObject
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"取得結果：%@",jsonObject);
        
        //檢查
        if(getNewMessage)
        {
            //取出訊息陣列
            NSMutableArray *messageArray=[NSMutableArray arrayWithArray:[plistManager getRootArrayOfPlist:@"receivedMessage" underFolder:@"watchtower"]];
            
            //逐一比較是否已有此則訊息
            alreadyHave=0;
            for(NSDictionary *dict in messageArray)
            {
                    if([dict isEqual:jsonObject]){
                        alreadyHave=1;
                        break;
                    }
            }
            
            if(alreadyHave) //若已有此訊息，重領取
            {
                NSString *deviceStr=[[plistManager getRootArrayOfPlist:@"deviceID" underFolder:@"watchtower"] objectAtIndex:0];
                NSString *url=[NSString stringWithFormat:@"http://52.185.155.19/watchtower/getRandomMessage.php?DeviceID=%@",deviceStr];
                [jsonRetriever httpGetMethodByURL:url];
            }
            else
            {
                //變更tag
                getNewMessage=0;
                
                //加到訊息陣列中
                [plistManager saveDictMessage:(NSDictionary *)jsonObject withinPlist:@"receivedMessage" underFolder:@"watchtower"];
                [_messageTable reloadData];
                
            }
        }
    });
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}


- (IBAction)tappedExitBtn:(id)sender
{
    //返回首頁
    //HomepageVC *homeVC=[[HomepageVC alloc] initWithNibName:@"HomepageVC" bundle:[NSBundle mainBundle]];
    //[self presentViewController:homeVC animated:NO completion:nil];
    
    [_naviVC popViewControllerAnimated:NO];
}

- (IBAction)tappedSendBtn:(id)sender
{
    SendVC *sendVC=[[SendVC alloc] initWithNibName:@"SendVC" bundle:[NSBundle mainBundle]];
    sendVC.whetherReply=NO;
    [_naviVC pushViewController:sendVC animated:NO];
}

- (IBAction)tappedExploreBtn:(id)sender {
    
    [_myAudioPlayer stop];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"playBGM"];

    TelescopeVC *telescopeVC=[[TelescopeVC alloc] initWithNibName:@"TelescopeVC" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:telescopeVC animated:NO];
}

- (IBAction)tappedMemoryBtn:(id)sender {
    EarthVC *earthVC=[[EarthVC alloc] initWithNibName:@"EarthVC" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:earthVC animated:NO];
}

- (IBAction)tappedRespondBtn:(id)sender
{
    ResponseVC *replyVC=[[ResponseVC alloc] initWithNibName:@"ResponseVC" bundle:[NSBundle mainBundle]];
    [_naviVC pushViewController:replyVC animated:NO];
}

# pragma mark - TableView 控制相關方法

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    _messageArray=[plistManager getRootArrayOfPlist:@"receivedMessage" underFolder:@"watchtower"];
    NSInteger num=[_messageArray count];
    _countLabel.text=[NSString stringWithFormat:@"%ld/12",(long)num];
    
    if(num==0){
        _emptyHint.hidden=NO;
        _countLabel.hidden=YES;
        _messageTable.hidden=YES;
    }
    return num;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //1.從緩存池中取出cell
    static NSString *ID=@"MessageCellIdentifier";
    MessageCell *cell=[tableView dequeueReusableCellWithIdentifier:ID];
    
    //2.若緩存池沒有cell則新創建一個
    if(cell==nil){
        [[NSBundle mainBundle] loadNibNamed:@"MessageCell" owner:self options:nil];
        cell = _messageCell;
        _messageCell = nil;
    }
    
    //3.傳遞模型數據
    cell.backgroundColor = [UIColor clearColor];
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor clearColor];
    [cell setSelectedBackgroundView:bgColorView];
    
    NSDictionary *dict=[_messageArray objectAtIndex:indexPath.row];
    cell.title=[dict objectForKey:@"Title"];
    NSLog(@"cell:%@",cell);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"row: %d",(int)indexPath.row);
    
    //navi
    BrowseVC *browseVC=[[BrowseVC alloc] initWithNibName:@"BrowseVC" bundle:[NSBundle mainBundle]];
    
    //獲取訊息內容
    NSDictionary *dict=[_messageArray objectAtIndex:indexPath.row];
    browseVC.messageDict=dict;
    //browseVC.Title=[dict objectForKey:@"Title"];
    //browseVC.Content=[dict objectForKey:@"Content"];
    
    //跳轉
    [_naviVC pushViewController:browseVC animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) {
        self.view = nil;
    }
}


@end
