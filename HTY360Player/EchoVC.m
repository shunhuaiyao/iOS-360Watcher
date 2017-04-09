//
//  EchoVC.m
//  360Project
//
//  Created by Rachel Yeh on 2017/2/23.
//  Copyright © 2017年 Hanton. All rights reserved.
//

#import "EchoVC.h"

@interface EchoVC ()

@end

@implementation EchoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

-(void) viewWillAppear:(BOOL)animated
{
    _titleLabel.text=[_messageDict objectForKey:@"Title"];
    _contentLabel.text=[[_messageDict objectForKey:@"Content"] stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
}

- (IBAction)tappedExitBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}
@end
