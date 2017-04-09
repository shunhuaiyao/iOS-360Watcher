//
//  EchoVC.h
//  360Project
//
//  Created by Rachel Yeh on 2017/2/23.
//  Copyright © 2017年 Hanton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EchoVC : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentLabel;
- (IBAction)tappedExitBtn:(id)sender;

@property NSDictionary *messageDict;
@end
