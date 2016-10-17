//
//  WQScan.m
//  WQScanQRCode
//
//  Created by admin on 16/8/31.
//  Copyright © 2016年 SUWQ. All rights reserved.
//

#import <CoreImage/CoreImage.h>
#import "WQCode.h"

#define WS(weakSelf) __weak __typeof(&*self) weakSelf = self;
@interface WQCode ()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) CAShapeLayer *scanLayer;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, assign) CGRect croRect;
@end

@implementation WQCode
void * const kSessionStatusContext;
#pragma mark System Method
-(void)dealloc{
    // 移除监听
    [self.session removeObserver:self
                      forKeyPath:@"running"];
}


#pragma mark Public Method
#pragma mark 二维码、条形码扫描
- (instancetype)initScanInView:(UIView *)view
                      scanType:(CodeType)codeType
                      scanRect:(CGRect)cropRect {
    self = [super init];
    if (self) {
        self.croRect = cropRect;
        // 定义捕捉对象
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        // 输入流
        NSError *error;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice
                                                                            error:&error];
#ifdef DEBUG
        NSString *msg = [NSString stringWithFormat:@"建立输入流对象错误: %@",error.localizedDescription];
        NSAssert(!error, msg);
#endif
        
        // 输出流
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        
        // 设置扫描完成代理
        [output setMetadataObjectsDelegate:self
                                     queue:dispatch_get_main_queue()];
        
        // 自定义扫描范围
        CGSize viewSize = view.bounds.size;
        CGFloat p1 = viewSize.height / viewSize.width;
        CGFloat p2 = 1920./1080.;
        if (p1 < p2) {
            CGFloat fixHeight = viewSize.width * 1920./1080.;
            CGFloat fixPadding = (fixHeight - viewSize.height) / 2;
            [output setRectOfInterest:CGRectMake((CGRectGetMinY(cropRect) + fixPadding)/fixHeight,
                                                 CGRectGetMinX(cropRect)/viewSize.width,
                                                 CGRectGetHeight(cropRect)/fixHeight,
                                                 CGRectGetWidth(cropRect)/viewSize.width)];
        }else {
            CGFloat fixWidth = viewSize.height * 1080./1920.;
            CGFloat fixPadding = (fixWidth - viewSize.width)/2;
            [output setRectOfInterest:CGRectMake(CGRectGetMinY(cropRect)/viewSize.height,
                                                 (CGRectGetMinX(cropRect) + fixPadding)/fixWidth,
                                                 CGRectGetHeight(cropRect)/viewSize.height,
                                                 CGRectGetWidth(cropRect)/fixWidth)];
        }
        
        // 建立会话
        self.session = [[AVCaptureSession alloc] init];
        
        // 高质量采集
        [self.session setSessionPreset:AVCaptureSessionPresetHigh];
        
        // 为会话添加输入输出流
        [self.session addInput:input];
        [self.session addOutput:output];
        
        // 扫描码类型数组
        NSArray *types;
        switch (codeType) {
            case WQQRCode:
                // 扫描二维码
                types = @[AVMetadataObjectTypeQRCode];
                break;
            case WQBarCode:
                // 扫描条形码
                types = @[AVMetadataObjectTypeEAN13Code,
                          AVMetadataObjectTypeEAN8Code,
                          AVMetadataObjectTypeCode128Code];
                break;
            default:
                // 两种码都可以扫描
                types = @[AVMetadataObjectTypeQRCode,
                          AVMetadataObjectTypeEAN13Code,
                          AVMetadataObjectTypeEAN8Code,
                          AVMetadataObjectTypeCode128Code];
                break;
        }
        
        // 设置输出类型为 QR码和条形码
        output.metadataObjectTypes = types;
        
        // 建立实时捕捉摄象头对象
        AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        previewLayer.frame = view.bounds;
        
        /********************************************* 扫描框 *********************************************/
        UIView *boxView = [[UIView alloc] initWithFrame:cropRect];
        boxView.layer.masksToBounds = YES;
        boxView.backgroundColor = [UIColor clearColor];
        boxView.layer.shadowColor = [UIColor greenColor].CGColor;
        
        // 角颜色与角线大小、长度
        UIColor *cornerColor = [UIColor greenColor];
        CGFloat cornerLineWidth = 5;
        CGFloat cornerLen = MIN(CGRectGetHeight(cropRect) * 1/6,
                                CGRectGetWidth(cropRect) * 1/6);
        
        // 右下角
        CAShapeLayer *rightDown = [CAShapeLayer layer];
        UIBezierPath *rightDownPath = [UIBezierPath bezierPath];
        [rightDownPath moveToPoint:CGPointMake(CGRectGetWidth(cropRect) - cornerLineWidth/2,
                                               CGRectGetHeight(cropRect) - cornerLen)];
        [rightDownPath addLineToPoint:CGPointMake(CGRectGetWidth(cropRect) - cornerLineWidth/2,
                                                  CGRectGetHeight(cropRect) - cornerLineWidth/2)];
        [rightDownPath addLineToPoint:CGPointMake(CGRectGetWidth(cropRect) - cornerLen,
                                                  CGRectGetHeight(cropRect) - cornerLineWidth/2)];
        rightDown.lineWidth = cornerLineWidth;
        rightDown.strokeColor = cornerColor.CGColor;
        rightDown.fillColor = [UIColor clearColor].CGColor;
        rightDown.path = rightDownPath.CGPath;
        [boxView.layer addSublayer:rightDown];
        
        // 右上角
        CAShapeLayer *rightTop = [CAShapeLayer layer];
        UIBezierPath *rightTopPath = [UIBezierPath bezierPath];
        [rightTopPath moveToPoint:CGPointMake(CGRectGetWidth(cropRect) - cornerLen,
                                              cornerLineWidth/2)];
        [rightTopPath addLineToPoint:CGPointMake(CGRectGetWidth(cropRect) - cornerLineWidth/2,
                                                 cornerLineWidth/2)];
        [rightTopPath addLineToPoint:CGPointMake(CGRectGetWidth(cropRect) - cornerLineWidth/2,
                                                 cornerLen)];
        rightTop.lineWidth = cornerLineWidth;
        rightTop.strokeColor = cornerColor.CGColor;
        rightTop.fillColor = [UIColor clearColor].CGColor;
        rightTop.path = rightTopPath.CGPath;
        [boxView.layer addSublayer:rightTop];
        
        // 左下角
        CAShapeLayer *leftDown = [CAShapeLayer layer];
        UIBezierPath *leftDownPath = [UIBezierPath bezierPath];
        [leftDownPath moveToPoint:CGPointMake(cornerLineWidth/2,
                                              CGRectGetHeight(cropRect) - cornerLen)];
        [leftDownPath addLineToPoint:CGPointMake(cornerLineWidth/2,
                                                 CGRectGetHeight(cropRect) - cornerLineWidth/2)];
        [leftDownPath addLineToPoint:CGPointMake(cornerLen,
                                                 CGRectGetHeight(cropRect) - cornerLineWidth/2)];
        leftDown.lineWidth = cornerLineWidth;
        leftDown.strokeColor = cornerColor.CGColor;
        leftDown.fillColor = [UIColor clearColor].CGColor;
        leftDown.path = leftDownPath.CGPath;
        [boxView.layer addSublayer:leftDown];
        
        // 左上角
        CAShapeLayer *leftTop = [CAShapeLayer layer];
        UIBezierPath *leftTopPath = [UIBezierPath bezierPath];
        [leftTopPath moveToPoint:CGPointMake(cornerLineWidth/2,
                                             cornerLen)];
        [leftTopPath addLineToPoint:CGPointMake(cornerLineWidth/2,
                                                cornerLineWidth/2)];
        [leftTopPath addLineToPoint:CGPointMake(cornerLen , cornerLineWidth/2)];
        leftTop.lineWidth = cornerLineWidth;
        leftTop.strokeColor = cornerColor.CGColor;
        leftTop.fillColor = [UIColor clearColor].CGColor;
        leftTop.path = leftTopPath.CGPath;
        [boxView.layer addSublayer:leftTop];
        
        /********************************************* 挡板 *********************************************/
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:view.bounds];
        [path appendPath:[[UIBezierPath bezierPathWithRect:cropRect] bezierPathByReversingPath]];
        maskLayer.path = path.CGPath;
        maskLayer.fillColor = [UIColor blackColor].CGColor;
        UIView *hug = [[UIView alloc] initWithFrame:view.bounds];
        hug.backgroundColor = [UIColor blackColor];
        hug.alpha = 0.5;
        hug.layer.mask = maskLayer;
        
        /********************************************* 扫描线 *********************************************/
        self.scanLayer = [CAShapeLayer layer];
        UIBezierPath *scanLine = [UIBezierPath bezierPath];
        [scanLine moveToPoint:CGPointMake(0, 0)];
        [scanLine addLineToPoint:CGPointMake(CGRectGetWidth(boxView.frame), 0)];
        [scanLine closePath];
        self.scanLayer.lineWidth = 1.5f;
        self.scanLayer.strokeColor = [UIColor whiteColor].CGColor;
        self.scanLayer.shadowColor = [UIColor greenColor].CGColor;
        self.scanLayer.shadowRadius = 5.f;
        self.scanLayer.shadowOpacity = 1.f;
        self.scanLayer.shadowOffset = CGSizeMake(0, 0);
        self.scanLayer.path = scanLine.CGPath;
        [boxView.layer insertSublayer:self.scanLayer atIndex:0];
        
        /********************************************* 添加视图 *********************************************/
        // 将摄象头捕捉到的图象展示到屏幕上
        [view.layer insertSublayer:previewLayer
                           atIndex:0];
        [view addSubview:hug];
        [view addSubview:boxView];
        
        // 对扫描开启进行监听
        [self.session addObserver:self
                       forKeyPath:@"running"
                          options:NSKeyValueObservingOptionNew
                          context:kSessionStatusContext];
    }
    return self;
}


#pragma mark 二维码、条形码生成
/**
 *  生成二维码、条形码
 */
+ (UIImage *)createCodeWithType:(CodeType)codeType
                         String:(NSString *)str
                           size:(CGSize)size
                          color:(UIColor *)color
                      watermark:(UIImage *)watermark
                       position:(CGRect)rect{
    // 获得 color 的 RGB 值
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel,
                                                 1,
                                                 1,
                                                 8,
                                                 4,
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    CGFloat red = resultingPixel[0];
    CGFloat green = resultingPixel[1];
    CGFloat blue = resultingPixel[2];
    
    // 滤镜
    CIFilter *filter;
    switch (codeType) {
        case WQBarCode:{
            if([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
#ifdef DEBUG
                // 条形码生成只在 iOS 8.0 后支持
                NSAssert([[UIDevice currentDevice].systemVersion floatValue] > 8.0, @"条形码生成只在 iOS 8.0 后支持");
#endif
                return nil;
            }
            
            // 生成条形码
            filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
            [filter setDefaults];
            
            // 生成条形码的上、下、左、右的 margins 值
            [filter setValue:@0.00 forKeyPath:@"inputQuietSpace"];
            break;
        }
            
        default:{
            // 生成二维码
            filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
            [filter setDefaults];
            
            // 纠错等级, "L"、"M"、"Q"、"H",越高越易识别
            [filter setValue:@"Q" forKeyPath:@"inputCorrectionLevel"];
            break;
        }
    }
    
    // 字符串转 NSData
    NSData *strData = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    // 将字符串数据放入滤镜
    [filter setValue:strData forKeyPath:@"inputMessage"];
    
    // 获得滤出图象
    CIImage *outputImg = [filter outputImage];
    
    // 得到重画图
    UIImage *resultImg = [self createNonInterPolateUIImageFormCIImage:outputImg
                                                                 size:size
                                                                  red:red
                                                                green:green
                                                                 blue:blue];
    if (watermark != nil) {
        // 为图片添加水印
        resultImg = [self watermarkWithImage:watermark
                                     toImage:resultImg
                                        rect:rect];
    }
    
    return resultImg;
}

/**
 *  开始扫描
 */
- (void)startReading{
    if (!self.session.running) {
        // 开始捕捉
        [self.session startRunning];
    }
}

/**
 *  停止扫描
 */
- (void)stopReading{
    if (self.session.running) {
        // 停止会话
        [self.session stopRunning];
    }
}


#pragma mark Private Method
/**
 *  图象处理
 */
+ (UIImage *)createNonInterPolateUIImageFormCIImage:(CIImage *)ciImage
                                               size:(CGSize)size
                                                red:(CGFloat)red
                                              green:(CGFloat)green
                                               blue:(CGFloat)blue{
    CGRect extentRect = CGRectIntegral(ciImage.extent);
    CGFloat scaleW = size.width / CGRectGetWidth(extentRect);
    CGFloat scaleH = size.height / CGRectGetHeight(extentRect);
    
    size_t width = CGRectGetWidth(extentRect) * scaleW;
    size_t height = CGRectGetHeight(extentRect) * scaleH;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil,
                                                   width,
                                                   height,
                                                   8,
                                                   0,
                                                   cs,
                                                   kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef bitmapImage = [context createCGImage:ciImage
                                           fromRect:extentRect];
    CGContextSetInterpolationQuality(bitmapRef,
                                     kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scaleW, scaleH);
    CGContextDrawImage(bitmapRef, extentRect, bitmapImage);
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    UIImage *newImage = [UIImage imageWithCGImage:scaledImage];
    return [self imageBlackToTransparent:newImage
                                 withRed:red
                                andGreen:green
                                 andBlue:blue];
}
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void *)data);
}
+ (UIImage *)imageBlackToTransparent:(UIImage *)image
                           withRed:(CGFloat)red
                          andGreen:(CGFloat)green
                           andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t *rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf,
                                                 imageWidth,
                                                 imageHeight,
                                                 8,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    
    int pixelNum = imageWidth * imageHeight;
    uint32_t *pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i ++, pCurPtr ++) {
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900) {
            uint8_t *ptr = (uint8_t *)pCurPtr;
            ptr[3] = red;
            ptr[2] = green;
            ptr[1] = blue;
        }else {
            uint8_t *ptr = (uint8_t *)pCurPtr;
            ptr[0] = 0;
        }
    }
    
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL,
                                                                  rgbImageBuf,
                                                                  bytesPerRow * imageHeight,
                                                                  ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth,
                                        imageHeight,
                                        8,
                                        32,
                                        bytesPerRow,
                                        colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little,
                                        dataProvider,
                                        NULL,
                                        true,
                                        kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage *resultUIImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}
+ (UIImage *)watermarkWithImage:(UIImage *)watermark
                        toImage:(UIImage *)img
                           rect:(CGRect)rect {
    UIGraphicsBeginImageContext(img.size);
    [img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
    //四个参数为水印图片的位置
    [watermark drawInRect:rect];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSString*, id> *)change
                       context:(nullable void *)context {
    if (context == kSessionStatusContext) {
        NSNumber *runStatus = change[@"new"];
        if ([runStatus boolValue]) {
            [self startScanLine];
        }else {
            [self.scanLayer removeAllAnimations];
        }
    }
}

- (void)startScanLine {
    WS(weakSelf);
    // 扫描线
    dispatch_async(dispatch_get_main_queue(), ^{
        // 扫描线动画
        CABasicAnimation *moveScanLayer = [CABasicAnimation animationWithKeyPath:@"position.y"];
        moveScanLayer.fromValue = @(0.0);
        moveScanLayer.toValue = [NSNumber numberWithFloat:CGRectGetHeight(self.croRect)];
        moveScanLayer.repeatCount = MAXFLOAT;
        moveScanLayer.duration = 3.f;
        moveScanLayer.delegate = weakSelf;
        if ([weakSelf.scanLayer animationForKey:@"moveScanLayer"]) {
            return ;
        }
        [weakSelf.scanLayer addAnimation:moveScanLayer
                                  forKey:@"moveScanLayer"];
    });
}


#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection{
    WS(weakSelf);
    // 扫描到数据代理回调
    if ([weakSelf.delegate respondsToSelector:@selector(captureOutput:
                                                    didOutputMetadataObjects:
                                                    fromConnection:)]) {
        [weakSelf.delegate captureOutput:captureOutput
                didOutputMetadataObjects:metadataObjects
                          fromConnection:connection];
    }
}
@end









