//
//  VideoPlayView.h
//  LeXiuVideo
//
//  Created by 张海军 on 2017/11/14.
//  Copyright © 2017年 baoqianli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPlayView : UIView

+ (instancetype)videoPlayViewWithframe:(CGRect)frame;

- (void)videoWithUrl:(NSURL *)url;

- (void)stop;
@end
