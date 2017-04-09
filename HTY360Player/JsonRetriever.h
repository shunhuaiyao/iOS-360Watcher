//
//  JsonRetriever.h
//  iutour
//
//  Created by cialab1 on 2016/7/26.
//  Copyright © 2016年 cialab1. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JsonRetrieverDelegate <NSObject>

@required
-(void)getJsonData:(id)jsonObject;

@end

@interface JsonRetriever : NSObject
{
    // Delegate to respond back
    id<JsonRetrieverDelegate> __delegate;
}

@property (nonatomic,assign)id delegate;

@property (nonatomic, weak) id jsonObj;

-(void) httpGetMethodByURL: (NSString *) URL;
-(void) httpPostMethodByURL: (NSString *) URL withObject: (id)object;
-(void) uploadBinary:(NSData * ) binary withURL:(NSString * ) urlAddress withAttName:(NSString *) attname andFilename:(NSString *) filename;

@end
