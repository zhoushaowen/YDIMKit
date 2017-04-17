//
//  YDJoyImageMessageCell.h
//  chatList
//
//  Created by r_zhou on 2016/10/28.
//  Copyright © 2016年 r_zhous. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YDImageMessage.h"

@class YDJoyImageMessageCell;

@protocol YDJoyImageMessageCellDelegate <NSObject>
- (void)joyImageMessageCell:(YDJoyImageMessageCell *)aCell headTapGesture:(id)sender;
- (void)joyImageMessageCell:(YDJoyImageMessageCell *)aCell onDeleteMenuAction:(id)sender;
@end

@interface YDJoyImageMessageCell : UITableViewCell
@property (strong, nonatomic) id<YDJoyImageMessageCellDelegate> delegate;
@property (nonatomic,strong) id dataModel;
- (CGFloat)rowHeightWithModel:(YDImageMessage *)model;
@end
