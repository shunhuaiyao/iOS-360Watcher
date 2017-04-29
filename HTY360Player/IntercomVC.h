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
- (IBAction)tappedEmailBtn:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *messageTable;
@property (strong, nonatomic) NSArray *messageArray;
@property (strong, nonatomic) MessageCell *messageCell;
@property (weak, nonatomic) IBOutlet UITableView *responseTable;
@property (strong, nonatomic) NSArray *responseArray;
@property (strong, nonatomic) MessageCell *responeseCell;
@property NSString *deleteMID;
@property BOOL whetherSend;
@property BOOL whetherInspect;

- (IBAction)tappedExitBtn:(id)sender;
- (IBAction)tappedSendBtn:(id)sender;

- (IBAction)tappedExploreBtn:(id)sender;
- (IBAction)tappedMemoryBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *emailBtnUI;
@property (weak, nonatomic) IBOutlet UIButton *responseBtnUI;

@end
