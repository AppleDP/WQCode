//
//  WQScan.h
//  WQScanQRCode
//
//  Created by admin on 16/8/31.
//  Copyright © 2016年 SUWQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

/*!
 *  @typedef CodeType
 *  @discussion 生成图片类型,和扫描类型
 */
typedef enum{
    WQBarCode,     // 条形码
    WQQRCode,      // 二维码
    WQAllCode      // 条形码和二维码(只在扫描时可用)
}CodeType;


/*!
 *  @protocol WQCodeDelegate
 *  @discussion WQScan 代理
 */
@protocol WQCodeDelegate <NSObject>
@optional
/*!
 *  发现数据代理回调
 *
 *  @param captureOutput   captureOutput
 *  @param metadataObjects metadataObjects
 *  @param connection      connection
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection;
@end


/*!
 *  @class WQCode
 *  @discssion 二维码、条形码扫描
 */
@interface WQCode : NSObject
/*! 扫描代理 WQCodeDelegate */
@property (nonatomic, weak) id<WQCodeDelegate> delegate;

/*!
 *  将字符串生成二维码、条形码
 *
 *  @param codeType  生成类型
 *  @param str       二维码、条形码内容
 *  @param size      二维码、条形码大小
 *  @param color     二维码、条形码颜色
 *  @param watermark 二维码、条形码水印图
 *  @param rect      水印图在二维码、条形码中的位置（在 watermark ！= nil 时可有效）
 *
 *  @return 二维码、条形码图片
 */
+ (UIImage *)createCodeWithType:(CodeType)codeType
                         String:(NSString *)str
                           size:(CGSize)size
                          color:(UIColor *)color
                      watermark:(UIImage *)watermark
                       position:(CGRect)rect;

/*!
 *  在 view 中添加扫描视图
 *
 *  @param view     扫描视图的父 view
 *  @param cropRect 扫描范围
 *
 *  @return WQScan  对象
 */
- (instancetype)initScanInView:(UIView *)view
                      scanType:(CodeType)codeType
                      scanRect:(CGRect)cropRect;

/*!
 *  开始扫描
 *
 *  @param captureOutput 扫描到数据回调
 */
- (void)startReading;

/*!
 *  停止扫描
 */
- (void)stopReading;
@end









