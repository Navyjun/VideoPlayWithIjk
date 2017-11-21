//
//  VideoPlayView.h
//  LeXiuVideo
//
//  Created by 张海军 on 2017/11/14.
//  Copyright © 2017年 baoqianli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPlayView : UIView
/// 当前视频播放完成的回调
@property (nonatomic, copy) void(^videoPlayFinish)(VideoPlayView *view);

+ (instancetype)videoPlayViewWithframe:(CGRect)frame;

- (void)videoWithUrl:(NSURL *)url;

- (void)play;

- (void)pause;

- (void)stop;

@end
