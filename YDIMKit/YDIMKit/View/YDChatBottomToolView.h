//
//  YDChatBottomToolView.h
//  ChatBottom
//
//  Created by 周少文 on 2016/10/24.
//  Copyright © 2016年 周少文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YDEmojiKeyboardView.h"
#import "YDChatPlusView.h"
#import "YDRecordingView.h"
#import "YDCancelSendView.h"
#import "YDAudioPressShortView.h"
#import "YDChatBaseViewController.h"
#import "UIView+HUD.h"

@class YDChatBottomToolView;

@protocol YDChatBottomToolViewDelegate <NSObject>

@optional

- (void)chatBottomToolView:(YDChatBottomToolView *)toolView textViewTextDidChange:(UITextView *)textView;
- (void)chatBottomToolView:(YDChatBottomToolView *)toolView keyboardWillChangeFrameNotification:(NSNotification *)notification;
- (void)chatBottomToolView:(YDChatBottomToolView *)toolView didClickSendButton:(NSString *)text;
- (void)chatBottomToolView:(YDChatBottomToolView *)toolView actionItemClick:(id<YDActionItemProtocol>)item;
- (void)chatBottomToolView:(YDChatBottomToolView *)toolView recordButtonTouchUpInside:(UIButton *)recordBtn completeRecord:(BOOL)isComplete;
- (void)chatBottomToolView:(YDChatBottomToolView *)toolView recordButtonTouchUpOutside:(UIButton *)recordBtn;
- (void)chatBottomToolView:(YDChatBottomToolView *)toolView recordButtonTouchDragEnter:(UIButton *)recordBtn;
- (void)chatBottomToolView:(YDChatBottomToolView *)toolView recordButtonTouchDragExit:(UIButton *)recordBtn;
- (void)chatBottomToolView:(YDChatBottomToolView *)toolView recordButtonTouchDown:(UIButton *)recordBtn;
- (void)chatBottomToolView:(YDChatBottomToolView *)toolView recordButtonShortPress:(UIButton *)recordBtn;


@end

extern CGFloat const YDBottomToolViewOriginalHeight;

@interface YDChatBottomToolView : UIView

@property (nonatomic,strong,readonly) UITextView *textView;
@property (nonatomic,strong,readonly) YDEmojiKeyboardView *emojiKeyboardView;
@property (nonatomic,strong,readonly) YDChatPlusView *plusView;
@property (nonatomic,weak) id<YDChatBottomToolViewDelegate> delegate;
@property (nonatomic,strong) YDRecordingView *recordingView;
@property (nonatomic,strong) YDCancelSendView *cancelSendView;
@property (nonatomic,strong) YDAudioPressShortView *audioPressShortView;
@property (nonatomic,strong) MBProgressHUD *recordingHUD;
@property (nonatomic,strong) MBProgressHUD *cancelSendHUD;
@property (nonatomic,strong) MBProgressHUD *audioPressShortHUD;
@property (nonatomic,strong) UIButton *centerButton;
@property (nonatomic,strong) UIColor *inputViewBackgroundColor;
@property (nonatomic,strong) UIColor *emojiSendBtnBackgroundColor;
@property (nonatomic) NSUInteger audioPressShortSecond;
@property (nonatomic) YDChatInputStyle inputStyle;
@property (nonatomic) YDChatStyle chatStyle;

- (void)resignTextViewFirstResponder;
+ (instancetype)bottomToolView;

@end
