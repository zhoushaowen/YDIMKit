//
//  YDEmojiKeyboardView.m
//  Chat
//
//  Created by 周少文 on 2016/10/24.
//  Copyright © 2016年 周少文. All rights reserved.
//

#import "YDEmojiKeyboardView.h"
#import "YDEmojiKeyboardCell.h"
#import "UIColor+Hex.h"
#import "UIView+SWAutoLayout.h"
#import "NSString+Emoji.h"
#import "UIImage+Bundle.h"
#import <SWExtension/UIImage+SWExtension.h>

const CGFloat YDEmojiKeyboardHeight = 220;

@interface YDEmojiKeyboardView ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSArray *_array;
    UIPageControl *_pageControl;
}

@end

@implementation YDEmojiKeyboardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, YDEmojiKeyboardHeight-40);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(10, 0, 0, 0);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, YDEmojiKeyboardHeight - 40) collectionViewLayout:layout];
        [_collectionView registerClass:[YDEmojiKeyboardCell class] forCellWithReuseIdentifier:@"cell"];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = [UIColor colorWithHexString:@"F9F9F9"];
        _collectionView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_collectionView];
        
        UIView *bottomView = [[UIView alloc] init];
        bottomView.backgroundColor = [UIColor colorWithHexString:@"FFFFFF"];
        [self addSubview:bottomView];
        [bottomView sw_addConstraintsWithFormat:@"H:|-0-[bottomView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bottomView)];
        [bottomView sw_addConstraintsWithFormat:@"V:[bottomView(40)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bottomView)];
        bottomView.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [sendBtn setTitleColor:[UIColor colorWithHexString:@"FFFFFF"] forState:UIControlStateNormal];
        [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        sendBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        self.emojiSendBtnBackgroundColor = [UIColor colorWithHexString:@"51D6DB"];
        [sendBtn setBackgroundImage:[UIImage sw_createImageWithColor:self.emojiSendBtnBackgroundColor] forState:UIControlStateNormal];
        [bottomView addSubview:sendBtn];
        [sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [sendBtn sw_addConstraintsWithFormat:@"H:[sendBtn(80)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sendBtn)];
        [sendBtn sw_addConstraintsWithFormat:@"V:|-0-[sendBtn]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sendBtn)];
        self.emojiSendBtn = sendBtn;
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [UIColor colorWithHexString:@"B7B7CC"];
        label.text = @"常用表情";
        label.textAlignment = NSTextAlignmentCenter;
        [bottomView addSubview:label];
        [label sw_addConstraintsWithFormat:@"H:|-0-[label(84)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)];
        [label sw_addConstraintsWithFormat:@"V:|-0-[label]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)];
        [label setNeedsLayout];
        [label layoutIfNeeded];
        CALayer *line = [CALayer layer];
        line.backgroundColor = [[UIColor colorWithHexString:@"000000"] colorWithAlphaComponent:0.2f].CGColor;
        line.frame = CGRectMake(label.frame.size.width-1/[UIScreen mainScreen].scale, 0, 1/[UIScreen mainScreen].scale, label.frame.size.height);
        [label.layer addSublayer:line];
        
        _pageControl = [[UIPageControl alloc] init];
        [self addSubview:_pageControl];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithHexString:@"D8D8D8"];
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"8C8C96"];
        [_pageControl sw_addConstraintsWithFormat:@"V:[_pageControl]-0-[bottomView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_pageControl,bottomView)];
        [_pageControl sw_addConstraintToView:self withEqualAttribute:NSLayoutAttributeCenterX constant:0];
        
        
        [self loadEmoji];
        
    }
    
    return self;
}

- (void)loadEmoji
{
    NSString *path = [[[NSBundle mainBundle] pathForResource:@"chat.bundle" ofType:nil] stringByAppendingPathComponent:@"emotion.plist"];
    NSArray *arr = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray *mutableArr = [NSMutableArray arrayWithCapacity:0];
    [arr enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *emoji = [NSString emojiWithHexString:obj[@"code"]];
        [mutableArr addObject:emoji];
    }];
    _array = mutableArr;
    [_collectionView reloadData];
    _pageControl.numberOfPages = [_collectionView numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if(_array ==nil)
        return 0;
    if(_array.count%23 ==0)
    {
        return (NSInteger)_array.count/23;
    }else
    {
        return (NSInteger)_array.count/23+1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YDEmojiKeyboardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    [cell.btnArray enumerateObjectsUsingBlock:^(UIButton*  _Nonnull btn, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger index = idx+23*indexPath.section;
        if(index<=_array.count-1)
        {
            if(idx <23)
            {
                [btn setImage:nil forState:UIControlStateNormal];
                [btn setTitle:_array[idx+23*indexPath.section] forState:UIControlStateNormal];
                
            }else
            {
                [btn setTitle:@"" forState:UIControlStateNormal];
                [btn setImage:[UIImage imageWithBundleName:@"chat" imageName:@"chat_delete"] forState:UIControlStateNormal];
            }
            
        }else if(index ==_array.count)
        {
            [btn setTitle:@"" forState:UIControlStateNormal];
            [btn setImage:[UIImage imageWithBundleName:@"chat" imageName:@"chat_delete"] forState:UIControlStateNormal];
            
        }else
        {
            [btn setImage:nil forState:UIControlStateNormal];
            [btn setTitle:@"" forState:UIControlStateNormal];
        }
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }];
    
    return cell;
}

- (void)btnClick:(UIButton *)sender
{
    if(_delegate&&[_delegate respondsToSelector:@selector(emojiKeyboardView:didSelected:isDelete:)])
    {
        if(sender.currentTitle.length>0)
        {
            [_delegate emojiKeyboardView:self didSelected:sender.currentTitle isDelete:NO];
            
        }else if (sender.currentImage)
        {
            [_delegate emojiKeyboardView:self didSelected:nil isDelete:YES];
        }
    }
    
}

- (void)sendBtnClick:(UIButton *)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(emojiKeyboardViewDidClickSendButton:)])
    {
        [_delegate emojiKeyboardViewDidClickSendButton:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = scrollView.contentOffset.x/[UIScreen mainScreen].bounds.size.width;
    _pageControl.currentPage = index;
}

- (void)setEmojiSendBtnBackgroundColor:(UIColor *)emojiSendBtnBackgroundColor
{
    _emojiSendBtnBackgroundColor = emojiSendBtnBackgroundColor;
    [self.emojiSendBtn setBackgroundImage:[UIImage sw_createImageWithColor:emojiSendBtnBackgroundColor] forState:UIControlStateNormal];
}


@end
