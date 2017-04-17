//
//  YDEmojiKeyboardView.h
//  Chat
//
//  Created by 周少文 on 2016/10/24.
//  Copyright © 2016年 周少文. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YDEmojiKeyboardView;

@protocol YDEmojiKeyboardViewDelegate <NSObject>

- (void)emojiKeyboardView:(YDEmojiKeyboardView *)view didSelected:(NSString *)emojiString isDelete:(BOOL)isDelete;
- (void)emojiKeyboardViewDidClickSendButton:(YDEmojiKeyboardView *)view;

@end

extern const CGFloat YDEmojiKeyboardHeight;

@interface YDEmojiKeyboardView : UIView

@property (nonatomic,weak) id<YDEmojiKeyboardViewDelegate> delegate;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UIButton *emojiSendBtn;
@property (nonatomic,strong) UIColor *emojiSendBtnBackgroundColor;


@end
