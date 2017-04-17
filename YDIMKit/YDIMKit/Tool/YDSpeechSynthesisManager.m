//
//  YDSpeechSynthesisManager.m
//  YDIMKit
//
//  Created by zhoushaowen on 2017/2/24.
//  Copyright © 2017年 Yidu. All rights reserved.
//

#import "YDSpeechSynthesisManager.h"
@import AVFoundation;

@interface YDSpeechSynthesisManager ()<AVSpeechSynthesizerDelegate>
{
    void(^_completedBlock)();
}
@property (nonatomic,strong) AVSpeechSynthesizer *synthesizer;
@property (nonatomic,strong) AVSpeechSynthesisVoice *voice;

@end

@implementation YDSpeechSynthesisManager

static YDSpeechSynthesisManager *manager = nil;

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
        self.synthesizer = [[AVSpeechSynthesizer alloc] init];
        self.synthesizer.delegate = self;
        self.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    }
    return self;
}

- (void)speakWithText:(NSString *)text completed:(void(^)())completedBlock {
    if(text.length < 1) {
        NSLog(@"合成语音的文本为空");
        return;
    }
    _completedBlock = completedBlock;
    [self stopSpeak];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:0 error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    //创建话语对象
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    utterance.voice = self.voice;
    [self.synthesizer speakUtterance:utterance];
}

- (void)stopSpeak {
    if(self.synthesizer.isSpeaking){
        [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
}

#pragma mark - AVSpeechSynthesizerDelegate
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance
{
    NSLog(@"开始合成");
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    NSLog(@"语音合成完成");
    if(_completedBlock){
        _completedBlock();
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance
{
    NSLog(@"语音合成被取消");
}



@end
