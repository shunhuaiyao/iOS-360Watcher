//
//  LettersViewController.h
//  360Project
//
//  Created by Rachel Yeh on 2016/12/12.
//  Copyright © 2016年 Hanton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LettersVC : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *writeButton;

- (IBAction)tappedWriteBtn:(id)sender;
- (IBAction)tappedExitBtn:(id)sender;
- (IBAction)tappedSendBtn:(id)sender;

@end
