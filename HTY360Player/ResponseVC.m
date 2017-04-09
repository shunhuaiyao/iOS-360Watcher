//
//  ResponseVC.m
//  360Project
//
//  Created by Rachel Yeh on 2017/2/23.
//  Copyright © 2017年 Hanton. All rights reserved.
//

#import "ResponseVC.h"
#import "PlistAccessManager.h"
#import "JsonRetriever.h"
#import "EchoVC.h"
#import "FakeVC.h"

@interface ResponseVC ()
{
    PlistAccessManager *plistManager;
    JsonRetriever *jsonRetriever;
    NSArray *_responseArray;
}
@end

@implementation ResponseVC
@synthesize messageCell = _messageCell;
@synthesize messageTable = _messageTable;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    jsonRetriever=[[JsonRetriever alloc]init];
    jsonRetriever.delegate=self;
    
    plistManager=[[PlistAccessManager alloc]init];
    
    //獲取所有寄送過的訊息
    //_responseArray=[NSArray arrayWithArray:[plistManager getRootArrayOfPlist:@"writtenMessage" underFolder:@"watchtower"]];
    _responseArray=[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:@"做了對不起朋友的事" forKey:@"Title"]];
    [_messageTable reloadData];
    //NSLog(@"array:%@",array);
    
    //檢測訊息是否有被回覆，若有則顯示
    /*for(NSDictionary *dict in _responseArray)
    {
        [dict objectForKey:@"MID"];
    }
    //[jsonRetriever httpGetMethodByURL:@""];*/
}


- (IBAction)tappedExitBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

# pragma mark - TableView 控制相關方法

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num=[_responseArray count];
    NSLog(@"responseArray:%@",_responseArray);
    
    if(num==0){
        //_emptyHint.hidden=NO;
        //_messageTable.hidden=YES;
    }
    return num;
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
    
    NSDictionary *dict=[_responseArray objectAtIndex:indexPath.row];
    cell.title=[dict objectForKey:@"Title"];
    cell.descrip.text=@"RE";
    NSLog(@"cell:%@",cell);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"row: %d",(int)indexPath.row);
    
    //navi
    EchoVC *echoVC=[[EchoVC alloc] initWithNibName:@"EchoVC" bundle:[NSBundle mainBundle]];
    
    //獲取訊息內容
    NSDictionary *dict=[_responseArray objectAtIndex:indexPath.row];
    echoVC.messageDict=dict;
    
    //跳轉
    FakeVC *fakeVC=[[FakeVC alloc]init];
    [self.navigationController pushViewController:fakeVC animated:NO];
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) {
        self.view = nil;
    }
}
@end
