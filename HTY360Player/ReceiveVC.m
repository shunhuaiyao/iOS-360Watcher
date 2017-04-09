//
//  ReceiveVC.m
//  360Project
//
//  Created by Rachel Yeh on 2017/1/24.
//  Copyright © 2017年 Hanton. All rights reserved.
//

#import "ReceiveVC.h"
#import "NaviVC.h"
#import "JsonRetriever.h"

@interface ReceiveVC () <JsonRetrieverDelegate>

@end


@implementation ReceiveVC

@synthesize messageCell = _messageCell;
@synthesize messageTable = _messageTable;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //以下使用get方法連上server
    JsonRetriever *retriever=[[JsonRetriever alloc] init];
    retriever.delegate=self;
    [retriever httpGetMethodByURL:@"http://52.185.155.19/watchtower/getAllMessage.php"];
    
}

-(void)getJsonData:(id)jsonObject
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"取得結果：%@",jsonObject);
        _messageArray=jsonObject;
        [_messageTable reloadData];
    });
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (IBAction)tappedExitBtn:(id)sender
{
    NaviVC *naviVC=self.navigationController;
    [self.navigationController popViewControllerAnimated:NO];
}

# pragma mark - TableView 控制相關方法

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_messageArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //1.從緩存池中取出cell
    static NSString *ID=@"MessageCellIdentifier";
    MessageCell *cell=[tableView dequeueReusableCellWithIdentifier:ID];
    
    //2.若緩存池沒有cell則新創建一個
    if(cell==nil){
        [[NSBundle mainBundle] loadNibNamed:@"MessageCell" owner:self options:nil];
        cell = _messageCell;
        _messageCell = nil;
    }
    
    //3.傳遞模型數據
    cell.backgroundColor = [UIColor clearColor];
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor clearColor];
    [cell setSelectedBackgroundView:bgColorView];
    
    NSLog(@"%@",[[_messageArray objectAtIndex:indexPath.row]objectForKey:@"Title"]);
    cell.title=[[_messageArray objectAtIndex:indexPath.row]objectForKey:@"Title"];
    NSLog(@"cell:%@",cell);
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) {
        self.view = nil;
    }
}


@end
