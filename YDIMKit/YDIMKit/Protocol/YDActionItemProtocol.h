//
//  YDActionItemProtocol.h
//  Chat
//
//  Created by 周少文 on 2016/10/25.
//  Copyright © 2016年 周少文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol YDActionItemProtocol <NSObject>

@property (nonatomic,strong) UIImage *image;
@property (nonatomic,copy) NSString *titleName;

@end
