//
//  PlistAccessManager.h
//  TopicResearchCustom
//
//  Created by cialab1 on 2015/12/12.
//  Copyright (c) 2015年 Yeh Rachel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlistAccessManager : NSObject

-(BOOL) buildFolder: (NSString *) folderName;
-(NSArray *) listAllFileUnderFolder: (NSString *) folderName;
-(BOOL) checkIfCertainFileExist:(NSString *)fileName underFolder:(NSString *)folderName;
-(void) createPlistFileWithRootArray:(NSString *)plistName underFolder:(NSString *)folderName;
-(NSArray *) getRootArrayOfPlist:(NSString *)plistName underFolder:(NSString *)folderName;
-(BOOL) saveAndCoverArray:(NSArray *)array intoPlist:(NSString *)plistName underFolder:(NSString *)folderName;
-(BOOL) saveDictMessage:(NSDictionary*)dict withinPlist:(NSString *)plistName underFolder:(NSString *)folderName;
-(BOOL) deletePlist:(NSString *)plistName underFolder:(NSString *)folderName;

@end
