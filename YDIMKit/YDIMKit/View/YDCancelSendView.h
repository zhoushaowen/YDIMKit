//
//  YDCancelSendView.h
//  Chat
//
//  Created by 周少文 on 2016/10/26.
//  Copyright © 2016年 周少文. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YDCancelSendView : UIView

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *durationLabel;

+ (instancetype)cancelSendView;

@end
