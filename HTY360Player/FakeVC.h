//
//  FakeVC.h
//  360Project
//
//  Created by Rachel Yeh on 2017/2/23.
//  Copyright © 2017年 Hanton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FakeVC : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *plainView;
- (IBAction)tappedExitBtn:(id)sender;

@end
