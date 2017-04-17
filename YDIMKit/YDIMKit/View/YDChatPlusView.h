//
//  YDChatPlusView.h
//  Chat
//
//  Created by 周少文 on 2016/10/24.
//  Copyright © 2016年 周少文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YDActionItemProtocol.h"
#import "YDChatBaseViewController.h"

@interface YDChatPlusView : UIView

@property (nonatomic,copy) NSArray<id<YDActionItemProtocol>> *actionItems;
@property (nonatomic,strong) void(^actionItemClick)(id<YDActionItemProtocol>);
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic) YDChatStyle chatStyle;


@end
