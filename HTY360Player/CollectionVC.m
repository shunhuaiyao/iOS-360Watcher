//
//  CollectionVC.m
//  360Project
//
//  Created by Rachel Yeh on 2016/12/12.
//  Copyright © 2016年 Hanton. All rights reserved.
//

#import "CollectionVC.h"
#import "HomepageVC.h"
#import "IntercomVC.h"
#import "NaviVC.h"

@interface CollectionVC ()

@end

@implementation CollectionVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    //NSLog(@"VCS:%@",[self.navigationController viewControllers]);
    NaviVC *naviVC=self.navigationController;
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (IBAction)tappedMailboxBtn:(id)sender
{
    IntercomVC *intercomVC=[[IntercomVC alloc] initWithNibName:@"IntercomVC" bundle:[NSBundle mainBundle]];
    [self presentViewController:intercomVC animated:NO completion:nil];
}

@end
