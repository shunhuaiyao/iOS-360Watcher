//
//  BrowseVC.h
//  360Project
//
//  Created by Rachel Yeh on 2017/2/23.
//  Copyright © 2017年 Hanton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowseVC : UIViewController

//@property (strong, nonatomic) NSString *Title;
//@property (strong, nonatomic) NSString *Content;
@property NSDictionary *messageDict;
@property (weak, nonatomic) IBOutlet UITextField *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentLabel;

@property (weak, nonatomic) IBOutlet UIButton *starBtn;

- (IBAction)tappedCollectBtn:(id)sender;

- (IBAction)tappedReplyBtn:(id)sender;
- (IBAction)tappedExitBtn:(id)sender;
- (IBAction)tappedReportBtn:(id)sender;

@end
