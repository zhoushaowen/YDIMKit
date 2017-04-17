//
//  YDChatBottomToolView.m
//  ChatBottom
//
//  Created by 周少文 on 2016/10/24.
//  Copyright © 2016年 周少文. All rights reserved.
//

#import "YDChatBottomToolView.h"

#import "UIImage+Bundle.h"
#import "UIColor+Hex.h"
#import <SWExtension/UIImage+SWExtension.h>
#import "UIView+SWAutoLayout.h"
#import <SWExpandResponse/UIView+ExpandResponse.h>

@interface YDChatPlusViewButton : UIButton
@end

@implementation YDChatPlusViewButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect bounds = self.bounds;
    CGFloat dx = bounds.size.width - 44.0f > 0 ? 0 : (bounds.size.width - 44.0f)/2.0f;
    CGFloat dy = bounds.size.height - 44.0f > 0 ? 0 : (bounds.size.height - 44.0f)/2.0f;
    bounds = CGRectInset(bounds, dx, dy);
    return CGRectContainsPoint(bounds, point);
}

@end

static CGFloat YDPlusViewHeight = 382/2.0;
CGFloat const YDBottomToolViewOriginalHeight = 67;
NSTimeInterval const YDKeyboardAnimationDuration = 0.25;

@interface YDChatBottomToolView ()<UITextViewDelegate,YDEmojiKeyboardViewDelegate>
{
    NSDate *_touchDownDate;
    UIImageView *_bgImgV;
    NSArray<NSLayoutConstraint *> *_centerBtnHConstraints;
    NSArray<NSLayoutConstraint *> *_textViewHConstraints;
}

@property (nonatomic,strong) UIButton *leftButton;
@property (nonatomic,strong) UIButton *emojiButton;
@property (nonatomic,strong) UIButton *plusButton;
@property (nonatomic,strong) UITextView *tempTextView;
@property (nonatomic,strong) UIButton *sendBtn;
@property (nonatomic) BOOL showSendBtn;

@end

@implementation YDChatBottomToolView

@synthesize emojiKeyboardView = _emojiKeyboardView;
@synthesize plusView = _plusView;
@synthesize emojiSendBtnBackgroundColor = _emojiSendBtnBackgroundColor;

+ (instancetype)bottomToolView {
    YDChatBottomToolView *view = [[self alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, YDBottomToolViewOriginalHeight)];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    UIImageView *bgImgV = [[UIImageView alloc] initWithImage:[[UIImage imageWithBundleName:@"chat" imageName:@"bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 30, 20, 30) resizingMode:UIImageResizingModeStretch]];
    [self addSubview:bgImgV];
    bgImgV.userInteractionEnabled = YES;
    [bgImgV sw_addConstraintsWithFormat:@"H:|-7-[bgImgV]-7-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bgImgV)];
    [bgImgV sw_addConstraintsWithFormat:@"V:|-0-[bgImgV]-7-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bgImgV)];
    _bgImgV = bgImgV;
    
    self.leftButton = [YDChatPlusViewButton buttonWithType:UIButtonTypeCustom];
    _leftButton.expandResponse = YES;
    [bgImgV addSubview:self.leftButton];
    UIImage *leftImage = [UIImage imageWithBundleName:@"chat" imageName:@"keyboard_hover"];
    [self.leftButton setImage:leftImage forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageWithBundleName:@"chat" imageName:@"talk_hover"] forState:UIControlStateSelected];
    [_leftButton sw_addConstraintsWithFormat:@"H:|-18-[_leftButton(w)]" options:0 metrics:@{@"w":@(leftImage.size.width)} views:NSDictionaryOfVariableBindings(_leftButton)];
    [_leftButton sw_addConstraintToView:bgImgV withEqualAttribute:NSLayoutAttributeCenterY constant:0];
    [self.leftButton addTarget:self action:@selector(leftButtonClick:) forControlEvents:UIControlEventTouchDown];
    
    self.plusButton = [YDChatPlusViewButton buttonWithType:UIButtonTypeCustom];
    _plusButton.expandResponse = YES;
    [bgImgV addSubview:self.plusButton];
    UIImage *plusImage = [UIImage imageWithBundleName:@"chat" imageName:@"add_hover"];
    [self.plusButton setImage:plusImage forState:UIControlStateNormal];
    [_plusButton sw_addConstraintsWithFormat:@"H:[_plusButton(w)]-18-|" options:0 metrics:@{@"w":@(plusImage.size.width)} views:NSDictionaryOfVariableBindings(_plusButton)];
    [_plusButton sw_addConstraintToView:bgImgV withEqualAttribute:NSLayoutAttributeCenterY constant:0];
    [self.plusButton addTarget:self action:@selector(plusButtonClick:) forControlEvents:UIControlEventTouchDown];
    
    self.emojiButton = [YDChatPlusViewButton buttonWithType:UIButtonTypeCustom];
    _emojiButton.expandResponse = YES;
    [self addSubview:self.emojiButton];
    self.emojiButton.translatesAutoresizingMaskIntoConstraints = NO;
    UIImage *emojiImage = [UIImage imageWithBundleName:@"chat" imageName:@"emoji_hover"];
    [self.emojiButton setImage:emojiImage forState:UIControlStateNormal];
    [self.emojiButton setImage:[UIImage imageWithBundleName:@"chat" imageName:@"keyboard_hover"] forState:UIControlStateSelected];
    [_emojiButton sw_addConstraintToView:bgImgV withEqualAttribute:NSLayoutAttributeCenterY constant:0];
    [self.emojiButton addTarget:self action:@selector(emojiButtonClick:) forControlEvents:UIControlEventTouchDown];
    _emojiButton.hidden = YES;
    
    self.centerButton = [YDChatPlusViewButton buttonWithType:UIButtonTypeCustom];
    [bgImgV addSubview:self.centerButton];
    _centerBtnHConstraints = [_centerButton sw_addConstraintsWithFormat:@"H:[_leftButton]-16-[_centerButton]-16-[_plusButton]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_leftButton,_centerButton,_plusButton)];
    [_centerButton sw_addConstraintToView:bgImgV withEqualAttribute:NSLayoutAttributeCenterY constant:0];
    [_centerButton sw_addConstraintsWithFormat:@"V:[_centerButton(35)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_centerButton)];
    [self.centerButton setTitleColor:[UIColor colorWithHexString:@"a0a0a0"] forState:UIControlStateNormal];
    self.centerButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.centerButton.layer.borderWidth = 1/[UIScreen mainScreen].scale;
    self.centerButton.layer.borderColor = [UIColor colorWithHexString:@"c3c3c3"].CGColor;
    self.centerButton.layer.cornerRadius = 35/2.0;
    self.centerButton.layer.masksToBounds = YES;
    [self.centerButton setTitle:@"请按住说话" forState:UIControlStateNormal];
    [self.centerButton setBackgroundImage:[UIImage sw_createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self.centerButton setBackgroundImage:[UIImage sw_createImageWithColor:[UIColor colorWithHexString:@"eaeaea"]] forState:UIControlStateHighlighted];
    [self.centerButton addTarget:self action:@selector(centerButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.centerButton addTarget:self action:@selector(centerButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [self.centerButton addTarget:self action:@selector(centerButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.centerButton addTarget:self action:@selector(centerButtonTouchDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
    [self.centerButton addTarget:self action:@selector(centerButtonTouchDragExit:) forControlEvents:UIControlEventTouchDragExit];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectZero];
    _textView.returnKeyType = UIReturnKeySend;
    _textView.delegate = self;
    //设置光标间距
    _textView.textContainerInset = UIEdgeInsetsMake(8, 12, 8, 12);
    //设置光标颜色
    _textView.tintColor = [UIColor colorWithHexString:@"61dadb"];
    //改变滚动条的位置
    _textView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    [bgImgV addSubview:_textView];
    _textViewHConstraints = [_textView sw_addConstraintsWithFormat:@"H:[_leftButton]-16-[_textView]-16-[_plusButton]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_leftButton,_textView,_plusButton)];
    [_textView sw_addConstraintsWithFormat:@"V:|-12.5-[_textView]-12.5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_textView)];
    _textView.layer.borderWidth = 1/[UIScreen mainScreen].scale;
    _textView.layer.borderColor = [UIColor colorWithHexString:@"c3c3c3"].CGColor;
    _textView.layer.cornerRadius = 35/2.0;
    _textView.layer.masksToBounds = YES;
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.font = [UIFont systemFontOfSize:15];
    _textView.enablesReturnKeyAutomatically = YES;
    
    self.tempTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.tempTextView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrameNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidBeginEditingNotification:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChangeNotification:) name:UITextViewTextDidChangeNotification object:nil];
    
    [self bringSubviewToFront:_centerButton];
    self.audioPressShortSecond = 1;
    [self setInputStyle:YDChatInputStyleText];
}

- (void)setInputStyle:(YDChatInputStyle)inputStyle
{
    _inputStyle = inputStyle;
    _emojiButton.selected = NO;
    _plusButton.selected = NO;
    [_tempTextView resignFirstResponder];
    if(inputStyle == YDChatInputStyleVoice)
    {
        _leftButton.selected = NO;
        _textView.hidden = YES;
        _centerButton.hidden = NO;
        [self bringSubviewToFront:_centerButton];
        [_textView resignFirstResponder];
        if(self.showSendBtn){
            self.sendBtn.hidden = YES;
        }
    }else if(inputStyle == YDChatInputStyleText){
        _leftButton.selected = YES;
        _textView.hidden = NO;
        _centerButton.hidden = YES;
        [self bringSubviewToFront:_textView];
        if(self.showSendBtn){
            self.sendBtn.hidden = NO;
        }
    }
}

#pragma mark - Action
- (void)leftButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _emojiButton.selected = NO;
    _plusButton.selected = NO;
    [_tempTextView resignFirstResponder];
    if(sender.isSelected)
    {
        _textView.hidden = NO;
        _centerButton.hidden = YES;
        [self bringSubviewToFront:_textView];
        [_textView resignFirstResponder];
        _textView.inputView = nil;
        [_textView becomeFirstResponder];
        if(self.showSendBtn){
            self.sendBtn.hidden = NO;
        }
    }else{
        _textView.hidden = YES;
        _centerButton.hidden = NO;
        [self bringSubviewToFront:_centerButton];
        [_textView resignFirstResponder];
        if(self.showSendBtn){
            self.sendBtn.hidden = YES;
        }
    }
}

- (void)emojiButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _leftButton.selected = YES;
    _plusButton.selected = NO;
    [self bringSubviewToFront:_textView];
    _centerButton.hidden = YES;
    _textView.hidden = NO;
    if(sender.isSelected)
    {
        [_textView resignFirstResponder];
        [_tempTextView resignFirstResponder];
        _tempTextView.inputView = self.emojiKeyboardView;
        [_tempTextView becomeFirstResponder];
    }else{
        [_tempTextView resignFirstResponder];
        [_textView resignFirstResponder];
        _textView.inputView = nil;
        [_textView becomeFirstResponder];
    }
}

- (void)plusButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _leftButton.selected = YES;
    _emojiButton.selected = NO;
    [self bringSubviewToFront:_textView];
    _centerButton.hidden = YES;
    _textView.hidden = NO;
    if(sender.isSelected)
    {
        [_textView resignFirstResponder];
        [_tempTextView resignFirstResponder];
        _tempTextView.inputView = self.plusView;
        [_tempTextView becomeFirstResponder];
    }else{
        [_tempTextView resignFirstResponder];
        [_textView resignFirstResponder];
        _textView.inputView = nil;
        [_textView becomeFirstResponder];
    }
}

- (void)centerButtonTouchUpInside:(UIButton *)sender
{
    [self setCenterBtnTitle:@"请按住说话"];
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitSecond fromDate:_touchDownDate toDate:currentDate options:0];
    BOOL flag;
    if(components.second < self.audioPressShortSecond)
    {
        flag = NO;
        if(_delegate && [_delegate respondsToSelector:@selector(chatBottomToolView:recordButtonShortPress:)]){
            [_delegate chatBottomToolView:self recordButtonShortPress:sender];
        }
    }else{
        flag = YES;
        [self hideCustomView];
    }
    if(_delegate && [_delegate respondsToSelector:@selector(chatBottomToolView:recordButtonTouchUpInside:completeRecord:)])
    {
        [_delegate chatBottomToolView:self recordButtonTouchUpInside:sender completeRecord:flag];
    }
}

- (void)centerButtonTouchUpOutside:(UIButton *)sender
{
    [self setCenterBtnTitle:@"请按住说话"];
    if(_delegate && [_delegate respondsToSelector:@selector(chatBottomToolView:recordButtonTouchUpOutside:)])
    {
        [_delegate chatBottomToolView:self recordButtonTouchUpOutside:sender];
    }
}

- (void)centerButtonTouchDown:(UIButton *)sender
{
    [self setCenterBtnTitle:@"松开 发送"];
    _touchDownDate = [NSDate date];
    if(_delegate && [_delegate respondsToSelector:@selector(chatBottomToolView:recordButtonTouchDown:)])
    {
        [_delegate chatBottomToolView:self recordButtonTouchDown:sender];
    }
}

- (void)centerButtonTouchDragEnter:(UIButton *)sender
{
    [self setCenterBtnTitle:@"松开 发送"];
    if(_delegate && [_delegate respondsToSelector:@selector(chatBottomToolView:recordButtonTouchDragEnter:)])
    {
        [_delegate chatBottomToolView:self recordButtonTouchDragEnter:sender];
    }
}

- (void)centerButtonTouchDragExit:(UIButton *)sender
{
    [self setCenterBtnTitle:@"松开,取消发送"];
    if(_delegate && [_delegate respondsToSelector:@selector(chatBottomToolView:recordButtonTouchDragExit:)])
    {
        [_delegate chatBottomToolView:self recordButtonTouchDragExit:sender];
    }
}

- (void)setCenterBtnTitle:(NSString *)title
{
    [_centerButton setTitle:title forState:UIControlStateNormal];
}

- (MBProgressHUD *)showCustomView:(UIView *)customView
{
    return [[UIApplication sharedApplication].keyWindow showHUDWithCustomView:customView];
}

- (void)hideCustomView
{
    [[UIApplication sharedApplication].keyWindow hideHUDAnimated:NO];
}

#pragma mark - Notification
- (void)keyboardWillChangeFrameNotification:(NSNotification *)notification
{
    if(_delegate && [_delegate respondsToSelector:@selector(chatBottomToolView:keyboardWillChangeFrameNotification:)])
    {
        [_delegate chatBottomToolView:self keyboardWillChangeFrameNotification:notification];
    }
}

- (void)textViewDidBeginEditingNotification:(NSNotification *)notification
{
    if(notification.object == _textView)
    {
        _emojiButton.selected = NO;
        _plusButton.selected = NO;
    }
}

- (void)textViewTextDidChangeNotification:(NSNotification *)notification
{
    if(notification.object != _textView)
        return;
    if(_delegate && [_delegate respondsToSelector:@selector(chatBottomToolView:textViewTextDidChange:)])
    {
        UITextView *textView = notification.object;
        [_delegate chatBottomToolView:self textViewTextDidChange:textView];
    }
    _sendBtn.hidden = !(_textView.text.length > 0);
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [self sendText];
        return NO;
    }
    return YES;
}


#pragma mark - YDEmojiKeyboardViewDelegate
- (void)emojiKeyboardView:(YDEmojiKeyboardView *)view didSelected:(NSString *)emojiString isDelete:(BOOL)isDelete
{
    if(isDelete)
    {
        [_textView deleteBackward];
    }else{
        
        [_textView insertText:emojiString];
    }
}

- (void)emojiKeyboardViewDidClickSendButton:(YDEmojiKeyboardView *)view
{
    [self sendText];
}

- (void)sendText
{
    if(_textView.text.length < 1)
        return;
    if(_delegate && [_delegate respondsToSelector:@selector(chatBottomToolView:didClickSendButton:)])
    {
        [_delegate chatBottomToolView:self didClickSendButton:_textView.text];
    }
    _textView.text = nil;
    if(_delegate && [_delegate respondsToSelector:@selector(chatBottomToolView:textViewTextDidChange:)]){
        [_delegate chatBottomToolView:self textViewTextDidChange:_textView];
    }
    _sendBtn.hidden = YES;
}

- (void)setShowSendBtn:(BOOL)showSendBtn
{
    _showSendBtn = showSendBtn;
    if(showSendBtn){
        self.plusButton.hidden = YES;
        if(!self.sendBtn.superview){
            [_bgImgV addSubview:self.sendBtn];
            [self.sendBtn sw_addConstraintToView:_bgImgV withEqualAttribute:NSLayoutAttributeCenterY constant:0];
            [self.sendBtn sw_addConstraintsWithFormat:@"H:[_textView]-6-[_sendBtn(40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_sendBtn,_textView)];
            [self.sendBtn sw_addConstraintsWithFormat:@"V:[_sendBtn(35)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_sendBtn)];
        }
    }else{
        self.sendBtn.hidden = YES;
        self.plusButton.hidden = NO;
    }
}

#pragma mark - Lazy
- (YDEmojiKeyboardView *)emojiKeyboardView
{
    if(!_emojiKeyboardView)
    {
        _emojiKeyboardView = [[YDEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, YDEmojiKeyboardHeight)];
        _emojiKeyboardView.delegate = self;
    }
    
    return _emojiKeyboardView;
}

- (YDChatPlusView *)plusView
{
    if(!_plusView)
    {
        _plusView = [[YDChatPlusView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, YDPlusViewHeight)];
        __weak typeof(self) weakSelf = self;
        _plusView.actionItemClick = ^(id<YDActionItemProtocol> item){
            if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(chatBottomToolView:actionItemClick:)])
            {
                [weakSelf.delegate chatBottomToolView:weakSelf actionItemClick:item];
            }
        };
        _inputViewBackgroundColor = _plusView.collectionView.backgroundColor;
    }
    return _plusView;
}

- (YDRecordingView *)recordingView
{
    if(!_recordingView)
    {
        _recordingView = [YDRecordingView recordingView];
    }
    return _recordingView;
}

- (YDCancelSendView *)cancelSendView
{
    if(!_cancelSendView)
    {
        _cancelSendView = [YDCancelSendView cancelSendView];
    }
    return _cancelSendView;
}

- (YDAudioPressShortView *)audioPressShortView
{
    if(!_audioPressShortView)
    {
        _audioPressShortView = [YDAudioPressShortView shortView];
    }
    
    return _audioPressShortView;
}

- (void)resignTextViewFirstResponder
{
    [_textView resignFirstResponder];
    [_tempTextView resignFirstResponder];
}

#pragma mark - Setter

- (void)setInputViewBackgroundColor:(UIColor *)inputViewBackgroundColor
{
    _inputViewBackgroundColor = inputViewBackgroundColor;
    self.plusView.collectionView.backgroundColor = inputViewBackgroundColor;
    self.emojiKeyboardView.collectionView.backgroundColor = inputViewBackgroundColor;
}

- (void)setEmojiSendBtnBackgroundColor:(UIColor *)emojiSendBtnBackgroundColor
{
    _emojiSendBtnBackgroundColor = emojiSendBtnBackgroundColor;
    self.emojiKeyboardView.emojiSendBtnBackgroundColor = emojiSendBtnBackgroundColor;
}

- (void)setChatStyle:(YDChatStyle)chatStyle
{
    _chatStyle = chatStyle;
    switch (chatStyle) {
        case YDChatStyleXiaoYi:{
            self.showSendBtn = NO;
            YDPlusViewHeight = 382/2.0;
            self.plusView.chatStyle = chatStyle;
            [self.plusView.collectionView reloadData];
            [self hideEmoji];
        }
            break;
            
            case YDChatStylePrivate:{
                self.showSendBtn = NO;
                YDPlusViewHeight = 510/2.0;
                CGRect rect = self.plusView.frame;
                rect.size.height = YDPlusViewHeight;
                self.plusView.frame = rect;
                self.plusView.chatStyle = chatStyle;
                [self.plusView.collectionView reloadData];
                [self showEmoji];
        }
            break;
            
            case YDChatStyleSearch:{
                self.showSendBtn = YES;
                [self hideEmoji];
                _sendBtn.hidden = !(_textView.text.length>0);
        }
            break;
            
        default:
            break;
    }
}

- (UIColor *)emojiSendBtnBackgroundColor
{
    return self.emojiKeyboardView.emojiSendBtnBackgroundColor;
}

- (UIButton *)sendBtn
{
    if(!_sendBtn){
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendBtn setBackgroundImage:[UIImage sw_createImageWithColor:[UIColor colorWithHexString:@"61dadb"]] forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        _sendBtn.layer.cornerRadius = 3;
        _sendBtn.layer.masksToBounds = YES;
        [_sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}

- (void)sendBtnClick:(UIButton *)sender {
    [self sendText];
}

#pragma mark - Private
- (void)showEmoji {
    _emojiButton.hidden = NO;
    [NSLayoutConstraint deactivateConstraints:_centerBtnHConstraints];
    _centerBtnHConstraints = [_centerButton sw_addConstraintsWithFormat:@"H:[_leftButton]-16-[_centerButton]-16-[_emojiButton(w)]-16-[_plusButton]" options:0 metrics:@{@"w":@(_emojiButton.currentImage.size.width)} views:NSDictionaryOfVariableBindings(_leftButton,_centerButton,_emojiButton,_plusButton)];
    [NSLayoutConstraint deactivateConstraints:_textViewHConstraints];
    _textViewHConstraints = [_textView sw_addConstraintsWithFormat:@"H:[_leftButton]-16-[_textView]-16-[_emojiButton]-16-[_plusButton]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_leftButton,_textView,_emojiButton,_plusButton)];
}

- (void)hideEmoji {
    _emojiButton.hidden = YES;
    [NSLayoutConstraint deactivateConstraints:_centerBtnHConstraints];
    _centerBtnHConstraints = [_centerButton sw_addConstraintsWithFormat:@"H:[_leftButton]-16-[_centerButton]-16-[_plusButton]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_leftButton,_centerButton,_plusButton)];
    [NSLayoutConstraint deactivateConstraints:_textViewHConstraints];
    _textViewHConstraints = [_textView sw_addConstraintsWithFormat:@"H:[_leftButton]-16-[_textView]-16-[_plusButton]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_leftButton,_textView,_plusButton)];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
