//
//  YDChatRefreshControl.h
//  YDIMKit
//
//  Created by 周少文 on 2016/11/2.
//  Copyright © 2016年 Yidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YDChatRefreshView : UIView
{
    UIActivityIndicatorView *_activityView;
}
@end

@interface YDChatRefreshControl : UIRefreshControl

@property (nonatomic,strong) YDChatRefreshView *refreshView;

@end
