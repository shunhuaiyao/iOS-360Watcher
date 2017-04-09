//
//  SendVC.h
//  360Project
//
//  Created by Rachel Yeh on 2017/1/24.
//  Copyright © 2017年 Hanton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

@property BOOL whetherReply;
@property NSString *replyTitle;
@property NSString *replyID;

- (IBAction)tappedSendBtn:(id)sender;
- (IBAction)tappedExitBtn:(id)sender;

@end
