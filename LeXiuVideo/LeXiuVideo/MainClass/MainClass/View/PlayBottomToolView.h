//
//  PlayBottomToolView.h
//  LeXiuVideo
//
//  Created by 张海军 on 2017/11/15.
//  Copyright © 2017年 baoqianli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayBottomToolView : UIView
@property (strong, nonatomic)  UIButton *playButton;
@property (strong, nonatomic)  UILabel *beginTimeL;
@property (strong, nonatomic)  UILabel *totalTimeL;
@property (strong, nonatomic)  UIButton *fullScreenBut;
@property (strong, nonatomic)  UIProgressView *progressView;
@property (strong, nonatomic)  UISlider *slider;
/// 是否正在滑动滑块
@property (nonatomic, assign) BOOL isTouchSlider;
/// 点击播放按钮的回调
@property (nonatomic, copy) void(^playButtonClickBlock)(BOOL isPlay);
/// 点击全屏按钮的回调
@property (nonatomic, copy) void(^fullButtonClickBlock)(BOOL isFull);
/// 滑块滑动的回调
@property (nonatomic, copy) void(^sliderChangeBlock)(CGFloat value);
- (void)clearData;
@end
