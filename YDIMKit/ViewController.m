//
//  ViewController.m
//  YDIMKit
//
//  Created by 周少文 on 2016/11/1.
//  Copyright © 2016年 Yidu. All rights reserved.
//

#import "ViewController.h"
#import "YDTextMessageCell.h"
#import "YDBaseMessage.h"
#import "YDJoyImageMessageCell.h"
#import "YDImageMessage.h"
#import "ORColorUtil.h"
#import "YDIMTool.h"
#import <SWExtension.h>
#import "YDChatBottomToolView.h"


@interface ViewController ()<YDJoyImageMessageCellDelegate,YDTextMessageCellDelegate,YDIMToolDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerMessageClass:[YDBaseMessage class] forCellClass:[YDTextMessageCell class]];
    [self registerMessageClass:[YDImageMessage class] forCellClass:[YDJoyImageMessageCell class]];
    
    self.chatTableViewBackgroundColor = ORColor(@"f1f1f1");
    
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
    for(int i = 0;i<20;i++)
    {
        YDBaseMessage *message = [YDBaseMessage new];
        message.messageContent = @"啊哈哈 哈 哈哈哈哈哈哈哈 哈哈哈哈哈哈";
        message.nickname = @"张三";
        [arr addObject:message];
    }
    [self setInitializedDataArray:arr];
    self.numberOfPageCount = 16;
    self.chatStyle = YDChatStylePrivate;
    [YDIMTool sharedTool].delegate = self;
}

#pragma mark - Override
- (void)chatControllerBeginSendText:(NSString *)text
{
    YDBaseMessage *message = [YDBaseMessage new];
    message.messageContent = text;
    message.nickname = @"李四";
    message.messageDirection = YDMessageDirectionSend;
    message.displayTime = NO;
    [self chatControllerAddMessages:@[message]];
}

- (void)chatControllerDidFinishPickingImage:(UIImage *)image
{
    YDImageMessage *imageMessage = [YDImageMessage new];
    imageMessage.timeStr = @"10:12";
    imageMessage.nickname = @"李四";
    imageMessage.contentImage  = image;
    imageMessage.messageDirection = YDMessageDirectionSend;
    imageMessage.displayTime = NO;
    [self chatControllerAddMessages:@[imageMessage]];
}

- (void)chatControllerBeginPullToRefreshCompletionHandler:(void(^)(NSArray<id<YDMessageProtocol>> *newMessages))completionHandler
{
    NSMutableArray *mutableArr = [NSMutableArray arrayWithCapacity:0];
    for(int i = 0;i < 16;i ++)
    {
        YDBaseMessage *message = [YDBaseMessage new];
        static NSInteger count = 0;
        count ++;
        message.messageContent = [NSString stringWithFormat:@"测试下拉%ld",count];
        message.nickname = @"李四";
        [mutableArr addObject:message];
    }
    completionHandler(mutableArr);
}

- (void)chatControllerStartRecording
{
    [[YDIMTool sharedTool] beginRecording:nil];
    [self.view showHUDWithCustomView:self.recordingView];
}

- (void)chatControllerSuspendRecording
{
    NSTimeInterval duration = [[YDIMTool sharedTool] pauseRecording];
    NSInteger min = duration/60;
    NSInteger time = floor(duration);
    int second =  time%60;
    self.cancelSendView.durationLabel.text = [NSString stringWithFormat:@"%.2ld:%.2d",min,second];
    [self.view showHUDWithCustomView:self.cancelSendView];
}

- (void)chatControllerContinueRecording
{
    [[YDIMTool sharedTool] continueRecording];
    [self.view showHUDWithCustomView:self.recordingView];
}

- (void)chatControllerCompleteRecording
{
    [[YDIMTool sharedTool] stopRecordWithCompletion:^(BOOL isSuccess, NSData *recordData, long long duration, NSURL *fileURL) {
        
    }];
    [self.view hideHUDAnimated:YES];
}

- (void)chatControllerShortPressRecordingBtn
{
    [[YDIMTool sharedTool] stopRecordWithCompletion:nil];
    [self.view showHUDWithCustomView:self.audioPressShortView hideWithDelay:0.8f];
}

- (void)chatControllerCancelRecording {
    [[YDIMTool sharedTool] cancelRecording];
    [self.view hideHUDAnimated:YES];
}

- (void)ydConversationCell:(UITableViewCell *)cell forMessageModel:(id<YDMessageProtocol>)model atIndex:(NSInteger)index
{
    if ([cell isKindOfClass:[YDJoyImageMessageCell class]]) {
        YDJoyImageMessageCell *joyImageMessageCell = (YDJoyImageMessageCell *)cell;
        joyImageMessageCell.delegate = self;
    } else  if([cell isKindOfClass:[YDTextMessageCell class]]) {
        YDTextMessageCell *textMessageCell = (YDTextMessageCell *)cell;
        textMessageCell.delegate = self;
    }
}

#pragma mark - YDTextMessageCellDelegate
- (void)textMessageCell:(YDTextMessageCell *)aCell headTapGesture:(id)sender
{
    
}

- (void)textMessageCell:(YDTextMessageCell *)aCell onDeleteMenuAction:(id)sender
{
    
}

#pragma mark - YDJoyImageMessageCellDelegate
- (void)joyImageMessageCell:(YDJoyImageMessageCell *)aCell headTapGesture:(id)sender
{
    NSLog(@"head");
}

- (void)joyImageMessageCell:(YDJoyImageMessageCell *)aCell onDeleteMenuAction:(id)sender
{
    NSLog(@"delete");
}

#pragma mark - YDIMToolDelegate
- (void)imTool:(YDIMTool *)tool onVolumeChanged:(float)volume
{
    NSInteger index = 0;
    if(volume > 0.9){
        index = self.recordingView.imageArr.count - 1;
    }else{
        index = [NSString stringWithFormat:@"%.1f",volume*(self.recordingView.imageArr.count - 1)].integerValue;
    }
    self.recordingView.animationImgV.image = self.recordingView.imageArr[index];
}

- (void)imTool:(YDIMTool *)tool onRecordTimeChanged:(NSTimeInterval)currentTime
{
    NSInteger min = currentTime/60;
    NSInteger time = floor(currentTime);
    int second =  time%60;
    self.recordingView.durationLabel.text = [NSString stringWithFormat:@"%.2ld:%.2d",min,second];
}


@end
