//
//  UIImage+Bundle.m
//  Chat
//
//  Created by 周少文 on 2016/10/24.
//  Copyright © 2016年 周少文. All rights reserved.
//

#import "UIImage+Bundle.h"

@implementation UIImage (Bundle)

+ (UIImage *)imageWithBundleName:(NSString *)bundleName imageName:(NSString *)imageName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    UIImage *image = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:imageName]];
    return image;
}

@end
