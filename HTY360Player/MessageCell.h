//
//  MessageCell.h
//  360Project
//
//  Created by Rachel Yeh on 2017/1/27.
//  Copyright © 2017年 Hanton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell



@property (copy, nonatomic) NSString *title;

@property (weak, nonatomic) IBOutlet UILabel *descrip;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

+ (NSString *)reuseIdentifier;

@end
