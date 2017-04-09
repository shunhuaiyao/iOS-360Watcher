//
//  LettersViewController.m
//  360Project
//
//  Created by Rachel Yeh on 2016/12/12.
//  Copyright © 2016年 Hanton. All rights reserved.
//

#import "LettersVC.h"
#import "HomepageVC.h"
#import "TZKeyboardPop.h"
#import "NaviVC.h"

@interface LettersVC ()
{
    TZKeyboardPop *_keyboard;
    NaviVC *_naviVC;
}
@end

@implementation LettersVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contentView.hidden=YES;
    _naviVC=self.navigationController;
    
    //鍵盤相關
    _keyboard = [[TZKeyboardPop alloc] initWithView:self.view];
    //_keyboard.delegate = self;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)showContentWithDuration:(NSTimeInterval)duration {
    self.contentView.alpha = 0.0;
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
                         self.contentView.alpha = 1.0f;
                     }
                     completion:^(BOOL finished){
                         if(finished)
                             self.contentView.hidden=NO;
                     }];
    
}

- (IBAction)tappedWriteBtn:(id)sender
{
    [_keyboard showKeyboard];
    [self showContentWithDuration:1];
}

- (IBAction)tappedExitBtn:(id)sender
{
    //返回首頁
    [self.navigationController popViewControllerAnimated:NO];
    //HomepageVC *homeVC=[[HomepageVC alloc] initWithNibName:@"HomepageVC" bundle:[NSBundle mainBundle]];
    //[self presentViewController:homeVC animated:NO completion:nil];
}

- (IBAction)tappedSendBtn:(id)sender
{
    //返回首頁
    [self.navigationController popViewControllerAnimated:NO];
    //HomepageVC *homeVC=[[HomepageVC alloc] initWithNibName:@"HomepageVC" bundle:[NSBundle mainBundle]];
    //[self presentViewController:homeVC animated:NO completion:nil];
    
    
}

/*- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![self.writeButton isFirstResponder]) {
        [self.writeButton becomeFirstResponder];
    }
}*/

@end
