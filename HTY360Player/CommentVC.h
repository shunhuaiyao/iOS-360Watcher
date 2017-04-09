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

@end
