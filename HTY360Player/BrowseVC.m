//
//  BrowseVC.m
//  360Project
//
//  Created by Rachel Yeh on 2017/2/23.
//  Copyright © 2017年 Hanton. All rights reserved.
//

#import "BrowseVC.h"
#import "SendVC.h"
#import "IntercomVC.h"

@interface BrowseVC () <UIAlertViewDelegate>
{
    BOOL collectMode;
}
@end

@implementation BrowseVC 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    collectMode=YES;
}

-(void) viewWillAppear:(BOOL)animated
{
    _titleLabel.text=[_messageDict objectForKey:@"Title"];
    _contentLabel.text=[[_messageDict objectForKey:@"Content"] stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
}

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

- (IBAction)tappedCollectBtn:(id)sender
{
    if(collectMode)
    {
        //彈出視窗確認是否取消收藏
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否取消收藏"
                                                        message:@"若不收藏信件，信件將會自信匣中刪除"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"確定",nil];
        alertView.tag=0;
        [alertView show];
    }
    else
    {
        collectMode=YES;
        _starBtn.imageView.image=[UIImage imageNamed:@"fullstar"];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        if(alertView.tag==0)
        {
            collectMode=NO;
            _starBtn.imageView.image=[UIImage imageNamed:@"hollowstar"];
        }
        else if(alertView.tag==1)
        {
            IntercomVC *intercomVC=[[self.navigationController viewControllers]objectAtIndex:[[self.navigationController viewControllers]count]-2];
            intercomVC.whetherInspect=YES;
            [self.navigationController popToViewController:intercomVC animated:NO];
        }
    }
}


- (IBAction)tappedReplyBtn:(id)sender
{
    SendVC *sendVC=[[SendVC alloc] initWithNibName:@"SendVC" bundle:[NSBundle mainBundle]];
    sendVC.whetherReply=YES;
    sendVC.replyTitle=[_messageDict objectForKey:@"Title"];
    sendVC.replyID=[_messageDict objectForKey:@"MID"];
    [self.navigationController pushViewController:sendVC animated:NO];
}

- (IBAction)tappedExitBtn:(id)sender
{
    if(!collectMode)
    {
        IntercomVC *intercomVC=[[self.navigationController viewControllers]objectAtIndex:[[self.navigationController viewControllers]count]-2];
        intercomVC.deleteMID=[_messageDict objectForKey:@"MID"];
    }
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)tappedReportBtn:(id)sender
{
    //彈出視窗確認是否取消收藏
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否舉報此信件"
                                                        message:@"若發現內容中有不當用詞或侮辱的意圖，可協助舉報，官方將進行查驗"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"確定",nil];
    alertView.tag=1;
    [alertView show];
}

@end
