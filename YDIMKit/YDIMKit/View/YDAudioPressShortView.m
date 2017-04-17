//
//  YDAudioPressShortView.m
//  Chat
//
//  Created by 周少文 on 2016/10/27.
//  Copyright © 2016年 周少文. All rights reserved.
//

#import "YDAudioPressShortView.h"
#import "UIImage+Bundle.h"
#import <SWExtension/UIView+SWAutoLayout.h>
#import <SWExtension/UIColor+Hex.h>
#import <SWExtension/UIView+HUD.h>

@implementation YDAudioPressShortView

+ (instancetype)shortView {
    YDAudioPressShortView *view = [[self alloc] initWithFrame:CGRectMake(0, 0, 350/2.0, 350/2.0)];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        UIImage *image = [UIImage imageWithBundleName:@"chat" imageName:@"audio_press_short"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [self addSubview:imageView];
        [imageView sw_addConstraintsWithFormat:@"H:[imageView(85)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)];
        [imageView sw_addConstraintsWithFormat:@"V:|-40-[imageView(85)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)];
        [imageView sw_addConstraintToView:self withEqualAttribute:NSLayoutAttributeCenterX constant:0];
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:12];
        label.text = @"说话时间太短";
        label.textColor = [UIColor colorWithHexString:@"eaeaea"];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        [label sw_addConstraintsWithFormat:@"H:|-0-[label]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)];
        [label sw_addConstraintsWithFormat:@"V:[imageView]-20-[label(h)]-10-|" options:0 metrics:@{@"h":@(ceil(label.font.lineHeight))} views:NSDictionaryOfVariableBindings(label,imageView)];
        
        self.imageView = imageView;
        self.titleLabel = label;

    }
    
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(350/2.0, 350/2.0);
}










@end
