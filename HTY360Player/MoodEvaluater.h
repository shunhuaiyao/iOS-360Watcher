//
//  MoodEvaluater.h
//  360Project
//
//  Created by Rachel Yeh on 2017/3/20.
//  Copyright © 2017年 Hanton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoodEvaluater : NSObject

-(NSString *) getNextVideoAccordingToMoodRecord: (NSString *) category;
-(BOOL) checkIfVideoAmountIsEnough:(int)amount withType: (NSString *)type;
-(BOOL) checkIfAlreadySeenVideoId:(NSString *) ID withType: (NSString *)type;
-(void) storeVideoInfo:(NSDictionary *)videoInfo withType:(NSString *)type;
-(NSDictionary *) getVideoInfoByID: (NSString *) Id;
-(NSDictionary *) getVideoInfoByPuzzleNum: (int) num;

@end
