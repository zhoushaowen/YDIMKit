//
//  UIViewController+Authorization.m
//  Chat
//
//  Created by 周少文 on 2016/11/1.
//  Copyright © 2016年 周少文. All rights reserved.
//

#import "UIViewController+Authorization.h"
@import AVFoundation;
@import AssetsLibrary;
@import Speech;

@implementation UIViewController (Authorization)

- (BOOL)isHaveCameraAuthorization
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(status == AVAuthorizationStatusRestricted || status ==AVAuthorizationStatusDenied)
    {
        [self showAlertWithTitle:@"无法启动相机" type:@"相机"];
        return NO;
    }
    
    return YES;
}

- (BOOL)isHavePhotoLibarayAuthorization
{
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if(status == ALAuthorizationStatusRestricted ||status == ALAuthorizationStatusDenied)
    {
        [self showAlertWithTitle:@"无法启动相册" type:@"相册"];
        return NO;
    }
    
    return YES;
}

- (BOOL)isHaveMicrophoneAuthorization {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    //AVAuthorizationStatusRestricted,未授权，且用户无法更新，如家长控制情况下
    //AVAuthorizationStatusDenied,用户已经明确否决
    if(status == AVAuthorizationStatusRestricted ||status == AVAuthorizationStatusDenied)
    {
        [self showAlertWithTitle:@"无法进行录音" type:@"麦克风"];
        return NO;
    }
    
    return YES;
}

- (BOOL)isHaveSpeechRecognizerAuthorization {
    SFSpeechRecognizerAuthorizationStatus status = [SFSpeechRecognizer authorizationStatus];
    if(status == SFSpeechRecognizerAuthorizationStatusDenied | status == SFSpeechRecognizerAuthorizationStatusRestricted){
        [self showAlertWithTitle:@"无法进行语音识别" type:@"语音识别"];
        return NO;
    }
    return YES;
}

- (void)openSettingWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"现在设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:url])
        {
            [[UIApplication sharedApplication] openURL:url];
        }
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showAlertWithTitle:(NSString *)title type:(NSString *)type{
    NSDictionary *dic = [NSBundle mainBundle].infoDictionary;
    NSString *appName = dic[@"CFBundleDisplayName"];
    if(!appName)
    {
        appName = dic[@"CFBundleName"];
    }
    [self openSettingWithTitle:title message:[NSString stringWithFormat:@"请开启%@的%@权限",appName,type]];
}


@end
