//
//  TelescopeVC.h
//  360Project
//
//  Created by Rachel Yeh on 2016/12/12.
//  Copyright © 2016年 Hanton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TelescopeVC : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *downBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *sliderView;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UIImageView *frameView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *microBtn;
@property (weak, nonatomic) IBOutlet UIImageView *microBlingView;
@property (weak, nonatomic) IBOutlet UIImageView *roundView;
@property (weak, nonatomic) IBOutlet UIImageView *triangleView;
@property (weak, nonatomic) IBOutlet UIImageView *maskView;

- (IBAction)tappedMicrophone:(id)sender;
- (IBAction)tappedDownBtn:(id)sender;
- (IBAction)tappedLeftBtn:(id)sender;
- (IBAction)tappedRightBtn:(id)sender;

@end
