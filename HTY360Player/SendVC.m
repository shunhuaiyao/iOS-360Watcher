//
//  SendVC.m
//  360Project
//
//  Created by Rachel Yeh on 2017/1/24.
//  Copyright © 2017年 Hanton. All rights reserved.
//

#import "SendVC.h"
#import "NaviVC.h"
#import "JsonRetriever.h"
#import "PlistAccessManager.h"
#import "IntercomVC.h"

@interface SendVC () <UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate, JsonRetrieverDelegate>
{
    PlistAccessManager *plistManager;
}
@end

@implementation SendVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    plistManager=[[PlistAccessManager alloc]init];
    
    //加入文字框的placeholder
    self.titleTextField.delegate = self;
    self.contentTextView.delegate = self;
    
    //設置鍵盤顏色
    self.titleTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
    self.contentTextView.keyboardAppearance = UIKeyboardAppearanceAlert;
    
    //若為回覆模式，需自訂標題，並取消鍵盤響應
    if(_whetherReply)
    {
        self.titleTextField.enabled=NO;
        self.titleTextField.text=[NSString stringWithFormat:@"RE：%@",_replyTitle];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (IBAction)tappedSendBtn:(id)sender
{
    if([self.titleTextField.text isEqual: @"輸入標題"] || [self.titleTextField.text isEqual: @""]){
        //使用者未填標題
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未填標題"
                                                            message:@"請填入標題方能寄出"
                                                           delegate:nil
                                                  cancelButtonTitle:@"確定"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else if([self.contentTextView.text isEqual: @"輸入文字內容..."] || [self.contentTextView.text isEqual: @""]){
        //使用者未填內容
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未填訊息內容"
                                                            message:@"請填入訊息內容方能寄出"
                                                           delegate:nil
                                                  cancelButtonTitle:@"確定"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        //彈出視窗確認是否寄出
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"寄送確認"
                                                    message:@"是否確定送出？送出後將無法更改內容"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"確定",nil];
        [alertView show];
    }
}

- (IBAction)tappedExitBtn:(id)sender
{
    self.titleTextField.text=@"";
    self.contentTextView.text=@"";

    NaviVC *naviVC=self.navigationController;
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)getJsonData:(id)jsonObject
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //NSString *transformedStr=[NSString stringWithString:(NSString *)jsonObject];
        //transformedStr=[transformedStr stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
        NSLog(@"寄送結果：%@",jsonObject);
        
        self.titleTextField.text=@"";
        self.contentTextView.text=@"";
        
        //[self.navigationController popViewControllerAnimated:NO];
        int num;
        if(_whetherReply)
        {
            NSLog(@"回覆寄送結果：%@",jsonObject);
            num=3;
        }
        else
        {
            NSLog(@"一般寄送結果：%@",jsonObject);
            
            num=2;
            
            //存下每一則自己發出的訊息
            [plistManager saveDictMessage:(NSDictionary *)jsonObject withinPlist:@"writtenMessage" underFolder:@"watchtower"];
        }

        IntercomVC *intercomVC=[[self.navigationController viewControllers]objectAtIndex:[[self.navigationController viewControllers]count]-num];
        intercomVC.whetherSend=YES;
        [self.navigationController popToViewController:intercomVC animated:NO];
    });
}

#pragma mark - 文字框相關delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        //使用者確定寄出
        NSLog(@"send message");
        
        //獲取裝置ID
        NSString *deviceID=[[plistManager getRootArrayOfPlist:@"deviceID" underFolder:@"watchtower"]objectAtIndex:0];
        
        if(!_whetherReply) //寄信模式
        {
            //組成字串
            NSString *postString=[NSString stringWithFormat:@"Title=%@&Content=%@&DeviceID=%@",self.titleTextField.text,self.contentTextView.text,deviceID];
            NSLog(@"postString:%@",postString);
        
            //使用post方法傳送資料
            JsonRetriever *retriever=[[JsonRetriever alloc]init];
            retriever.delegate=self;
            [retriever httpPostMethodByURL:@"http://52.185.155.19/watchtower/addMessage.php" withObject:postString];
        }
        else //回覆模式
        {
            //組成字串
            NSString *postString=[NSString stringWithFormat:@"Reference=%@&Content=%@&DeviceID=%@",self.replyID,self.contentTextView.text,deviceID];
            NSLog(@"postString:%@",postString);
            
            //使用post方法傳送資料
            JsonRetriever *retriever=[[JsonRetriever alloc]init];
            retriever.delegate=self;
            [retriever httpPostMethodByURL:@"http://52.185.155.19/watchtower/replyMessage.php" withObject:postString];
        
        }
    }
}

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@"輸入標題"]) {
        textField.text = @"";
        textField.textColor = [UIColor whiteColor]; //optional
    }
    [textField becomeFirstResponder];
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""]) {
        textField.text = @"輸入標題";
        textField.textColor = [UIColor whiteColor]; //optional
    }
    [textField resignFirstResponder];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"輸入文字內容..."]) {
        textView.text = @"";
        textView.textColor = [UIColor whiteColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"輸入文字內容...";
        textView.textColor = [UIColor whiteColor]; //optional
    }
    [textView resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) {
        self.view = nil;
    }
}


@end
