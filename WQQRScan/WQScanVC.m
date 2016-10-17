//
//  WQScanVC.m
//  WQQRScan
//
//  Created by admin on 16/10/14.
//  Copyright © 2016年 SUWQ. All rights reserved.
//

#import "WQScanVC.h"
#import "WQCode.h"

@interface WQScanVC ()<WQCodeDelegate>
@property (nonatomic, strong) WQCode *scan;
@end

@implementation WQScanVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫描条形码、二维码";
    CGRect scanRect = CGRectMake(CGRectGetMidX(self.view.frame) - CGRectGetWidth(self.view.frame) * 0.3,
                                 CGRectGetMidY(self.view.frame) - CGRectGetWidth(self.view.frame) * 0.3,
                                 CGRectGetWidth(self.view.frame) * 0.6,
                                 CGRectGetWidth(self.view.frame) * 0.6);
    self.scan = [[WQCode alloc] initScanInView:self.view
                                      scanType:WQAllCode
                                      scanRect:scanRect];
    [self.scan startReading];
    self.scan.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scan stopReading];
}


#pragma mrak WQScanDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count > 0) {
        // 停止扫描
        [self.scan stopReading];
        
        // 调整用系统声音
        SystemSoundID alertSound = kSystemSoundID_Vibrate;
        NSURL *url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/jbl_confirm.caf"];
        if (url) {
            OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url), &alertSound);
            
            if (error != kAudioServicesNoError) {
            }
        }
        AudioServicesPlaySystemSound(alertSound);
        AVMetadataMachineReadableCodeObject *metadataObj = metadataObjects[0];
        [self showAlertWithMessage:[metadataObj stringValue]];
    }
}

- (void)showAlertWithMessage:(NSString *)msg {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"扫描内容"
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           [self.scan startReading];
                                                       });
                                                   }];
    [alert addAction:cancel];
    [self.navigationController presentViewController:alert
                                            animated:YES
                                          completion:nil];
}

@end










