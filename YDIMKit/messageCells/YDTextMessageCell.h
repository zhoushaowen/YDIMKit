//
//  YDTextMessageCell.h
//  chatList
//
//  Created by r_zhou on 2016/10/28.
//  Copyright © 2016年 r_zhous. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YDMessageCell.h"
#import "YDBaseMessage.h"

@class YDTextMessageCell;

@protocol YDTextMessageCellDelegate <NSObject>
- (void)textMessageCell:(YDTextMessageCell *)aCell headTapGesture:(id)sender;
- (void)textMessageCell:(YDTextMessageCell *)aCell onDeleteMenuAction:(id)sender;
@end


@interface YDTextMessageCell : YDMessageCell
@property (strong, nonatomic) id<YDTextMessageCellDelegate> delegate;
- (CGFloat)rowHeightWithModel:(YDBaseMessage *)model;
@end
