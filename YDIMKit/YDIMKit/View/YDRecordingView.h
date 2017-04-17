//
//  YDRecordingView.h
//  Chat
//
//  Created by 周少文 on 2016/10/26.
//  Copyright © 2016年 周少文. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YDRecordingView : UIView

@property (nonatomic,strong) UIImageView *animationImgV;
@property (nonatomic,copy) NSArray<UIImage *> *imageArr;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *durationLabel;

+ (instancetype)recordingView;

@end
