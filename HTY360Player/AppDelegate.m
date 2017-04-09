//
//  AppDelegate.m
//  HTY360Player
//
//  Created by  on 11/8/15.
//  Copyright © 2015 Hanton. All rights reserved.
//

#import "AppDelegate.h"
#import "HomepageVC.h"
#import "NaviVC.h"
#import "PlistAccessManager.h"
#import "EarthVC.h"

@interface AppDelegate ()
{
    PlistAccessManager *plistManager;
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //建立ViewController
    
    HomepageVC *homepageVC = [[HomepageVC alloc] initWithNibName:@"HomepageVC" bundle:[NSBundle mainBundle]];

    EarthVC *earthVC = [[EarthVC alloc] initWithNibName:@"EarthVC" bundle:[NSBundle mainBundle]];
    earthVC.playTutorialAtFirst=NO;
    
    NaviVC *naviVC=[[NaviVC alloc]initWithRootViewController:homepageVC];
    naviVC.navigationBar.hidden=YES;
    self.window.rootViewController = naviVC;
    [self.window makeKeyAndVisible];
    
    //建立Plist資料夾
    plistManager=[[PlistAccessManager alloc]init];
    [plistManager buildFolder:@"watchtower"];
    [plistManager listAllFileUnderFolder:@"watchtower"];
    
    //創建裝置UUID
    [plistManager createPlistFileWithRootArray:@"deviceID" underFolder:@"watchtower"];
    if([[plistManager getRootArrayOfPlist:@"deviceID" underFolder:@"watchtower"]count]==0)
    {
        //得知為第一次登入app
        earthVC.playTutorialAtFirst=YES;
        
        NSArray *deviceArray=[NSArray arrayWithObject:[[NSUUID UUID] UUIDString]];
        [plistManager saveAndCoverArray:deviceArray intoPlist:@"deviceID" underFolder:@"watchtower"];
    }
    NSLog(@"uuid:%@",[[plistManager getRootArrayOfPlist:@"deviceID" underFolder:@"watchtower"]objectAtIndex:0]);
    
    //創建存取訊息的陣列
    [plistManager createPlistFileWithRootArray:@"receivedMessage" underFolder:@"watchtower"];
    [plistManager createPlistFileWithRootArray:@"receivedReply" underFolder:@"watchtower"];
    [plistManager createPlistFileWithRootArray:@"writtenMessage" underFolder:@"watchtower"];
    
    //加入開啟和關閉時間的字典
    [plistManager createPlistFileWithRootArray:@"TimeRecord" underFolder:@"watchtower"];
    if([[plistManager getRootArrayOfPlist:@"TimeRecord" underFolder:@"watchtower"]count]==0)
    {
        NSMutableDictionary *timeDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"",@"onTime",@"",@"offTime", nil];
        NSArray *timeArray=[NSArray arrayWithObject:timeDict];
        [plistManager saveAndCoverArray:timeArray intoPlist:@"TimeRecord" underFolder:@"watchtower"];
    }

    //加入記錄四大類情緒的字典
    [plistManager createPlistFileWithRootArray:@"MoodRecord" underFolder:@"watchtower"];
    if([[plistManager getRootArrayOfPlist:@"MoodRecord" underFolder:@"watchtower"]count]==0)
    {
        NSArray *categoryArray=[NSArray arrayWithObjects: @"Aggressive", @"Self-Control", @"Embracive", @"Depressive", nil];
        NSArray *videotypeArray=[NSArray arrayWithObjects: @"Nature", @"City", @"Observing", @"Riding", @"Strolling", nil];
        
        NSMutableArray *moodArray=[NSMutableArray array];
        for(int i=0 ; i<4 ; i++) //i作為情緒群組的index
        {
            NSMutableArray *typeArray=[NSMutableArray array];
            for(int j=0; j<5 ; j++) //j作為影片類型的index
            {
                NSMutableDictionary *eachTypeDict=[NSMutableDictionary dictionary];
                [eachTypeDict setObject:[videotypeArray objectAtIndex:j] forKey:@"videoType"];
                [eachTypeDict setObject:[NSNumber numberWithInt:j] forKey:@"typeId"];
                [eachTypeDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"likeRate"];
                [eachTypeDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"dislikeRate"];
                [eachTypeDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"watchTimeAverage"];
                [eachTypeDict setObject:[NSMutableArray array] forKey:@"videoList"];
                
                [typeArray addObject:eachTypeDict]; //依序加入五種影片類型的模板
            }
            
            NSMutableDictionary *eachMoodDict=[NSMutableDictionary dictionary];
            [eachMoodDict setObject:[categoryArray objectAtIndex:i] forKey:@"moodGroup"];
            [eachMoodDict setObject:typeArray forKey:@"videoTypeArray"];
            [eachMoodDict setObject:[NSNumber numberWithInt:0] forKey:@"totalVideoCount"];

            [moodArray addObject:eachMoodDict]; //依序加入四種情緒群組的模板
        }
        [plistManager saveAndCoverArray:moodArray intoPlist:@"MoodRecord" underFolder:@"watchtower"];
    }
    
    //加入記錄觀看影片的字典
    [plistManager createPlistFileWithRootArray:@"VideoRecord" underFolder:@"watchtower"];
    if([[plistManager getRootArrayOfPlist:@"VideoRecord" underFolder:@"watchtower"]count]==0)
    {
        NSArray *videotypeArray=[NSArray arrayWithObjects: @"Nature", @"City", @"Observing", @"Riding", @"Strolling", nil];

        NSMutableArray *typeArray=[NSMutableArray array];
        for(int j=0; j<5 ; j++) //j作為影片類型的index
        {
            NSMutableDictionary *eachTypeDict=[NSMutableDictionary dictionary];
            [eachTypeDict setObject:[videotypeArray objectAtIndex:j] forKey:@"videoType"];
            [eachTypeDict setObject:[NSNumber numberWithInt:j] forKey:@"typeId"];
            [eachTypeDict setObject:[NSMutableArray array] forKey:@"videoList"];
            
            [typeArray addObject:eachTypeDict]; //依序加入五種影片類型的模板
        }
        [plistManager saveAndCoverArray:typeArray intoPlist:@"VideoRecord" underFolder:@"watchtower"];
    }
    
    return YES;
}

-(NSString *) getCurrentTimeString
{
    //現在的時間
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:now];
    NSLog(@"date:%@",dateString);
    return dateString;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"resign active");
    
    NSMutableDictionary *timeDict=[[plistManager getRootArrayOfPlist:@"TimeRecord" underFolder:@"watchtower"]objectAtIndex:0];
    [timeDict setObject:[self getCurrentTimeString] forKey:@"offTime"];

    NSArray *timeArray=[NSArray arrayWithObject:timeDict];
    [plistManager saveAndCoverArray:timeArray intoPlist:@"TimeRecord" underFolder:@"watchtower"];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"active");
    
    NSMutableDictionary *timeDict=[[plistManager getRootArrayOfPlist:@"TimeRecord" underFolder:@"watchtower"]objectAtIndex:0];
    [timeDict setObject:[self getCurrentTimeString] forKey:@"onTime"];
    
    NSArray *timeArray=[NSArray arrayWithObject:timeDict];
    [plistManager saveAndCoverArray:timeArray intoPlist:@"TimeRecord" underFolder:@"watchtower"];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
