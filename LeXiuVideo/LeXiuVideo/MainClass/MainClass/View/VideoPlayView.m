//
//  VideoPlayView.m
//  LeXiuVideo
//
//  Created by 张海军 on 2017/11/14.
//  Copyright © 2017年 baoqianli. All rights reserved.
//

#import "VideoPlayView.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import <UIImageView+WebCache.h>
#import <Masonry.h>
#import "PlayBottomToolView.h"


@interface VideoPlayView()
/// 内容view
@property (nonatomic, strong) UIView *contentView;
/// 播放按钮
@property (nonatomic, strong) UIButton *playButton;
/// 底部工具条
@property (nonatomic, strong) PlayBottomToolView *bottomToolBar;
/// 播放地址
@property (nonatomic, strong) NSURL *videoUrl;
/// 刷新进度
@property (nonatomic, weak) NSTimer *refreshTime;
@property (nonatomic,strong) IJKFFMoviePlayerController *player;
@property (nonatomic, strong) IJKFFOptions *options;
/// 进度加载
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

@implementation VideoPlayView

+ (instancetype)videoPlayViewWithframe:(CGRect)frame{
    VideoPlayView *view = [[VideoPlayView alloc] initWithFrame:frame];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self =[super initWithFrame:frame]) {
        self.contentView = [[UIView alloc] init];
        [self addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.mas_equalTo(self);
        }];
        
        //播放按钮
        self.playButton = [[UIButton alloc] init];
        [self.playButton setImage:[UIImage imageNamed:@"video-play"] forState:UIControlStateNormal];
        [self.playButton addTarget:self action:@selector(playButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.playButton];
        [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(60, 60));
            make.center.mas_equalTo(self.contentView.center);
        }];
        
        // 底部工具条
        self.bottomToolBar = [[PlayBottomToolView alloc] init];
        [self.contentView addSubview:self.bottomToolBar];
        [self.bottomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView.mas_left);
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
            make.height.mas_equalTo(@30);
            make.width.mas_equalTo(self.contentView.mas_width);
        }];
        
        __weak typeof(self)weakSelf = self;
        self.bottomToolBar.playButtonClickBlock = ^(BOOL isPlay){
            if (isPlay) {
                [weakSelf play];
            }else{
                [weakSelf pause];
            }
        };
        
        self.bottomToolBar.fullButtonClickBlock = ^(BOOL isFull){
            if (isFull) {
                UIWindow * keyWindow = [UIApplication sharedApplication].keyWindow;
                [weakSelf makePreviewFullScreen:keyWindow isFull:YES];
            }else{
                [weakSelf makePreviewFullScreen:weakSelf isFull:NO];
            }
        };
        
        self.bottomToolBar.sliderChangeBlock = ^(CGFloat value){
            weakSelf.indicatorView.hidden = NO;
            [weakSelf.indicatorView startAnimating];
            weakSelf.player.currentPlaybackTime = weakSelf.player.duration * value;
        };
        
        self.bottomToolBar.hidden = YES;
        
        
        // 加载圈
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self.contentView addSubview:self.indicatorView];
        [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.contentView.center);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        self.indicatorView.hidden = YES;

    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!self.player.isPlaying) {
        return;
    }
    
    self.bottomToolBar.hidden = !self.bottomToolBar.isHidden;
    
}

#pragma mark -
- (void)refreshData{
    if (self.bottomToolBar.isTouchSlider) {
        return;
    }
    self.bottomToolBar.beginTimeL.text = [self secondTimeToMMss:self.player.currentPlaybackTime];
    self.bottomToolBar.totalTimeL.text = [self secondTimeToMMss:self.player.duration];
    // 加载进度
    self.bottomToolBar.progressView.progress = self.player.playableDuration / self.player.duration;
    self.bottomToolBar.slider.value = self.player.currentPlaybackTime / self.player.duration;
}

- (NSString *)secondTimeToMMss:(NSTimeInterval)time{
    NSInteger min = time / 60;
    NSInteger second = time - (min * 60);
    return [NSString stringWithFormat:@"%02zd:%02zd",min,second];
}

// 初始化播放器 / 设置播放地址
- (void)videoWithUrl:(NSURL *)url{
    if (self.player) {
        [self.player stop];
    }
    
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:self.options];
    [self.player setScalingMode:IJKMPMovieScalingModeAspectFit];
    [self installMovieNotificationObservers];
    self.player.view.backgroundColor = [UIColor blackColor];
    [self.contentView insertSubview:self.player.view atIndex:0];
    [self.player prepareToPlay];
    [self.player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.contentView);
    }];
    [self play];
}

#pragma mark - 播放 / 暂停 / 停止
// 播放
- (void)play{
    self.playButton.hidden = YES;
    self.indicatorView.hidden = NO;
    [self.indicatorView startAnimating];
    [self.player play];
}

// 暂停播放
- (void)pause{
    [self.player pause];
}

// 停止播放
- (void)stop{
    [self.player stop];
    [self stopHandle];
}

- (BOOL)isPlaying{
    return self.player.isPlaying;
}

// 停止播放后的操作
- (void)stopHandle{
    [self.player.view removeFromSuperview];
    self.player = nil;
    self.playButton.hidden = NO;
    self.bottomToolBar.hidden = YES;
    self.videoUrl = nil;
    [self.bottomToolBar clearData];
    if (self.refreshTime) {
        [self.refreshTime invalidate];
        self.refreshTime = nil;
    }
    self.indicatorView.hidden = YES;
}

// 播放按钮点击
- (void)playButtonDidClick:(UIButton *)button{
    if (!self.player.isPlaying) {
        [self play];
    }else{
        [self pause];
    }
    
    button.hidden = YES;
}

// 全屏播放 / 退出全屏
- (void)makePreviewFullScreen:(UIView *)view isFull:(BOOL)full
{
    [self.contentView removeFromSuperview];
    [view addSubview:self.contentView];
    // 状态栏动画持续时间
    [[UIApplication sharedApplication]  setStatusBarHidden:full withAnimation:UIStatusBarAnimationFade];
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    // 基础动画
    [UIView animateWithDuration:duration animations:^{
        self.contentView.transform = full ? CGAffineTransformMakeRotation(M_PI / 2) : CGAffineTransformIdentity;
       
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (full) {
                make.width.mas_equalTo(view.mas_height);
                make.height.mas_equalTo(view.mas_width);
                make.center.mas_equalTo(0);
            }else{
                make.top.left.mas_equalTo(view);
                make.height.mas_equalTo(view.mas_height);
                make.width.mas_equalTo(view.mas_width);
            }
        }];
        
    } completion:^(BOOL finished) {
        [UIApplication sharedApplication].statusBarHidden = full;
    }];
}

#pragma mark-观察视频播放状态
- (void)installMovieNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
    
}

- (void)removeMovieNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:_player];
    
}

#pragma Selector func

- (void)loadStateDidChange:(NSNotification*)notification {
    IJKMPMovieLoadState loadState = _player.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        if (!self.refreshTime) {
            self.refreshTime = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshData) userInfo:nil repeats:YES];
        }
        [self.indicatorView stopAnimating];
        self.indicatorView.hidden = YES;
        self.bottomToolBar.hidden = NO;
        
    }else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
        self.indicatorView.hidden = NO;
        [self.indicatorView startAnimating];
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackFinish:(NSNotification*)notification {
    int reason =[[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    // 播放完毕回调
    if (self.videoPlayFinish) {
        self.videoPlayFinish(self);
    }
    switch (reason) {
        case IJKMPMovieFinishReasonPlaybackEnded:{
            // 播放完成
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            
        }
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification {
    NSLog(@"mediaIsPrepareToPlayDidChange\n");
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification {
    switch (_player.playbackState) {
        case IJKMPMoviePlaybackStateStopped:{
            [self stopHandle];
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
        }
            break;
            
        case IJKMPMoviePlaybackStatePlaying:{
            self.playButton.hidden = YES;
            self.bottomToolBar.playButton.selected = YES;
            [self.indicatorView stopAnimating];
            self.indicatorView.hidden = YES;
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
        }
            break;
            
        case IJKMPMoviePlaybackStatePaused:{
            self.playButton.hidden = NO;
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
        }
            break;
            
        case IJKMPMoviePlaybackStateInterrupted:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
            
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

#pragma mark - lazy
- (IJKFFOptions *)options{
    if (!_options) {
        IJKFFOptions *options = [IJKFFOptions optionsByDefault];
        [options setOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_frame" ofCategory:kIJKFFOptionCategoryCodec];
        [options setOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_loop_filter" ofCategory:kIJKFFOptionCategoryCodec];
        //软解码方式
        [options setOptionIntValue:1 forKey:@"videotoolbox" ofCategory:kIJKFFOptionCategoryPlayer];
        [options setOptionIntValue:30 forKey:@"max-fps" ofCategory:kIJKFFOptionCategoryPlayer];
        [options setOptionIntValue:10 forKey:@"reconnect" ofCategory:kIJKFFOptionCategoryPlayer];
        [options setOptionIntValue:3000000 forKey:@"timeout" ofCategory:kIJKFFOptionCategoryPlayer];
        [options setPlayerOptionIntValue:256 forKey:@"vol"];
        _options = options;
    }
    return _options;
}

@end
