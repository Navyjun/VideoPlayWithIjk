//
//  VideoCell.h
//  LeXiuVideo
//
//  Created by 张海军 on 2017/11/14.
//  Copyright © 2017年 baoqianli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoModel.h"

@interface VideoCell : UITableViewCell
/// indexPath
@property (nonatomic, strong) NSIndexPath *indexPath;
/// 刷新回调
@property (nonatomic, copy) void(^refreshDataBlock)(NSIndexPath *indexPath);
/// dataModel
@property (nonatomic, strong) VideoModel *dataModel;

+ (instancetype)videoCell:(UITableView *)tableView;

@end


@interface ViewCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *playImageView;
@property (nonatomic, strong) VideoModel *dataModel;

@end
