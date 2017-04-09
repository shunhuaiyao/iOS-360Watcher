//
//  ResponseVC.h
//  360Project
//
//  Created by Rachel Yeh on 2017/2/23.
//  Copyright © 2017年 Hanton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageCell.h"

@interface ResponseVC : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *messageTable;
//@property (strong, nonatomic) NSArray *messageArray;
@property (strong, nonatomic) MessageCell *messageCell;

- (IBAction)tappedExitBtn:(id)sender;

@end
