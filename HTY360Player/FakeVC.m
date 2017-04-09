//
//  FakeVC.m
//  360Project
//
//  Created by Rachel Yeh on 2017/2/23.
//  Copyright © 2017年 Hanton. All rights reserved.
//

#import "FakeVC.h"

@interface FakeVC ()

@end

@implementation FakeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *content=@"好朋友A在工作上受到了很不公平的待遇，我們親近的共同好友問起她最近好嗎，我便抱著「我們一起多關心她」的心情，把發生在他身上的事告訴了對方。但是A並不是這樣想的，對他來說被其他人問起這件事很難堪，也很困擾。\n\n我覺得好羞恥，一直以來抱著「告訴我不能說的話，就絕對不會讓其他人知道，但沒有特別說的話，或許沒關係」的心態，就做出這種愚蠢的事，沒有好好考慮當事者的心情，傷害了自己重要的朋友，給他的感覺或許像是背叛吧。\n\n我知道我一直道歉也沒用，而且這不只是給A帶來困擾、讓他受到傷害，甚至可能讓他覺得我背叛了你給我的信任。如果他因此無法再信任我、心中有芥蒂，都是合理的，因為我真的做了很過份的事。不過我有向A澄清，我不是以說八卦的心情談他的事的。澄清不是要為了讓他原諒我，而是覺得或許可以讓他不要更受傷。";
    
    NSString *reply=@"我曾經也犯過類似的錯誤。也許你可以最後ㄧ次跟A解釋你當初的立場,還有知道你錯了。至少不要有遺憾沒有解釋的機會\n\n那個人到最後並沒有原諒我的樣子，因為之後不常聯絡。但，是學到ㄧ課。";
    
    _scrollView.contentSize=CGSizeMake(490, 650);
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    
    
    UITextView *contentLabel=[[UITextView alloc]init];
    contentLabel.scrollEnabled=NO;
    contentLabel.text=content;
    [contentLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [contentLabel  setBackgroundColor: [UIColor clearColor]];
    [contentLabel  setTextColor: [UIColor whiteColor]];
    CGSize contentSize=[content sizeWithFont:contentLabel.font constrainedToSize:CGSizeMake(450, MAXFLOAT)];
    NSLog(@"contentHeight:%f",contentSize.height);
    contentLabel.frame=CGRectMake(15, 15, 450, contentSize.height+30);
    [_scrollView addSubview:contentLabel];
    
    CGFloat replyY=CGRectGetMaxY(contentLabel.frame);
    
    UITextView *replyLabel=[[UITextView alloc]init];
    replyLabel.scrollEnabled=NO;
    replyLabel.text=reply;
    [replyLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [replyLabel  setBackgroundColor: [UIColor clearColor]];
    [replyLabel  setTextColor: [UIColor whiteColor]];
    
    CGSize contentSize2=[reply sizeWithFont:replyLabel.font constrainedToSize:CGSizeMake(450, MAXFLOAT)];
    replyLabel.frame=CGRectMake(25, replyY+15, 450, contentSize2.height+30);
    [_scrollView addSubview:replyLabel];
    
    UIImageView *imageView=[[UIImageView alloc]init];
    [imageView setImage:[UIImage imageNamed:@"indicator"]]; //resizableImageWithCapInsets:UIEdgeInsetsMake(28, 28, 28, 28)]];
    imageView.frame=CGRectMake(0,replyY+20,18,contentSize2.height+10);
    [_scrollView addSubview:imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)tappedExitBtn:(id)sender{
    [self.navigationController popViewControllerAnimated:NO];
}
@end
