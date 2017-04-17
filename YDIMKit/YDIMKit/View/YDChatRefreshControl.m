//
//  YDChatRefreshControl.m
//  YDIMKit
//
//  Created by 周少文 on 2016/11/2.
//  Copyright © 2016年 Yidu. All rights reserved.
//

#import "YDChatRefreshControl.h"
#import <SWExtension/UIView+SWAutoLayout.h>

@implementation YDChatRefreshView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = [UIColor whiteColor];
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_activityView];
        [_activityView sw_addConstraintToView:self withEqualAttribute:NSLayoutAttributeCenterX constant:0];
        [_activityView sw_addConstraintToView:self withEqualAttribute:NSLayoutAttributeCenterY constant:0];
    }
    
    return self;
}

- (void)startAnimating
{
    [_activityView startAnimating];
}

- (void)stopAnimating
{
    [_activityView stopAnimating];
}


@end

@implementation YDChatRefreshControl

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        _refreshView = [[YDChatRefreshView alloc] initWithFrame:CGRectZero];
        [self addSubview:_refreshView];
        [_refreshView sw_addConstraintToView:self withEqualAttribute:NSLayoutAttributeCenterX constant:0];
        [_refreshView sw_addConstraintToView:self withEqualAttribute:NSLayoutAttributeCenterY constant:0];
        [_refreshView sw_addConstraintsWithFormat:@"H:[_refreshView(150)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_refreshView)];
        [_refreshView sw_addConstraintsWithFormat:@"V:[_refreshView(50)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_refreshView)];
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if(self.isRefreshing)
    {
        [_refreshView startAnimating];
    }else{
        [_refreshView stopAnimating];
    }
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"frame"];
}


@end
