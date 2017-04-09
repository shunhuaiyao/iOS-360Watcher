//
//  ReceiveVC.h
//  360Project
//
//  Created by Rachel Yeh on 2017/1/24.
//  Copyright © 2017年 Hanton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageCell.h"

@interface ReceiveVC : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *messageTable;
@property (strong, nonatomic) NSArray *messageArray;
@property (strong, nonatomic) IBOutlet MessageCell *messageCell;

- (IBAction)tappedExitBtn:(id)sender;

@end
