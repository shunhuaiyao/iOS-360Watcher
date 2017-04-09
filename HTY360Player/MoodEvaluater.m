//
//  MoodEvaluater.m
//  360Project
//
//  Created by Rachel Yeh on 2017/3/20.
//  Copyright © 2017年 Hanton. All rights reserved.
//

#import "MoodEvaluater.h"
#import "PlistAccessManager.h"

@interface MoodEvaluater ()
{
    //NSArray *typeArray
}
@end

@implementation MoodEvaluater

-(NSString *) getNextVideoAccordingToMoodRecord: (NSString *) category
{
    //從plist獲取該情緒類別的紀錄
    PlistAccessManager *plistManager=[[PlistAccessManager alloc]init];
    NSArray *moodArray=[NSArray arrayWithArray:[plistManager getRootArrayOfPlist:@"MoodRecord" underFolder:@"watchtower"]];
    
    NSArray *typeArray=[NSArray array];
    NSNumber *total;
    for(NSDictionary *dict in moodArray)
    {
        if([[dict objectForKey:@"moodGroup"]isEqualToString:category]){
            typeArray=[dict objectForKey:@"videoTypeArray"];
            total=[dict objectForKey:@"totalVideoCount"];
            break;
        }
    }
    
    //計算每個影片類別的核可度
    NSMutableArray *approvability=[self calculateApprovability:typeArray withTotalCount:total];
    //比較陣列內的元素，找出數值高者，裁決播放的影片類型
    NSNumber *electedIndex=[self determineElectedVideoType:approvability];
    NSString *videoTypeStr=[NSString stringWithString:[[typeArray objectAtIndex:[electedIndex intValue]]objectForKey:@"videoType"]];
    NSLog(@"selected video type:%@",videoTypeStr);
    return videoTypeStr;
}

-(NSMutableArray *) calculateApprovability: (NSArray *) array withTotalCount: (NSNumber *) total
{
    NSMutableArray *scoreArray=[NSMutableArray arrayWithCapacity:5];
    for(NSDictionary *dict in array)
    {
        NSNumber *likeRate=[dict objectForKey:@"likeRate"];
        NSNumber *dislikeRate=[dict objectForKey:@"dislikeRate"];
        
        //1．得出每個影片類別適合播放的機率（核可度）
        //比較判別正評與負評
        NSNumber *score;
        if(likeRate > dislikeRate) //正評多
            score=[NSNumber numberWithFloat:0.9];
        else if(likeRate <dislikeRate) //負評多
            score=[NSNumber numberWithFloat:0.1];
        else //平手
        {
            //比較觀看時長
            NSNumber *average=[dict objectForKey:@"watchTimeAverage"];
            if([average floatValue]>0)
                score=[NSNumber numberWithFloat:0.9];
            else if ([average floatValue]<0)
                score=[NSNumber numberWithFloat:0.1];
            else
                score=[NSNumber numberWithFloat:0.5];
        }
        
        //2．乘上調整係數，令播放次數較低者有較高的機會能在下一輪播放
        //計算該類別的播放率，（1-播放率）即為調整係數
        NSNumber *playTimes=[NSNumber numberWithUnsignedInteger:[[dict objectForKey:@"videoList"] count]];
        NSNumber *share;
        if([playTimes intValue]!=0)
            share=[NSNumber numberWithFloat:(float)[playTimes intValue]/[total intValue]];
        else
            share=[NSNumber numberWithFloat:0.0];

        NSNumber *coefficient= [NSNumber numberWithFloat:1-[share floatValue]];
        
        //原核可度乘上調整係數
        NSNumber *adjustedScore=[NSNumber numberWithFloat:[score floatValue]*[coefficient floatValue]];
        [scoreArray addObject:adjustedScore];
    }
    NSLog(@"adjustedScore: %@",scoreArray);
    return scoreArray;
}

-(NSNumber *) determineElectedVideoType: (NSMutableArray *) array
{
    float value=0.0;
    NSMutableArray *tempArray=[NSMutableArray array];
    
    //得出陣列中的最高數值
    for(int i=0 ; i<5 ; i++){
        float num=[[array objectAtIndex:i] floatValue];
        if(num>value)
            value=num;
    }
    
    //迭代看哪些索引的具有此數值（至少一個）
    for(int i=0 ; i<5 ; i++){
        float num=[[array objectAtIndex:i] floatValue];
        if(num==value)
            [tempArray addObject:[NSNumber numberWithInt:i]];
    }
    
    //決定播放哪個類別的影片
    if([tempArray count]==1) //只有單一者，確定選此影片類型
        return [tempArray objectAtIndex:0];
    else if([tempArray count]>1) //有複數者，隨機選擇其中一者
    {
        int r = arc4random() % [tempArray count];
        return [tempArray objectAtIndex:r];
    }
    else
        NSLog(@"計算核可度發生錯誤！");
    return [NSNumber numberWithInt:-1];
}

-(BOOL) checkIfVideoAmountIsEnough:(int)amount withType: (NSString *)type
{
    //從plist獲取影片紀錄
    PlistAccessManager *plistManager=[[PlistAccessManager alloc]init];
    NSArray *typeArray=[NSArray arrayWithArray:[plistManager getRootArrayOfPlist:@"VideoRecord" underFolder:@"watchtower"]];
    
    //找出影片類別為type的陣列，計算其數目
    int count=0;
    for(NSDictionary *dict in typeArray)
    {
        if([[dict objectForKey:@"videoType"]isEqualToString:type])
        {
            count+=[[dict objectForKey:@"videoList"] count];
            break;
        }
    }
    NSLog(@"watched video count:%d",count);
    
    //若看過此類型的影片數量少於server上所提供的總數，則傳true，反之傳false
    if(amount>count)
        return YES;
    else
        return NO;
}

-(BOOL) checkIfAlreadySeenVideoId:(NSString *) ID withType: (NSString *)type
{
    //從plist獲取影片紀錄
    PlistAccessManager *plistManager=[[PlistAccessManager alloc]init];
    NSArray *typeArray=[NSArray arrayWithArray:[plistManager getRootArrayOfPlist:@"VideoRecord" underFolder:@"watchtower"]];
    
    //找出影片類別為type的陣列，找尋是否有看過同ID的影片
    BOOL isFound=NO;
    for(NSDictionary *dict in typeArray)
    {
        if([[dict objectForKey:@"videoType"]isEqualToString:type])
        {
            NSArray *videoList=[dict objectForKey:@"videoList"];
            for(NSDictionary *dict2 in videoList){
                if([[dict2 objectForKey:@"ID"]isEqualToString:ID]){
                    isFound=YES;
                    break;
                }
            }
            break;
        }
    }
    
    //若發現已看過此影片，回傳true，反之傳false
    if(isFound)
        return YES;
    else
        return NO;
}

-(void) storeVideoInfo:(NSDictionary *)videoInfo withType:(NSString *)type
{
    //從plist獲取影片紀錄
    PlistAccessManager *plistManager=[[PlistAccessManager alloc]init];
    NSMutableArray *typeArray=[NSMutableArray arrayWithArray:[plistManager getRootArrayOfPlist:@"VideoRecord" underFolder:@"watchtower"]];
    
    //找出影片類別為type的陣列，加入新影片資訊
    for(NSMutableDictionary *dict in typeArray)
    {
        if([[dict objectForKey:@"videoType"]isEqualToString:type])
        {
            NSMutableArray *array=[NSMutableArray arrayWithArray:[dict objectForKey:@"videoList"]];
            [array addObject:videoInfo];
            [dict setObject:array forKey:@"videoList"];
            break;
        }
    }
    
    //覆蓋原plist
    [plistManager saveAndCoverArray:typeArray intoPlist:@"VideoRecord" underFolder:@"watchtower"];
    NSLog(@"寫入新的typeArray：%@",typeArray);
}

-(NSDictionary *) getVideoInfoByID: (NSString *) Id
{
    NSString *firstLetter=[NSString stringWithString:[Id substringToIndex:1]];
    NSString *type=[NSString string];

    //由ID識別影片類型
    if ([firstLetter isEqualToString:@"N"])
        type=@"Nature";
    else if([firstLetter isEqualToString:@"C"])
        type=@"City";
    else if([firstLetter isEqualToString:@"O"])
        type=@"Observing";
    else if([firstLetter isEqualToString:@"R"])
        type=@"Riding";
    else if([firstLetter isEqualToString:@"S"])
        type=@"Strolling";
    
    //從plist獲取影片紀錄
    PlistAccessManager *plistManager=[[PlistAccessManager alloc]init];
    NSArray *typeArray=[NSArray arrayWithArray:[plistManager getRootArrayOfPlist:@"VideoRecord" underFolder:@"watchtower"]];
    
    //找出影片類別為type的陣列，找尋該ID的影片資訊
    NSDictionary *theDict=[NSDictionary dictionary];
    for(NSDictionary *dict in typeArray)
    {
        if([[dict objectForKey:@"videoType"]isEqualToString:type])
        {
            NSArray *videoList=[dict objectForKey:@"videoList"];
            for(NSDictionary *dict in videoList){
                if([[dict objectForKey:@"ID"]isEqualToString:Id]){
                    theDict=dict;
                    break;
                }
            }
            break;
        }
    }
    return theDict;
}

-(NSDictionary *) getVideoInfoByPuzzleNum: (int) num
{
    //從plist獲取影片紀錄
    PlistAccessManager *plistManager=[[PlistAccessManager alloc]init];
    NSArray *typeArray=[NSArray arrayWithArray:[plistManager getRootArrayOfPlist:@"VideoRecord" underFolder:@"watchtower"]];
    
    
    //遍歷所有類型的影片，找出與拼圖編號相符者
    NSDictionary *targetDict=[NSDictionary dictionary];
    for(NSDictionary *dict in typeArray)
    {
        NSArray *videoList=[dict objectForKey:@"videoList"];
        
        for(NSDictionary *dict2 in videoList)
        {
            if([[dict2 objectForKey:@"PuzzleNum"]intValue]==num)
            {
                targetDict=dict2;
                break;
            }
            break;
        }
    }
    return targetDict;
}

@end
