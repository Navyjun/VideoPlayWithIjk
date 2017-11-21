//
//  VideoCell.m
//  LeXiuVideo
//
//  Created by 张海军 on 2017/11/14.
//  Copyright © 2017年 baoqianli. All rights reserved.
//

#import "VideoCell.h"
#import <UIImageView+WebCache.h>

@interface VideoCell ()
@property (weak, nonatomic) IBOutlet UIImageView *bgImageViwe;
@property (weak, nonatomic) IBOutlet UIImageView *playImage;
@end

@implementation VideoCell
+ (instancetype)videoCell:(UITableView *)tableView{
    VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}


- (void)awakeFromNib{
    [super awakeFromNib];
    self.bgImageViwe.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

- (void)setDataModel:(VideoModel *)dataModel{
    _dataModel = dataModel;
    [self.bgImageViwe sd_setImageWithURL:[NSURL URLWithString:dataModel.imageURL]];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end


#pragma mark ------- ViewCollectionCell

@implementation ViewCollectionCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self = [[NSBundle mainBundle] loadNibNamed:@"VideoCell" owner:nil options:nil][1];
    }
    return self;
}

- (void)setDataModel:(VideoModel *)dataModel{
    _dataModel = dataModel;
    [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.imageURL]];
}

@end
