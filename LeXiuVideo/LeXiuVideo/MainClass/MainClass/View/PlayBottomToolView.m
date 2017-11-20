//
//  PlayBottomToolView.m
//  LeXiuVideo
//
//  Created by 张海军 on 2017/11/15.
//  Copyright © 2017年 baoqianli. All rights reserved.
//

#import "PlayBottomToolView.h"
#import <Masonry.h>
#import "UIImage+Image.h"

@implementation PlayBottomToolView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        // 播放
        self.playButton = [self creationBut:@"play_icon_s" selected:@"pause_icon_s" sel:@selector(playButtonDidClick:)];
        self.playButton.selected = YES;
        [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.left.mas_equalTo(self.mas_left).offset(8.0);
        }];
        
        // 开始时间
        self.beginTimeL = [self creationLabel];
        [self.beginTimeL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.left.mas_equalTo(self.playButton.mas_right).offset(8);
            make.width.mas_equalTo(@36);
        }];
        
        // 全屏按钮
        self.fullScreenBut = [self creationBut:@"full_screen_a" selected:@"zoom_out_a" sel:@selector(fullButtonDidClick:)];
        [self.fullScreenBut mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.right.mas_equalTo(self.mas_right).offset(-8.0);
        }];
        
        // 总时长
        self.totalTimeL = [self creationLabel];
        [self.totalTimeL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.right.mas_equalTo(self.fullScreenBut.mas_left).offset(-8);
            make.width.mas_equalTo(@36);
        }];
        
        // 进度条
        self.progressView = [[UIProgressView alloc] init];
        self.progressView.progressTintColor = [UIColor whiteColor];
        [self addSubview:self.progressView];
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.left.mas_equalTo(self.beginTimeL.mas_right).offset(8);
            make.right.mas_equalTo(self.totalTimeL.mas_left).offset(-8);
        }];
        
        // 滑块
        self.slider = [[UISlider alloc] init];
        [self addSubview:self.slider];
        self.slider.minimumTrackTintColor = [UIColor whiteColor];
        self.slider.maximumTrackTintColor = [UIColor clearColor];
        UIImage *thum = [UIImage imageWithColor:[UIColor whiteColor] height:16 width:16];
        [self.slider setThumbImage:[UIImage imageWithCircularImage:thum] forState:UIControlStateNormal];
        self.slider.continuous = NO;//设置为NO,只有在手指离开的时候调用valueChange
        [self.slider addTarget:self action:@selector(sliderValuechange:) forControlEvents:UIControlEventValueChanged];
        [self.slider addTarget:self action:@selector(sliderTapInside:) forControlEvents:UIControlEventTouchDown];
        //[self.slider addTarget:self action:@selector(sliderTapOutside:) forControlEvents:UIControlEventTouchUpInside];
        [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY).mas_offset(-1);
            make.left.right.mas_equalTo(self.progressView);
        }];
    }
    return self;
}

- (UILabel *)creationLabel{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:12.0];
    label.text = @"00:00";
    [self addSubview:label];
    return label;
}

- (UIButton *)creationBut:(NSString *)defImg selected:(NSString*)selImg sel:(SEL)action{
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:defImg] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:selImg] forState:UIControlStateSelected];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}



#pragma amrk - event
- (void)playButtonDidClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.playButtonClickBlock) {
        self.playButtonClickBlock(sender.selected);
    }
}

- (void)fullButtonDidClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.fullButtonClickBlock) {
        self.fullButtonClickBlock(sender.selected);
    }
}

- (void)sliderValuechange:(UISlider *)slider{
    self.isTouchSlider = NO;
    if (self.sliderChangeBlock) {
        self.sliderChangeBlock(slider.value);
    }
}

- (void)sliderTapInside:(UISlider *)slider{
    self.isTouchSlider = YES;
}

- (void)clearData{
    self.isTouchSlider = NO;
    self.progressView.progress = 0.0;
    self.slider.value = 0.0;
    self.playButton.selected = YES;
    self.fullScreenBut.selected = NO;
}


@end
