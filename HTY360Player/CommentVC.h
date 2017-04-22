//
//  CommentVC.h
//  360Project
//
//  Created by Rachel Yeh on 2017/3/22.
//  Copyright © 2017年 Hanton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentVC : UIViewController

@property (strong, nonatomic) NSString *currentMood;
//@property (strong, nonatomic) NSString *currentVideo;
@property (strong, nonatomic) NSDictionary *currentVideoInfo;

@property (weak, nonatomic) IBOutlet UIImageView *triangleView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UIImageView *puzzleView;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;

@property (weak, nonatomic) IBOutlet UILabel *option1;
@property (weak, nonatomic) IBOutlet UILabel *option2;

@property (weak, nonatomic) IBOutlet UILabel *positive;
@property (weak, nonatomic) IBOutlet UILabel *slash;
@property (weak, nonatomic) IBOutlet UILabel *negative;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingConstraint;
- (IBAction)tappedMessageBtn:(id)sender;
- (IBAction)tappedMemoryBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *StarBtn1UI;
@property (weak, nonatomic) IBOutlet UIButton *StarBtn2UI;
@property (weak, nonatomic) IBOutlet UIButton *StarBtn3UI;
@property (weak, nonatomic) IBOutlet UIButton *StarBtn4UI;
@property (weak, nonatomic) IBOutlet UIButton *StarBtn5UI;
- (IBAction)StarBtn1:(id)sender;
- (IBAction)StarBtn2:(id)sender;
- (IBAction)StarBtn3:(id)sender;
- (IBAction)StarBtn4:(id)sender;
- (IBAction)StarBtn5:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *NextBtnUI;
- (IBAction)NextBtn:(id)sender;

@end
