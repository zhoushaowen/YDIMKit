//
//  YDSpeechRecognizeManager.m
//  YDIMKit
//
//  Created by zhoushaowen on 2017/2/24.
//  Copyright © 2017年 Yidu. All rights reserved.
//

#import "YDSpeechRecognizeManager.h"

#import <UIKit/UIDevice.h>
@import Speech;

@interface YDSpeechRecognizeManager ()

@property (nonatomic,strong) SFSpeechRecognizer *recognizer;

@end

@implementation YDSpeechRecognizeManager

static YDSpeechRecognizeManager *manager = nil;

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(!manager){
            manager = [[self alloc] init];
        }
    });
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(!manager){
            manager = [super allocWithZone:zone];
        }
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if(self){
        self.recognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
        self.recognizer.queue = [[NSOperationQueue alloc] init];//指定语音识别的delegate和block回调在分线程
    }
    return self;
}

- (void)recognizeWithURL:(NSURL *)url completed:(void(^)(NSString *result,NSError *error))completedBlock deleteSourceOnSuccess:(BOOL)deleteSourceOnSuccess {
    NSComparisonResult compare = [[UIDevice currentDevice].systemVersion compare:@"10.0"];
    if(compare == NSOrderedAscending){
        NSLog(@"系统版本号低于iOS10.0,无法使用语音识别功能");
        return;
    }
    if(![self.recognizer isAvailable]){
        NSLog(@"语音识别不可用");
        return;
    }
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        if(!url){
            NSLog(@"语音识别的url不能为空");
            return;
        }
        if(status == SFSpeechRecognizerAuthorizationStatusAuthorized){
            NSLog(@"语音识别授权成功");
            SFSpeechURLRecognitionRequest *request = [[SFSpeechURLRecognitionRequest alloc] initWithURL:url];
            [self.recognizer recognitionTaskWithRequest:request resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
                if(!error){
                    NSLog(@"语音识别成功:%@",result.bestTranscription.formattedString);
                    if(completedBlock){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completedBlock(result.bestTranscription.formattedString,nil);
                        });
                    }
                    if(deleteSourceOnSuccess){
                        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
                    }
                }else{
                    NSLog(@"语音识别失败:%@",error.localizedDescription);
                    if(completedBlock){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completedBlock(nil,error);
                        });
                    }
                }
            }];
        }else{
            NSLog(@"语音识别还未授权");
        }
    }];
}













@end
