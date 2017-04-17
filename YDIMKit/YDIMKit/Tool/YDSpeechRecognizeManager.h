//
//  YDSpeechRecognizeManager.h
//  YDIMKit
//
//  Created by zhoushaowen on 2017/2/24.
//  Copyright © 2017年 Yidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YDSpeechRecognizeManager : NSObject

+ (instancetype)sharedManager;

/**
 语音识别
 
 @param url 音频资源的url
 @param completedBlock 识别完成的回调
 @param deleteSourceOnSuccess 识别成功之后是否删除音频资源文件,默认是NO
 */
- (void)recognizeWithURL:(NSURL *)url completed:(void(^)(NSString *result,NSError *error))completedBlock deleteSourceOnSuccess:(BOOL)deleteSourceOnSuccess;

@end
