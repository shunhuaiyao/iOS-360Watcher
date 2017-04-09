//
//  PlistAccessControl.m
//  TopicResearchCustom
//
//  Created by cialab1 on 2015/12/12.
//  Copyright (c) 2015年 Yeh Rachel. All rights reserved.
//

#import "PlistAccessManager.h"

@implementation PlistAccessManager

-(BOOL) buildFolder: (NSString *) folderName
{
    //建立目錄專用此app的資料夾
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path=[[paths objectAtIndex:0] stringByAppendingPathComponent:folderName];
    
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])	//Does directory already exist?
    {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error])
        {
            NSLog(@"Create directory error: %@", error);
            return NO;
        }
    }
    return YES;
}

-(NSArray *) listAllFileUnderFolder: (NSString *) folderName
{
    //查看目前所有的file
    NSLog(@"LISTING ALL FILES FOUND");
    
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path=[[paths objectAtIndex:0] stringByAppendingPathComponent:folderName];
    
    int Count;
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (Count = 0; Count < (int)[directoryContent count]; Count++)
    {
        NSLog(@"File %d: %@", (Count + 1), [directoryContent objectAtIndex:Count]);
    }
    return directoryContent;
}

-(BOOL) checkIfCertainFileExist:(NSString *)fileName underFolder:(NSString *)folderName
{
    //進一步查看指定file是否存在該資料夾下
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path=[[paths objectAtIndex:0] stringByAppendingPathComponent:folderName];
    path=[path stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSLog(@"File does exist");
        return YES;
    }
    else
    {
        NSLog(@"File does not exist");
        return NO;
    }
}

-(void) createPlistFileWithRootArray:(NSString *)plistName underFolder:(NSString *)folderName
{
    //從新建檔
    NSString *path;
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path=[[paths objectAtIndex:0] stringByAppendingPathComponent:folderName];
    path=[path stringByAppendingPathComponent:plistName];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath: path]) //若該路徑確實存在plist檔案
    {
        //檢查檔案是否為空
        NSDictionary *attributes=[fileManager attributesOfItemAtPath:path error:nil];
        unsigned long long size=[attributes fileSize];
        
        if (attributes && size == 0) { //file exists, but is empty.
            NSString *error;
            NSMutableArray *someArray=[[NSMutableArray alloc]init];
            NSData *plistData=[NSPropertyListSerialization  dataFromPropertyList:someArray
                                                            format:NSPropertyListXMLFormat_v1_0
                                                            errorDescription:&error];
            if(plistData)
            {
                [plistData writeToFile:path atomically:YES];
                NSLog(@"Plist with an array-rooted object has been created.");
            }
        }
        else //file isn't empty, it'd already been initialized with an array before
        {
            NSMutableArray *someArray=[[NSMutableArray alloc]initWithContentsOfFile:path];
            NSLog(@"rootArray原本已存在的內容為：%@",someArray);
        }
    }
    else //一開始就不存在檔案，需從頭創建
    {
        NSString *error;
        NSMutableArray *someArray=[[NSMutableArray alloc]init];
        NSData *plistData=[NSPropertyListSerialization  dataFromPropertyList:someArray
                                                        format:NSPropertyListXMLFormat_v1_0
                                                        errorDescription:&error];
        if(plistData)
        {
            [plistData writeToFile:path atomically:YES];
            NSLog(@"Plist with an array-rooted object has been created.");
        }
    }
}

-(NSArray *) getRootArrayOfPlist:(NSString *)plistName underFolder:(NSString *)folderName
{
    NSString *path;
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path=[[paths objectAtIndex:0] stringByAppendingPathComponent:folderName];
    path=[path stringByAppendingPathComponent:plistName];
    
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:path];
    NSArray *temp = (NSArray *)[NSPropertyListSerialization
                                propertyListFromData:plistXML
                                mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                format:&format
                                errorDescription:&errorDesc];
    if (!temp) {
        NSLog(@"Error reading plist: %@, format: %lu", errorDesc, format);
    }
    NSLog(@"%@", temp);
    
    return temp;
}

-(BOOL) saveDictMessage:(NSDictionary*)dict withinPlist:(NSString *)plistName underFolder:(NSString *)folderName
{
    NSString *path;
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path=[[paths objectAtIndex:0] stringByAppendingPathComponent:folderName];
    path=[path stringByAppendingPathComponent:plistName];
    
    NSMutableArray *getarr=[[NSMutableArray alloc] initWithContentsOfFile:path];
    NSLog(@"before getarr:%@",getarr);
    [getarr addObject: dict];
    NSLog(@"after getarr:%@",getarr);
    
    NSString *error;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:getarr
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    
    if(plistData) {
        BOOL check=[plistData writeToFile:path atomically:YES];
        NSLog(@"new message appended? %d",check);
        
        if (check==YES) {
            return YES; //順利存入訊息
        } else {
            return NO; //存入訊息失敗
        }
    }
    else
        return NO;
}

-(BOOL) saveAndCoverArray:(NSArray *)array intoPlist:(NSString *)plistName underFolder:(NSString *)folderName
{
    NSString *path;
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path=[[paths objectAtIndex:0] stringByAppendingPathComponent:folderName];
    path=[path stringByAppendingPathComponent:plistName];

    NSString *error;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:array
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    
    if(plistData) {
        BOOL check=[plistData writeToFile:path atomically:YES];
        NSLog(@"new message appended? %d",check);
        
        if (check==YES) {
            return YES; //順利存入訊息
        } else {
            return NO; //存入訊息失敗
        }
    }
    else
        return NO;
}

-(BOOL) deletePlist:(NSString *)plistName underFolder:(NSString *)folderName
{
    NSString *path;
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path=[[paths objectAtIndex:0] stringByAppendingPathComponent:folderName];
    path=[path stringByAppendingPathComponent:plistName];
        
    NSError *error;
    if(![[NSFileManager defaultManager] removeItemAtPath:path error:&error])
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
        return NO;
    }
    NSLog(@"Delete plist file: %@",plistName);
    return YES;
}

@end
