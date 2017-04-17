//
//  YDRecordingView.m
//  Chat
//
//  Created by 周少文 on 2016/10/26.
//  Copyright © 2016年 周少文. All rights reserved.
//

#import "YDRecordingView.h"
#import "UIView+SWAutoLayout.h"
#import "UIImage+Bundle.h"
#import "UIView+HUD.h"
#import "UIColor+Hex.h"

@interface YDRecordingView ()

@end

@implementation YDRecordingView

+ (instancetype)recordingView {
    YDRecordingView *view = [[self alloc] initWithFrame:CGRectMake(0, 0, 350/2.0, 350/2.0)];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        UIImage *image = [UIImage imageWithBundleName:@"chat" imageName:@"voice_1"];
        _animationImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 170/2.0, 170/2.0)];
        _animationImgV.center = CGPointMake(frame.size.width/2.0, frame.size.height/2.0);
        [self addSubview:_animationImgV];
        _animationImgV.image = image;
        _animationImgV.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        NSMutableArray *array = [NSMutableArray array];
        for(int i= 0;i<6;i++)
        {
            NSString *name = [NSString stringWithFormat:@"voice_%d",i+1];
            UIImage *image = [UIImage imageWithBundleName:@"chat" imageName:name];
            [array addObject:image];
        }
        _imageArr = array;
        
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.font = [UIFont systemFontOfSize:15];
        _durationLabel.textAlignment = NSTextAlignmentCenter;
        _durationLabel.textColor = [UIColor colorWithHexString:@"eaeaea"];
        _durationLabel.text = @"";
        [self addSubview:_durationLabel];
        [_durationLabel sw_addConstraintsWithFormat:@"V:|-15-[_durationLabel(h)]" options:0 metrics:@{@"h":@(ceil(_durationLabel.font.lineHeight))} views:NSDictionaryOfVariableBindings(_durationLabel)];
        [_durationLabel sw_addConstraintToView:self withEqualAttribute:NSLayoutAttributeCenterX constant:0];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor colorWithHexString:@"eaeaea"];
        label.text = @"松开发送";
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        [label sw_addConstraintsWithFormat:@"H:|-0-[label]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)];
        [label sw_addConstraintsWithFormat:@"V:[_animationImgV]-20-[label(h)]" options:0 metrics:@{@"h":@(ceil(label.font.lineHeight))} views:NSDictionaryOfVariableBindings(label,_animationImgV)];
        
        self.titleLabel = label;
    }
    
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(350/2.0f, 350/2.0f);
}



@end
