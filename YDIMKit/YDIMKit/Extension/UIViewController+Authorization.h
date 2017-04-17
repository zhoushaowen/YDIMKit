//
//  UIViewController+Authorization.h
//  Chat
//
//  Created by 周少文 on 2016/11/1.
//  Copyright © 2016年 周少文. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Authorization)

- (BOOL)isHaveCameraAuthorization;
- (BOOL)isHavePhotoLibarayAuthorization;
- (BOOL)isHaveMicrophoneAuthorization;
- (BOOL)isHaveSpeechRecognizerAuthorization;

@end
