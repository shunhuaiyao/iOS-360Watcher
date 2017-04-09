//
//  MessageCell.m
//  360Project
//
//  Created by Rachel Yeh on 2017/1/27.
//  Copyright © 2017年 Hanton. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

}

+ (NSString *)reuseIdentifier {
    return @"MessageCellIdentifier";
}

-(void) setTitle:(NSString *)title
{
    if(![_title isEqualToString:title]){
        _title=[title copy];
        self.titleLabel.text=_title;
    }
}

@end
