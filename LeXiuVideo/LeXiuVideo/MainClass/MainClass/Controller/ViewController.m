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
///
@property (nonatomic, strong) UIView *windowView;
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
   
    __weak typeof(self)weakSelf = self;
    self.playView = [VideoPlayView videoPlayViewWithframe:CGRectMake(0, 0, self.view.frame.size.width, cellH)];
    self.playView.backgroundColor = [UIColor whiteColor];
    self.playView.videoPlayFinish = ^(VideoPlayView *view){
        [view stop];
        [view removeFromSuperview];
        weakSelf.windowView.hidden = YES;
        //[weakSelf.tableView reloadData];
    };
    
    // 悬浮窗
    UIView *windowView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, 100, 135)];
    windowView.backgroundColor = [UIColor redColor];
    [self.view addSubview:windowView];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(changePostion:)];
    [windowView addGestureRecognizer:pan];
    self.windowView = windowView;
    self.windowView.hidden = YES;
}

-(void)changePostion:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan translationInView:self.view];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    CGRect originalFrame = self.windowView.frame;
    if (originalFrame.origin.x >= 0 && originalFrame.origin.x+originalFrame.size.width <= width) {
        originalFrame.origin.x += point.x;
    }
    
    if (originalFrame.origin.y < 64) {
        originalFrame.origin.y = 64;
    }
    if (originalFrame.origin.y >= 64 && originalFrame.origin.y+originalFrame.size.height <= height) {
        originalFrame.origin.y += point.y;
    }

    self.windowView.frame = originalFrame;
    [pan setTranslation:CGPointZero inView:self.windowView];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.windowView.userInteractionEnabled = NO;
    }else if (pan.state == UIGestureRecognizerStateChanged){
        
    } else {
        
        CGRect frame = self.windowView.frame;
        //记录是否越界
        BOOL isOver = NO;
        
        if (frame.origin.x < 0) {
            frame.origin.x = 0;
            isOver = YES;
        } else if (frame.origin.x+frame.size.width > width) {
            frame.origin.x = width - frame.size.width;
            isOver = YES;
        }
        
        if (frame.origin.y < 0) {
            frame.origin.y = 0;
            isOver = YES;
        } else if (frame.origin.y+frame.size.height > height) {
            frame.origin.y = height - frame.size.height;
            isOver = YES;
        }
        if (isOver) {
            [UIView animateWithDuration:0.3 animations:^{
                self.windowView.frame = frame;
            }];
        }
        _windowView.userInteractionEnabled = YES;
    }
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
    cell.dataModel = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self videoToCell:indexPath pause:NO];
    self.selectIndex = indexPath;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.selectIndex == nil) {
        return;
    }

    // 对于cell 高度固定的 / 非固定高度不适用
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat H = (self.selectIndex.row + 1) * cellH;
    CGFloat BH = (H - cellH - self.view.frame.size.height);
    if ((contentOffsetY >= H) || (BH >= contentOffsetY)) {
        if ((self.playView.superview == nil) || (self.playView.superview == self.windowView)) {
            return;
        }
        [self videoToWindowView];
    }else if ((contentOffsetY <= (H - 64))){
        if ((self.playView.superview == nil) || (self.playView.superview != self.windowView)) {
            return;
        }
        [self videoToCell:self.selectIndex pause:YES];
    }else if (contentOffsetY >= BH){
        if ((self.playView.superview == nil) || (self.playView.superview != self.windowView)) {
            return;
        }
        [self videoToCell:self.selectIndex pause:YES];
    }
}

// 在悬浮窗上播放视频
- (void)videoToWindowView{
    self.windowView.hidden = NO;
    [self.playView removeFromSuperview];
    self.playView.frame = self.windowView.bounds;
    [self.windowView addSubview:self.playView];
}

// 在cell上播放视频
- (void)videoToCell:(NSIndexPath *)indexPath pause:(BOOL)isPause{
    VideoModel *model = self.dataModelArray[indexPath.row];
    VideoCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (self.playView.superview != nil) {
        self.windowView.hidden = YES;
        [self.playView removeFromSuperview];
        if (!isPause) {
            [self.playView stop];
        }
    }
    self.playView.frame = CGRectMake(0, 0, self.view.frame.size.width, 260);
    if (!isPause) {
        [self.playView videoWithUrl:[NSURL URLWithString:model.videoURL]];
    }
    [cell addSubview:self.playView];
}


@end
