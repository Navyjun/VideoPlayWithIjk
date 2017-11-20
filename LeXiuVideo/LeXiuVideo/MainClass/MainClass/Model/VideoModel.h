//
//  VideoModel.h
//  LeXiuVideo
//
//  Created by 张海军 on 2017/11/14.
//  Copyright © 2017年 baoqianli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoModel : NSObject
/// headImageUrl
@property (nonatomic, copy) NSString *headImageUrl;
/// imageURL
@property (nonatomic, copy) NSString *imageURL;
/// videoURL
@property (nonatomic, copy) NSString *videoURL;
/// videoDescription
@property (nonatomic, copy) NSString *videoDescription;
/// 是否选中
@property (nonatomic, assign) BOOL isSelect;
@end
