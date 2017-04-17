//
//  YDEmojiKeyboardCell.m
//  Chat
//
//  Created by 周少文 on 2016/10/24.
//  Copyright © 2016年 周少文. All rights reserved.
//

#import "YDEmojiKeyboardCell.h"
#import <SWExtension/UIColor+Hex.h>

@implementation YDEmojiKeyboardCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = [UIColor colorWithHexString:@"F9F9F9"];
        CGFloat btnWidth = [UIScreen mainScreen].bounds.size.width/8.0f;
        CGFloat btnHeight = btnWidth;
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
        for(int i =0;i<24;i++)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(btnWidth*(i%8), btnHeight*(i/8), btnWidth, btnHeight);
            [array addObject:btn];
            btn.titleLabel.font = [UIFont systemFontOfSize:25];
            [self.contentView addSubview:btn];
        }
        
        self.btnArray = array;
    }
    
    return self;
}


@end
