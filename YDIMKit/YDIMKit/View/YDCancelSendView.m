//
//  YDCancelSendView.m
//  Chat
//
//  Created by 周少文 on 2016/10/26.
//  Copyright © 2016年 周少文. All rights reserved.
//

#import "YDCancelSendView.h"
#import "UIImage+Bundle.h"
#import "UIView+SWAutoLayout.h"
#import "UIColor+Hex.h"
#import "UIView+HUD.h"

@implementation YDCancelSendView

+ (instancetype)cancelSendView {
    YDCancelSendView *view = [[self alloc] initWithFrame:CGRectMake(0, 0, 350/2.0, 350/2.0)];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithBundleName:@"chat" imageName:@"return"]];
        imageView.center = CGPointMake(frame.size.width/2.0, frame.size.height/2.0);
        [self addSubview:imageView];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.font = [UIFont systemFontOfSize:15];
        _durationLabel.textAlignment = NSTextAlignmentCenter;
        _durationLabel.textColor = [UIColor colorWithHexString:@"eaeaea"];
        _durationLabel.text = @"";
        [self addSubview:_durationLabel];
        [_durationLabel sw_addConstraintsWithFormat:@"V:|-15-[_durationLabel(h)]" options:0 metrics:@{@"h":@(ceil(_durationLabel.font.lineHeight))} views:NSDictionaryOfVariableBindings(_durationLabel)];
        [_durationLabel sw_addConstraintToView:self withEqualAttribute:NSLayoutAttributeCenterX constant:0];
        
        UIView *labelBgView = [[UIView alloc] init];
        labelBgView.backgroundColor = [UIColor colorWithHexString:@"f35a5e"];
        [self addSubview:labelBgView];
        labelBgView.layer.cornerRadius = 5;
        [labelBgView sw_addConstraintToView:self withEqualAttribute:NSLayoutAttributeCenterX constant:0];
        [labelBgView sw_addConstraintsWithFormat:@"V:[labelBgView(25)]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(labelBgView,imageView)];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor colorWithHexString:@"eaeaea"];
        label.textAlignment = NSTextAlignmentCenter;
        [labelBgView addSubview:label];
        [label sw_addConstraintWith:NSLayoutAttributeTop toView:imageView attribute:NSLayoutAttributeBottom constant:0];
        [label sw_addConstraintToView:labelBgView withEqualAttribute:NSLayoutAttributeCenterY constant:0];
        [label sw_addConstraintsWithFormat:@"H:|-8-[label(106)]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)];
        label.text = @"松开，取消发送";
        
        self.imageView = imageView;
        self.titleLabel = label;
    }
    
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(350/2.0f, 350/2.0f);
}


@end
