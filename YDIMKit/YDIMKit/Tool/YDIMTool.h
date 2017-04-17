//
//  YDIMTool.h
//  YDIMKit
//
//  Created by 周少文 on 2016/12/19.
//  Copyright © 2016年 Yidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class YDIMTool;

@protocol YDIMToolDelegate <NSObject>

@optional

/*!
 *  音量变化回调
 *    在录音过程中，回调音频的音量。
 *
 *  @param volume -[out] 音量，范围从0-1
 */
- (void)imTool:(YDIMTool *)tool onVolumeChanged:(float)volume;
//录音的时间变化回调
- (void)imTool:(YDIMTool *)tool onRecordTimeChanged:(NSTimeInterval)currentTime;

@end

@interface YDIMTool : NSObject

+ (instancetype)sharedTool;
/**
 开始录音,会覆盖之前的录音

 @param isSuccessedBlock isSuccessedBlock 是否成功开启录音的回调
 */
- (void)beginRecording:(void(^)(BOOL isSuccessed))isSuccessedBlock;
/**
 暂停录音

 @return 返回已录音时长
 */
- (NSTimeInterval)pauseRecording;
//继续录音
- (void)continueRecording;
//停止录音
- (void)stopRecordWithCompletion:(void(^)(BOOL isSuccess,NSData *recordData,long long duration,NSURL *fileURL))complete;
//取消录音,录音文件会被从本地删除
- (void)cancelRecording;

//播放音频,如果是暂停状态再调用一次api会自动接着后面继续播放,内部已经处理,外部不用再判断.
- (void)playWithData:(NSData *)data completion:(void(^)())complete;
- (void)playeWithUrl:(NSURL *)url completion:(void(^)())complete;
//暂停播放
- (void)pausePlaying;
//停止播放
- (void)stopPlaying;

@property (nonatomic,weak) id<YDIMToolDelegate> delegate;

@end
