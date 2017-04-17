//
//  YDSpeechSynthesisManager.h
//  YDIMKit
//
//  Created by zhoushaowen on 2017/2/24.
//  Copyright © 2017年 Yidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YDSpeechSynthesisManager : NSObject

+ (instancetype)sharedManager;

/**
 开始合成
 
 @param text 需要合成的文本
 @param completedBlock 合成成功的回调
 */
- (void)speakWithText:(NSString *)text completed:(void(^)())completedBlock;

/**
 停止说话
 */
- (void)stopSpeak;

@end
