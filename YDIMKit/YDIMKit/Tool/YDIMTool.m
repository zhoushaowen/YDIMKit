//
//  YDIMTool.m
//  YDIMKit
//
//  Created by 周少文 on 2016/12/19.
//  Copyright © 2016年 Yidu. All rights reserved.
//

#import "YDIMTool.h"
#import <UIKit/UIKit.h>

static YDIMTool *tool = nil;

@interface YDIMTool ()<AVAudioRecorderDelegate,AVAudioPlayerDelegate>
{
    void(^_stopRecordBlock)(BOOL isSuccess,NSData *recordData,long long duration,NSURL *fileURL);
    void(^_playComplete)();
    BOOL _isPause;
    BOOL _isComplete;
    CADisplayLink *_levelDisplayLink;
}

@property (nonatomic,strong) AVAudioRecorder *audioRecorder;
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;

@end

@implementation YDIMTool

+ (instancetype)sharedTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[self alloc] init];
    });
    return tool;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [super allocWithZone:zone];
    });
    return tool;
}

- (instancetype)init {
    self = [super init];
    if(self){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleProximityStateChangeNotification:) name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    return self;
}

- (void)beginRecording:(void(^)(BOOL isSuccessed))isSuccessedBlock {
    //先请求权限,解决第一次无法系统请求alert的bug
    //注意:这个函数的block一定要实现,否则调用的时候会崩溃
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if(granted){
            NSLog(@"麦克风授权成功");
            [self stopPlaying];
            [self cancelRecording];
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"YDAudioRecords"];
            NSFileManager *manager = [NSFileManager defaultManager];
            if(![manager fileExistsAtPath:path]){
                [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
            }
            NSDate *date = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [[formatter stringFromDate:date] stringByAppendingPathExtension:@"wav"];
            NSString *filePath = [path stringByAppendingPathComponent:str];
            NSDictionary *settings = @{AVFormatIDKey: @(kAudioFormatLinearPCM),
                                       AVSampleRateKey: @8000.00f,
                                       AVNumberOfChannelsKey: @1,
                                       AVLinearPCMBitDepthKey: @16,
                                       AVLinearPCMIsNonInterleaved: @NO,
                                       AVLinearPCMIsFloatKey: @NO,
                                       AVLinearPCMIsBigEndianKey: @NO,
                                       AVEncoderAudioQualityKey:@(AVAudioQualityHigh)
                                       };
            NSError *error = nil;
            _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:filePath] settings:settings error:&error];
            _audioRecorder.delegate = self;
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord withOptions:0 error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            _audioRecorder.meteringEnabled = YES;
            [_audioRecorder prepareToRecord];
            [_audioRecorder record];
            _levelDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(levelDisplayLinkCallback:)];
            [_levelDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
            if(error){
                NSLog(@"开始录音失败:%@",error);
                if(isSuccessedBlock){
                    isSuccessedBlock(NO);
                }
            }else{
                NSLog(@"开始录音成功");
                if(isSuccessedBlock){
                    isSuccessedBlock(YES);
                }
            }
        }else{
            NSLog(@"麦克风授权失败");
            if(isSuccessedBlock){
                isSuccessedBlock(NO);
            }
        }
    }];
}

- (NSTimeInterval)pauseRecording {
#ifdef DEBUG
    if(_audioRecorder){
        NSLog(@"暂停录音");
    }
#endif
    [_audioRecorder pause];
    _levelDisplayLink.paused = YES;
    return _audioRecorder.currentTime;
}

- (void)continueRecording {
#ifdef DEBUG
    if(_audioRecorder){
        NSLog(@"继续录音");
    }
#endif
    [_audioRecorder record];
    _levelDisplayLink.paused = NO;
}

- (void)cancelRecording {
    [self stopRecordWithCompletion:nil];
    if([[NSFileManager defaultManager] fileExistsAtPath:_audioRecorder.url.absoluteString]){
        [[NSFileManager defaultManager] removeItemAtURL:_audioRecorder.url error:nil];
    }
    _audioRecorder = nil;
}

- (void)stopRecordWithCompletion:(void(^)(BOOL isSuccess,NSData *recordData,long long duration,NSURL *fileURL))complete {
    _stopRecordBlock = complete;
    [_audioRecorder stop];
    [_levelDisplayLink invalidate];
    _levelDisplayLink = nil;
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
#ifdef DEBUG
    NSLog(@"完成录音");
#endif
    if(_stopRecordBlock && flag){
        NSData *recordData = [[NSData alloc] initWithContentsOfURL:recorder.url];
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:recorder.url options:nil];
        double duration = CMTimeGetSeconds(asset.duration);
        long long dura = [NSString stringWithFormat:@"%f",duration].longLongValue;
        _stopRecordBlock(flag,recordData,dura,recorder.url);
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"音频编码失败:%@",error.localizedDescription);
}

- (void)playWithData:(NSData *)data completion:(void(^)())complete {
    if(!_isPause){
        [self stopPlaying];
        _playComplete = complete;
        NSError *error = nil;
        _audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
        [self setupPlayer];
#ifdef DEBUG
        NSLog(@"开始播放音频");
        if(error){
            NSLog(@"%@",error);
        }
#endif
    }else{
        [self play];
    }
}

- (void)playeWithUrl:(NSURL *)url completion:(void(^)())complete {
    if(!_isPause){
        [self stopPlaying];
        _playComplete = complete;
        NSError *error = nil;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [self setupPlayer];
#ifdef DEBUG
        NSLog(@"开始播放音频");
        if(error){
            NSLog(@"%@",error);
        }
#endif
    }else{
        [self play];
    }
}

- (void)play {
    _isComplete = NO;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if([UIDevice currentDevice].proximityState){//接近传感器了
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }else{
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    //为了提高用户体验,延迟0.5秒再播放
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_audioPlayer play];
    });
}

- (void)pausePlaying {
    [_audioPlayer pause];
    _isPause = YES;
#ifdef DEBUG
    if(_audioPlayer){
        NSLog(@"暂停播放");
    }
#endif
}

- (void)stopPlaying {
    [_audioPlayer stop];
    _audioPlayer = nil;
    _isPause = NO;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
#ifdef DEBUG
    if(_audioPlayer){
        NSLog(@"停止播放");
    }
#endif
}

- (void)setupPlayer {
    if([[UIDevice currentDevice].systemVersion floatValue] >= 8.0f){
        [self removeAudioPlayerNotification];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    }
    _audioPlayer.delegate = self;
    [_audioPlayer prepareToPlay];
    [self play];
}

#pragma mark - Notification
- (void)handleInterruption:(NSNotification *)notification {
    AVAudioSessionSilenceSecondaryAudioHintType type = [[notification.userInfo objectForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    if(type == AVAudioSessionSilenceSecondaryAudioHintTypeBegin){//被打断
        [_audioPlayer pause];
    }else if(type == AVAudioSessionSilenceSecondaryAudioHintTypeEnd){//恢复
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self play];
        });
    }
}

//注意:如果proximityMonitoringEnabled的值一旦设置NO,那么就不会收到接近或远离传感器的通知
- (void)handleProximityStateChangeNotification:(NSNotification *)notification {
    if([UIDevice currentDevice].proximityState){
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }else{
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    if(_isComplete){
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
}

- (void)removeAudioPlayerNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
}


#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self removeAudioPlayerNotification];
    _isPause = NO;
    if(_playComplete){
        _playComplete();
    }
    _isComplete = YES;
    //如果没有靠近传感器,播放结束之后就关闭传感器
    if(![UIDevice currentDevice].proximityState){
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [self removeAudioPlayerNotification];
    if(_playComplete){
        _playComplete();
    }
    _isComplete = YES;
    if(![UIDevice currentDevice].proximityState){
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
}

- (void)levelDisplayLinkCallback:(CADisplayLink *)displayLink {
    [_audioRecorder updateMeters];
    float   level = 0;                // The linear 0.0 .. 1.0 value we need.
    float   minDecibels = -80.0f; // Or use -60dB, which I measured in a silent room.
    float   decibels    = [_audioRecorder averagePowerForChannel:0];
    
    if (decibels < minDecibels)
    {
        level = 0.0f;
    }
    else if (decibels >= 0.0f)
    {
        level = 1.0f;
    }
    else
    {
        float   root            = 2.0f;
        float   minAmp          = powf(10.0f, 0.05f * minDecibels);
        float   inverseAmpRange = 1.0f / (1.0f - minAmp);
        float   amp             = powf(10.0f, 0.05f * decibels);
        float   adjAmp          = (amp - minAmp) * inverseAmpRange;
        
        level = powf(adjAmp, 1.0f / root);
    }
    
    /* level 范围[0 ~ 1] */
#ifdef DEBUG
    NSLog(@"level:%f-----currentTime:%f",level,_audioRecorder.currentTime);
#endif
    if(_delegate && [_delegate respondsToSelector:@selector(imTool:onVolumeChanged:)]){
        [_delegate imTool:tool onVolumeChanged:level];
    }
    if(_delegate && [_delegate respondsToSelector:@selector(imTool:onRecordTimeChanged:)]){
        [_delegate imTool:self onRecordTimeChanged:_audioRecorder.currentTime];
    }

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




@end
