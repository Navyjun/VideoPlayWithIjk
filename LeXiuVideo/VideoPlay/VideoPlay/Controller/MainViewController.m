//
//  MainViewController.m
//  VideoPlay
//
//  Created by 张海军 on 2017/11/14.
//  Copyright © 2017年 baoqianli. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()<UITableViewDelegate,UITableViewDataSource>
/// tableView
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation MainViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - init
- (void)setupInit{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

- (void)getJsonData{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"videoPageOne.json" ofType:@".json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
}
@end
