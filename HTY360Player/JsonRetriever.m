//
//  JsonRetriever.m
//  iutour
//
//  Created by cialab1 on 2016/7/26.
//  Copyright © 2016年 cialab1. All rights reserved.
//

#import "JsonRetriever.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation JsonRetriever

#pragma mark - 上網抓資料方法


-(void) httpGetMethodByURL: (NSString *) URL
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URL]];
     
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          //a.以字串形式獲得JSON檔並印出
          NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
          
          //做特殊字元（引號）處理
          requestReply=[requestReply stringByReplacingOccurrencesOfString:@"\\\'" withString:@"\'"];
          NSLog(@"requestReply: %@", requestReply);
          NSData* changedData = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
          
          //b.以字典形式獲得JSON檔並回傳
          NSError *Error;
          _jsonObj=[NSJSONSerialization JSONObjectWithData:changedData options:NSJSONReadingAllowFragments error:&Error];
          
          if (!_jsonObj)
              NSLog(@"%@", [Error localizedDescription]);
          else
              [self.delegate getJsonData:_jsonObj];

      }] resume];
}

-(void) httpPostMethodByURL: (NSString *) URL withObject: (id)object
{
    //設定URL
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URL]];
    
    //設定Body內容
    NSData *postData;
    if ([object isKindOfClass:[NSString class]]) //若為字串
    {
        postData = [object dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    }
    else if([object isKindOfClass:[NSData class]]) //若為DATA型態
    {
        postData=(NSData *)object;
    }
    else //為其他資料型態，如字典或陣列等
    {
        NSLog(@"dict format");
        NSError *error;
        postData = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    [request setHTTPMethod:@"POST"];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        //a.以字串形式獲得JSON檔並印出
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        //做特殊字元（雙引號）處理
        requestReply=[requestReply stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        NSLog(@"requestReply: %@", requestReply);
        NSData* changedData = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
        
        //b.以字典形式獲得JSON檔並回傳
        NSError *Error;
        _jsonObj=[NSJSONSerialization JSONObjectWithData:changedData options:NSJSONReadingAllowFragments error:&Error];
        
        if (!_jsonObj)
        {
            NSLog(@"%@", [Error localizedDescription]);
            [self.delegate getJsonData:@"received but cannot read!"];
        }
        else
            [self.delegate getJsonData:_jsonObj];
        
    }] resume];
    
}

-(void) uploadBinary:(NSData * ) binary withURL:(NSString * ) urlAddress withAttName:(NSString *) attname andFilename:(NSString *) filename{
    
    NSURL *theURL = [NSURL URLWithString:urlAddress];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:20.0f];
    [theRequest setHTTPMethod:@"POST"];
    NSString *boundary = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *boundaryString = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [theRequest addValue:boundaryString forHTTPHeaderField:@"Content-Type"];
    
    // define boundary separator...
    NSString *boundarySeparator = [NSString stringWithFormat:@"--%@\r\n", boundary];
    
    //adding the body...
    NSMutableData *postBody = [NSMutableData data];
    
    [postBody appendData:[boundarySeparator dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",attname, filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:binary];
    
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r \n",boundary]
                          dataUsingEncoding:NSUTF8StringEncoding]];
    [theRequest setHTTPBody:postBody];
    
    
    //[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:theRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          //a.以字串形式獲得JSON檔並印出
          NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
          NSLog(@"requestReply: %@", requestReply);
          
          //b.以字典形式獲得JSON檔並回傳
          NSError *Error;
          _jsonObj=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&Error];
          
          if (!_jsonObj)
          {
              NSLog(@"%@", [Error localizedDescription]);
              [self.delegate getJsonData:@"received but cannot read!"];
          }
          else
              [self.delegate getJsonData:_jsonObj];
          
      }] resume];
}

- (NSData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
                             paths:(NSArray *)paths
                         fieldName:(NSString *)fieldName
{
    NSMutableData *httpBody = [NSMutableData data];
    
    // add params (all params are strings)
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // add audio data
    for (NSString *path in paths) {
        NSString *filename  = [path lastPathComponent];
        NSData   *data      = [NSData dataWithContentsOfFile:path];
        NSString *mimetype  = [self mimeTypeForPath:path];
        
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:data];
        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return httpBody;
}

- (NSString *)mimeTypeForPath:(NSString *)path
{
    // get a mime type for an extension using MobileCoreServices.framework
    
    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    assert(UTI != NULL);
    
    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    assert(mimetype != NULL);
    
    CFRelease(UTI);
    
    return mimetype;
}

- (NSString *)generateBoundaryString
{
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
    
    // if supporting iOS versions prior to 6.0, you do something like:
    //
    // // generate boundary string
    // //
    // adapted from http://developer.apple.com/library/ios/#samplecode/SimpleURLConnections
    //
    // CFUUIDRef  uuid;
    // NSString  *uuidStr;
    //
    // uuid = CFUUIDCreate(NULL);
    // assert(uuid != NULL);
    //
    // uuidStr = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
    // assert(uuidStr != NULL);
    //
    // CFRelease(uuid);
    //
    // return uuidStr;
}


@end
