//
//  YDTextMessageCell.m
//  chatList
//
//  Created by r_zhou on 2016/10/28.
//  Copyright © 2016年 r_zhous. All rights reserved.
//

#import "YDTextMessageCell.h"
#import "YDBaseMessage.h"

@interface YDTextMessageCell()
@property (nonatomic,strong) UILabel *contentLab;
@end

@implementation YDTextMessageCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentLab = [[UILabel alloc] init];
        self.contentLab.font = [UIFont systemFontOfSize:15];
        self.contentLab.numberOfLines = 0;
        [self.bubbleImgV addSubview:self.contentLab];
        [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(17);
            make.top.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.bottom.mas_equalTo(-10);
        }];
        self.contentLab.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 172/2.0f - 140/2.0f;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - 手势
- (void)longPressed:(id)sender
{
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        [self showMenu];
    }
}

- (void)headTapGesture:(id)sender
{
    NSLog(@"头像图片点击事件");
    if ([self.delegate respondsToSelector:@selector(textMessageCell:headTapGesture:)]) {
        [self.delegate textMessageCell:self headTapGesture:sender];
    }
}

#pragma mark - 菜单
- (void)showMenu
{
    if ([self canBecomeFirstResponder]) {
        if ([self becomeFirstResponder]) {
            if ([self isFirstResponder]) {
                UIMenuController *menuController = [UIMenuController sharedMenuController];
                UIMenuItem *copyMenu = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(onCopyMenuAction:)];
                UIMenuItem *deleteMenu = [[UIMenuItem alloc] initWithTitle:@"删除"action:@selector(onDeleteMenuAction:)];
                [self becomeFirstResponder];
                
                [menuController setMenuItems:[NSArray arrayWithObjects:copyMenu, deleteMenu, nil]];
                
                [menuController setTargetRect:self.bubbleImgV.frame inView:self];
                [menuController setMenuVisible:YES animated:YES];
            }
        }
    }
}

- (void)onCopyMenuAction:(id)sender
{
    NSLog(@"复制");
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:self.contentLab.text];
}

- (void)onDeleteMenuAction:(id)sender
{
    NSLog(@"删除");
    if ([self.delegate respondsToSelector:@selector(textMessageCell:onDeleteMenuAction:)]) {
        [self.delegate textMessageCell:self onDeleteMenuAction:sender];
    }
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    if (action == @selector(onCopyMenuAction:) || action == @selector(onDeleteMenuAction:))
    {
        return YES;
    }
    return NO;
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)rotatingOverloadingTapGesture:(id)sender
{
    NSLog(@"123213");
    
}

#pragma mark -- dataModel
- (void)setDataModel:(YDBaseMessage *)contentModel
{
    [super setDataModel:contentModel];
    YDBaseMessage *message = contentModel;
    
    self.displayTime = message.displayTime;
    self.isReceiver = message.messageDirection == YDMessageDirectionReceive;
    
    [self updateCellLayout];
    
    if (!self.isReceiver) {
        [self.contentLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.top.mas_equalTo(10);
            make.right.mas_equalTo(-17);
            make.bottom.mas_equalTo(-10);
        }];
    } else {
        [self.contentLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(17);
            make.top.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.bottom.mas_equalTo(-10);
        }];
    }
    
    [self.headerImgV setImage:[UIImage imageNamed:@"icon_message_defaultHead"]];
    self.contentLab.text = message.messageContent;
    self.timeLabel.text = message.timeStr;
    self.nameLabel.text = message.nickname;
    
    if (message.messageStatus == YDMessageSendStatusFail) {
        self.promptImageView.hidden = NO;
        self.rotateImageView.hidden = YES;
    } else {
        self.promptImageView.hidden = YES;
        self.rotateImageView.hidden = YES;
    }
}

- (CGFloat)calculateRowHeight:(NSDictionary *)model
{
    self.dataModel = model;
    [self layoutIfNeeded];
    CGFloat height = CGRectGetMaxY(self.bubbleImgV.frame) + 15;
    return height;
}

- (CGFloat)rowHeightWithModel:(id)model
{
    return [self calculateRowHeight:model];
}

@end
