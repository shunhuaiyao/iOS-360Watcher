//
//  MailboxVC.h
//  360Project
//
//  Created by Rachel Yeh on 2016/12/12.
//  Copyright © 2016年 Hanton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageCell.h"

@interface IntercomVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *emptyHint;
@property (weak, nonatomic) IBOutlet UILabel *actionHint;

@property (weak, nonatomic) IBOutlet UIButton *responseBtn;
- (IBAction)tappedRespondBtn:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *messageTable;
@property (strong, nonatomic) NSArray *messageArray;
@property (strong, nonatomic) MessageCell *messageCell;

@property NSString *deleteMID;
@property BOOL whetherSend;
@property BOOL whetherInspect;

- (IBAction)tappedExitBtn:(id)sender;
- (IBAction)tappedSendBtn:(id)sender;

- (IBAction)tappedExploreBtn:(id)sender;
- (IBAction)tappedMemoryBtn:(id)sender;

@end
