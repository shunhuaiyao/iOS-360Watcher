//
//  EarthVC.h
//  360Project
//
//  Created by Rachel Yeh on 2017/2/6.
//  Copyright © 2017年 Hanton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EarthVC : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *mapView;

@property (weak, nonatomic) IBOutlet UIImageView *earthView;
//@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UIImageView *triangleView;
@property (weak, nonatomic) IBOutlet UIImageView *mascotView;












@property (weak, nonatomic) IBOutlet UIImageView *ufoView2;
@property (weak, nonatomic) IBOutlet UIImageView *ufoView3;












@property (weak, nonatomic) IBOutlet UIButton *sup;
@property (weak, nonatomic) IBOutlet UIButton *sdown;
@property (weak, nonatomic) IBOutlet UIButton *sleft;
@property (weak, nonatomic) IBOutlet UIButton *sright;
@property BOOL playTutorialAtFirst;

- (IBAction)tappedUpBtn:(id)sender;
- (IBAction)tappedRightBtn:(id)sender;
- (IBAction)tappedExploreBtn:(id)sender;
- (IBAction)tappedMemoryBtn:(id)sender;
- (IBAction)tappedMessageBtn:(id)sender;
- (IBAction)tappedClassLeftArrow:(id)sender;
- (IBAction)tappedClassRightArrow:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *classLabel;

- (IBAction)tappedStarUpBtn1:(id)sender;
- (IBAction)tappedStarUpBtn2:(id)sender;
- (IBAction)tappedStarUpBtn3:(id)sender;
- (IBAction)tappedStarUpBtn4:(id)sender;
- (IBAction)tappedStarUpBtn5:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *StarUpBtn1;
@property (weak, nonatomic) IBOutlet UIButton *StarUpBtn2;
@property (weak, nonatomic) IBOutlet UIButton *StarUpBtn3;
@property (weak, nonatomic) IBOutlet UIButton *StarUpBtn4;
@property (weak, nonatomic) IBOutlet UIButton *StarUpBtn5;
@property (weak, nonatomic) IBOutlet UIButton *StarDownBtn1;
@property (weak, nonatomic) IBOutlet UIButton *StarDownBtn2;
@property (weak, nonatomic) IBOutlet UIButton *StarDownBtn3;
@property (weak, nonatomic) IBOutlet UIButton *StarDownBtn4;
@property (weak, nonatomic) IBOutlet UIButton *StarDownBtn5;
- (IBAction)tappedVideoRightBtn:(id)sender;
- (IBAction)tappedVideoLeftBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *VideoRightBtn;
@property (weak, nonatomic) IBOutlet UIButton *VideoLeftBtn;
@property (weak, nonatomic) IBOutlet UIImageView *endlessImg;

@end
