//
//  ViewController.m
//  LeXiuVideo
//
//  Created by 张海军 on 2017/9/21.
//  Copyright © 2017年 baoqianli. All rights reserved.
//

#import "ViewController.h"
#import "VideoCell.h"
#import <MJExtension.h>
#import "VideoPlayView.h"

static CGFloat const cellH = 260.0;

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
/// tableView
@property (nonatomic, strong) UITableView *tableView;
/// 模型数据
@property (nonatomic, strong) NSMutableArray *dataModelArray;
/// 当前选中的indexpath
@property (nonatomic, strong) NSIndexPath *selectIndex;
/// 播放view
@property (nonatomic, strong) VideoPlayView *playView;
@end

@implementation ViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupInit];
    [self getJsonData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark -
- (void)setupInit{
    self.navigationItem.title = @"视频列表";
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = cellH;
    [self.view addSubview:self.tableView];
   
    self.playView = [VideoPlayView videoPlayViewWithframe:CGRectMake(0, 0, self.view.frame.size.width, 260)];
    self.playView.backgroundColor = [UIColor whiteColor];
    self.playView.videoPlayFinish = ^(VideoPlayView *view){
        [view stop];
        [view removeFromSuperview];
    };
}

- (void)getJsonData{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"videoPageOne" ofType:@".json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    self.dataModelArray = [VideoModel mj_objectArrayWithKeyValuesArray:dataDic[@"data"][@"vodVideoLists"]];
    [self.tableView reloadData];
}

#pragma mark - table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataModelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    VideoModel *model = self.dataModelArray[indexPath.row];
    VideoCell *cell = [VideoCell videoCell:tableView];
    cell.indexPath = indexPath;
    //__weak typeof(self)weakSelf = self;
    cell.refreshDataBlock =^(NSIndexPath *indexPath){
 
    };
    cell.dataModel = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    VideoModel *model = self.dataModelArray[indexPath.row];
    VideoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (self.playView.superview != nil) {
        [self.playView removeFromSuperview];
        [self.playView stop];
    }
    [self.playView videoWithUrl:[NSURL URLWithString:model.videoURL]];
    [cell addSubview:self.playView];
    self.selectIndex = indexPath;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.selectIndex == nil) {
        return;
    }

    // 对于cell 高度固定的 / 非固定高度不适用
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat H = (self.selectIndex.row + 1) * cellH;
    CGFloat BH = (H - cellH - scrollView.frame.size.height);
    if ((contentOffsetY >= H) || (BH >= contentOffsetY)) {
        [self.playView stop];
        [self.playView removeFromSuperview];
        self.selectIndex = nil;
    }
    
}



@end
