//
//  YDChatPlusView.m
//  Chat
//
//  Created by 周少文 on 2016/10/24.
//  Copyright © 2016年 周少文. All rights reserved.
//

#import "YDChatPlusView.h"
#import "YDPlusViewModel.h"
#import "UIImage+Bundle.h"
#import <SWExtension.h>

//static CGFloat const itemWidth = 50;
//static CGFloat const itemHeight = 50;

@interface YDChatPlusCollectionViewLayout : UICollectionViewLayout

@property (nonatomic,strong) NSMutableArray *mutableArr;
@property (nonatomic) YDChatStyle chatStyle;


@end

@interface YDChatPlusCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView *imgV;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic) YDChatStyle chatStyle;
@property (nonatomic,strong) NSLayoutConstraint *widthConstraint;
@property (nonatomic,strong) NSLayoutConstraint *heightConstraint;

@end

@implementation YDChatPlusCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        _imgV = imageView;
        NSArray *hConstraints =  [_imgV sw_addConstraintsWithFormat:@"H:[_imgV(22)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_imgV)];
        NSArray *vConstraints = [_imgV sw_addConstraintsWithFormat:@"V:|-0-[_imgV(22)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_imgV)];
        _widthConstraint = [hConstraints firstObject];
        _heightConstraint = vConstraints[1];
        [imageView sw_addConstraintToView:self.contentView withEqualAttribute:NSLayoutAttributeCenterX constant:0];
        self.nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:13];
        _nameLabel.textColor = [UIColor grayColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_nameLabel];
        [_nameLabel sw_addConstraintsWithFormat:@"V:[_nameLabel(h)]-0-|" options:0 metrics:@{@"h":@(ceil(_nameLabel.font.lineHeight))} views:NSDictionaryOfVariableBindings(_nameLabel)];
        [_nameLabel sw_addConstraintToView:self.contentView withEqualAttribute:NSLayoutAttributeCenterX constant:0];
    }
    
    return self;
}

- (void)setChatStyle:(YDChatStyle)chatStyle
{
    _chatStyle = chatStyle;
    CGFloat wh = 0;
    if(_chatStyle == YDChatStyleXiaoYi){
        wh = 22;
    }else if (_chatStyle == YDChatStylePrivate){
        wh = 55;
    }
    _widthConstraint.constant = wh;
    _heightConstraint.constant = wh;
}

@end

@interface YDChatPlusView ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    UIPageControl *_pageControl;
    YDChatPlusCollectionViewLayout *_layout;
}
@end

@implementation YDChatPlusView

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
    YDChatPlusCollectionViewLayout *layout = [[YDChatPlusCollectionViewLayout alloc] init];
    layout.chatStyle = _chatStyle;
    _layout = layout;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.pagingEnabled = YES;
    [self addSubview:_collectionView];
    [_collectionView registerClass:[YDChatPlusCell class] forCellWithReuseIdentifier:@"cell"];
    _collectionView.showsHorizontalScrollIndicator = NO;
    
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.hidesForSinglePage = YES;
    [self addSubview:_pageControl];
    [_pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    _pageControl.pageIndicatorTintColor = [UIColor colorWithHexString:@"efefef"];
    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"d3d3d3"];
    [_pageControl sw_addConstraintToView:self withEqualAttribute:NSLayoutAttributeCenterX constant:0];
    [_pageControl sw_addConstraintsWithFormat:@"V:[_pageControl]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_pageControl)];
    
    NSArray *titleNames = @[@"照片",@"拍照",@"定位",@"文件"];
    NSArray *imageNames = @[@"actionbar_picture_icon",@"actionbar_camera_icon",@"actionbar_location_icon",@"actionbar_file_icon"];
    NSMutableArray *mutableArr = [NSMutableArray arrayWithCapacity:0];
    for(int i = 0;i < 4;i++)
    {
        YDPlusViewModel *model = [[YDPlusViewModel alloc] init];
        model.titleName = titleNames[i];
        model.image = [UIImage imageWithBundleName:@"chat" imageName:imageNames[i]];
        [mutableArr addObject:model];
    }
    self.actionItems = mutableArr;
    _pageControl.numberOfPages = ceil(_actionItems.count/8.0);
}

- (void)setChatStyle:(YDChatStyle)chatStyle
{
    _chatStyle = chatStyle;
    _layout.chatStyle = chatStyle;
    [_layout invalidateLayout];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _actionItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YDChatPlusCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.chatStyle = _chatStyle;
    YDPlusViewModel *model = _actionItems[indexPath.row];
    cell.imgV.image = model.image;
    cell.nameLabel.text = model.titleName;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(_actionItemClick)
    {
        _actionItemClick(_actionItems[indexPath.item]);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x/scrollView.frame.size.width;
    _pageControl.currentPage = index;
}

- (void)pageControlValueChanged:(UIPageControl *)control {
    [_collectionView setContentOffset:CGPointMake(_collectionView.frame.size.width*control.currentPage, 0) animated:YES];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _collectionView.frame = self.bounds;
}

- (void)btnClick:(UIButton *)sender
{
    if(_actionItemClick)
    {
        _actionItemClick(_actionItems[sender.tag]);
    }
}

- (void)setActionItems:(NSArray<id<YDActionItemProtocol>> *)actionItems
{
    _actionItems = actionItems;
    [_collectionView reloadData];
    _pageControl.numberOfPages = ceil(_actionItems.count/8.0);
}

@end

@implementation YDChatPlusCollectionViewLayout
{
    CGFloat _itemWidth;
    CGFloat _itemHeight;
}

- (void)prepareLayout
{
    [super prepareLayout];
    if(_chatStyle == YDChatStyleXiaoYi){
        _itemWidth = 50;
        _itemHeight = 50;
    }else if (_chatStyle == YDChatStylePrivate){
        _itemWidth = 55;
        _itemHeight = 80;
    }
    [self createLayoutAttributes];
}

- (void)createLayoutAttributes {
    CGFloat marginH = ([UIScreen mainScreen].bounds.size.width - 4*_itemWidth)/4.0;
    NSInteger totalItems = [self.collectionView numberOfItemsInSection:0];
    for(int i=0;i<totalItems;i++){
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        //第几页
        NSInteger index = i/8;
        CGFloat x = i%8%4*(marginH+_itemWidth)+marginH/2.0+index*self.collectionView.frame.size.width;
        CGFloat y = i%8/4*(15+_itemHeight) + 25;
        attributes.frame = CGRectMake(x, y, _itemWidth, _itemHeight);
        [self.mutableArr addObject:attributes];
    }
}

- (NSMutableArray *)mutableArr {
    if(!_mutableArr){
        _mutableArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _mutableArr;
}

- (CGSize)collectionViewContentSize
{
    NSInteger index = ceil([self.collectionView numberOfItemsInSection:0]/8.0);
    return CGSizeMake(self.collectionView.frame.size.width*(index), self.collectionView.frame.size.height);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.mutableArr filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes*  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return CGRectIntersectsRect(evaluatedObject.frame, rect);
    }]];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.mutableArr[indexPath.item];
}


@end


