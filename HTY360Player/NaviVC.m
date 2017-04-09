//
//  naviVC.m
//  360Project
//
//  Created by Rachel Yeh on 2016/12/12.
//  Copyright © 2016年 Hanton. All rights reserved.
//

#import "NaviVC.h"

@interface NaviVC ()

@end

@implementation NaviVC

- (void)viewDidLoad {
    [super viewDidLoad];
   // _withNotification=NO;
    _pushDirection=1;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    UIView *theWindow = self.view ;
    if( animated ) {
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.45f];
        [animation setType:kCATransitionPush];
        
        if(_pushDirection==1) //向上
            [animation setSubtype:kCATransitionFromBottom];
        else if(_pushDirection==2) //向右
            [animation setSubtype:kCATransitionFromLeft];
        else if(_pushDirection==3) //向下
            [animation setSubtype:kCATransitionFromTop];
        else if(_pushDirection==4) //向左
            [animation setSubtype:kCATransitionFromRight];
        
        
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [[theWindow layer] addAnimation:animation forKey:@""];
    }
    
    //make sure we pass the super "animated:NO" or we will get both our
    //animation and the super's animation
    [super pushViewController:viewController animated:NO];
    
}

-(NSArray *) popToViewController: (UIViewController *)viewController animated:(BOOL)animated;
{
    UIView *theWindow = self.view ;
    if( animated ) {
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.45f];
        [animation setType:kCATransitionPush];
        
        if(_pushDirection==1) //向上
            [animation setSubtype:kCATransitionFromTop];
        else if(_pushDirection==2) //向左
            [animation setSubtype:kCATransitionFromRight];
        else if(_pushDirection==3) //向下
            [animation setSubtype:kCATransitionFromBottom];
        else if(_pushDirection==4) //向右
            [animation setSubtype:kCATransitionFromLeft];
        
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [[theWindow layer] addAnimation:animation forKey:@""];
    }
    return [super popToViewController:viewController animated:NO];
}

-(NSArray *) popToRootViewControllerAnimated:(BOOL)animated
{
    UIView *theWindow = self.view ;
    if( animated ) {
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.45f];
        [animation setType:kCATransitionPush];
        
        if(_pushDirection==1) //向上
            [animation setSubtype:kCATransitionFromTop];
        else if(_pushDirection==2) //向左
            [animation setSubtype:kCATransitionFromRight];
        else if(_pushDirection==3) //向下
            [animation setSubtype:kCATransitionFromBottom];
        else if(_pushDirection==4) //向右
            [animation setSubtype:kCATransitionFromLeft];
        
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [[theWindow layer] addAnimation:animation forKey:@""];
    }
    return [super popToRootViewControllerAnimated:NO];
    
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIView *theWindow = self.view ;
    if( animated ) {
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.45f];
        [animation setType:kCATransitionPush];
        
        if(_pushDirection==1) //向上
            [animation setSubtype:kCATransitionFromTop];
        else if(_pushDirection==2) //向左
            [animation setSubtype:kCATransitionFromRight];
        else if(_pushDirection==3) //向下
            [animation setSubtype:kCATransitionFromBottom];
        else if(_pushDirection==4) //向右
            [animation setSubtype:kCATransitionFromLeft];
        
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [[theWindow layer] addAnimation:animation forKey:@""];
    }
    return [super popViewControllerAnimated:NO];
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}


@end
