//
//  YDJoyImageMessageCell.m
//  chatList
//
//  Created by r_zhou on 2016/10/28.
//  Copyright © 2016年 r_zhous. All rights reserved.
//

#import "YDJoyImageMessageCell.h"
#import <Masonry/Masonry.h>
#import "ORColorUtil.h"
#import "YDImageMessage.h"

@interface YDJoyImageMessageCell ()
@property (nonatomic,strong) UIImageView *headerImgV;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UILabel *nameLabel;

@property (nonatomic,strong) UIView *boxView;
@property (nonatomic,strong) UIImageView *pictureView;
@property (nonatomic,strong) UIImageView *bubbleImgV;
@property (nonatomic,assign) CGFloat topLength;
@end

@implementation YDJoyImageMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [self setupUI];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - UI
- (void)setupUI
{
    self.selectionStyle = UITableViewCellSeparatorStyleNone;
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.backgroundColor = [UIColor grayColor];
    _timeLabel.font = [UIFont systemFontOfSize:11];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.centerX.mas_equalTo(self.contentView);
        make.height.mas_equalTo(ceil(_timeLabel.font.lineHeight));
    }];
    
    self.headerImgV = [[UIImageView alloc] init];
    self.headerImgV.userInteractionEnabled = YES;
    self.headerImgV.backgroundColor = [UIColor redColor];
    _headerImgV.image = [UIImage imageNamed:@"chat_appointment"];
    [self.contentView addSubview:_headerImgV];
    [_headerImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(83/2.0f);
        make.size.mas_equalTo(44);
    }];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont systemFontOfSize:10];
    self.nameLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerImgV.mas_right).with.offset(20);
        make.top.equalTo(self.timeLabel.mas_bottom).with.offset(10);
        make.size.mas_equalTo(CGSizeMake(self.frame.size.width - self.bubbleImgV.frame.size.width - 30, 15));
    }];
    
    self.boxView = [[UIView alloc] init];
    self.boxView.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:self.boxView];
    [self.boxView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_headerImgV.mas_right).offset(0);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(0);
        make.size.mas_equalTo(CGSizeMake(self.frame.size.width/1.8, 150));
    }];
    
    self.pictureView = [[UIImageView alloc] init];
    self.pictureView.contentMode = UIViewContentModeScaleAspectFill;
//    self.pictureView.userInteractionEnabled = YES;
    self.pictureView.clipsToBounds = YES;
    [self.boxView addSubview:self.pictureView];
    [self.pictureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    self.bubbleImgV = [[UIImageView alloc] init];
    self.bubbleImgV.userInteractionEnabled = YES;
    _bubbleImgV.image = [UIImage imageNamed:@"icon_message_box"];
    [self.boxView addSubview:_bubbleImgV];
    [_bubbleImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.bubbleImgV addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headTapGesture:)];
    tap.numberOfTapsRequired = 1; // 单击
    [self.headerImgV addGestureRecognizer:tap];

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
    if ([self.delegate respondsToSelector:@selector(joyImageMessageCell:headTapGesture:)]) {
        [self.delegate joyImageMessageCell:self headTapGesture:sender];
    }
}

- (void)showMenu
{
    if ([self canBecomeFirstResponder]) {
        if ([self becomeFirstResponder]) {
            if ([self isFirstResponder]) {
                UIMenuController *menuController = [UIMenuController sharedMenuController];
                UIMenuItem *deleteMenu = [[UIMenuItem alloc] initWithTitle:@"删除"action:@selector(onDeleteMenuAction:)];
                [self becomeFirstResponder];
                
                [menuController setMenuItems:[NSArray arrayWithObjects: deleteMenu, nil]];
                
                [menuController setTargetRect:self.timeLabel.frame inView:self];
                [menuController setMenuVisible:YES animated:YES];
            }
        }
    }
}

- (void)onDeleteMenuAction:(id)sender
{
    NSLog(@"删除");
    if ([self.delegate respondsToSelector:@selector(joyImageMessageCell:onDeleteMenuAction:)]) {
        [self.delegate joyImageMessageCell:self onDeleteMenuAction:sender];
    }
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    if (action == @selector(onDeleteMenuAction:))
    {
        return YES;
    }
    return NO;
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

#pragma mark -- dataModel
- (void)setDataModel:(YDImageMessage *)contentModel
{
    YDImageMessage *imageMessage = contentModel;
    
    if (imageMessage.displayTime) {
        self.topLength = 35;
        self.timeLabel.hidden = NO;
    } else {
        self.topLength = 20;
        self.timeLabel.hidden = YES;
    }
    
    if (imageMessage.messageDirection == YDMessageDirectionSend) {
        self.nameLabel.hidden = YES;
        
        [_headerImgV mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15);
            make.top.mas_equalTo(self.topLength);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
        
        [self.boxView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(_headerImgV.mas_left).offset(0);
            make.top.mas_equalTo(_headerImgV);
            make.size.mas_equalTo(CGSizeMake(self.frame.size.width/1.8, 150));
        }];
    
        self.pictureView.image = imageMessage.contentImage;
        [self.pictureView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
    
        _bubbleImgV.image = [UIImage imageNamed:@"icon_message_box2"];
        [_bubbleImgV mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
    } else {
        self.nameLabel.hidden = NO;
        
        [_headerImgV mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.mas_equalTo(self.topLength);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
        
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.headerImgV.mas_right).with.offset(20);
            make.top.mas_equalTo(self.headerImgV);
            make.size.mas_equalTo(CGSizeMake(self.frame.size.width - self.bubbleImgV.frame.size.width - 30, 15));
        }];
        
        [self.boxView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_headerImgV.mas_right).offset(0);
            make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(0);
            make.size.mas_equalTo(CGSizeMake(self.frame.size.width/1.8, 150));
        }];
        
        self.pictureView.image = imageMessage.contentImage;
        [self.pictureView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
        
        _bubbleImgV.image = [UIImage imageNamed:@"icon_message_box"];
        [_bubbleImgV mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
    }
    self.timeLabel.text = imageMessage.timeStr;
    self.nameLabel.text = imageMessage.nickname;
}

- (CGFloat)calculateRowHeight:(NSDictionary *)model
{
    self.dataModel = model;
    [self layoutIfNeeded];
    CGFloat height = CGRectGetMaxY(self.boxView.frame) + 15;
    return height;
}

- (CGFloat)rowHeightWithModel:(id)model
{
    return [self calculateRowHeight:model];
}

@end
