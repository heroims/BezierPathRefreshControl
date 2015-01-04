//
//  ViewController.m
//  BezierPathRefreshControlDemo
//
//  Created by ZhaoYiQi on 14/12/30.
//  Copyright (c) 2014年 ZhaoYiQi. All rights reserved.
//

#import "ViewController.h"
#import "MyTableView.h"
#import "BezierPathRefreshControl.h"
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MyTableView *tableV1=[[MyTableView alloc] initWithFrame:CGRectMake(0, 30, [UIScreen mainScreen].bounds.size.width/2., 300) plist:@"loading"];
    tableV1.backgroundColor=[UIColor blackColor];
    [self.view addSubview:tableV1];
    
    MyTableView *tableV2=[[MyTableView alloc] initWithFrame:CGRectMake(tableV1.frame.origin.x+tableV1.frame.size.width, tableV1.frame.origin.y, tableV1.frame.size.width, tableV1.frame.size.height) plist:@"storehouse"];
    tableV2.backgroundColor=[UIColor blackColor];
    [self.view addSubview:tableV2];

    MyTableView *tableV3=[[MyTableView alloc] initWithFrame:CGRectMake(0, tableV1.frame.size.height+tableV1.frame.origin.y, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-300) plist:@"AKTA"];
    tableV3.backgroundColor=[UIColor blackColor];
    [self.view addSubview:tableV3];

    // Do any additional setup after loading the view, typically from a nib.
}

-(void)refeshTable{
    NSLog(@"12345");
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cellStr"];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellStr"];
    }
    cell.textLabel.text=[NSString stringWithFormat:@"%d",indexPath.row];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
