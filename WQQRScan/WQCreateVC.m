//
//  WQCreateVC.m
//  WQQRScan
//
//  Created by admin on 16/10/14.
//  Copyright © 2016年 SUWQ. All rights reserved.
//

#import "WQCreateVC.h"
#import "WQCode.h"

@interface WQCreateVC ()
@property (weak, nonatomic) IBOutlet UITextField *texQRCode;
@property (weak, nonatomic) IBOutlet UIImageView *imgVQRCode;
@property (weak, nonatomic) IBOutlet UIImageView *imgBarCode;
- (IBAction)createQRCode:(UIButton *)sender;
@end

@implementation WQCreateVC

- (void)viewDidLoad {
    self.title = @"生成条开码、二维码";
    [super viewDidLoad];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches
          withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (IBAction)createQRCode:(UIButton *)sender {
    // 生成二维码
    UIImage *watermask = [UIImage imageNamed:@"Airplane"];
    UIImage *code = [WQCode createCodeWithType:WQQRCode
                                        String:self.texQRCode.text
                                          size:CGSizeMake(177, 173)
                                         color:[UIColor colorWithRed:139/255.0
                                                               green:87/255.0
                                                                blue:42/255.0
                                                               alpha:1.0]
                                     watermark:watermask
                                      position:CGRectMake((177 - watermask.size.width/2)/2,
                                                          (173 - watermask.size.height/2)/2,
                                                          watermask.size.width/2,
                                                          watermask.size.height/2)];
    [self.imgVQRCode setImage:code];
    
    // 添加阴影
    self.imgVQRCode.layer.shadowColor = [UIColor grayColor].CGColor;
    self.imgVQRCode.layer.shadowOffset = CGSizeMake(3, -3);
    self.imgVQRCode.layer.shadowRadius = 3;
    self.imgVQRCode.layer.shadowOpacity = 1.0;
}

- (IBAction)createBarCode:(UIButton *)sender {
    // 生成条形码
    UIImage *code = [WQCode createCodeWithType:WQBarCode
                                        String:self.texQRCode.text
                                          size:CGSizeMake(230, 70)
                                         color:[UIColor colorWithRed:25/255.0
                                                               green:133/255.0
                                                                blue:250/255.0
                                                               alpha:1.0]
                                     watermark:nil
                                      position:CGRectNull];
    [self.imgBarCode setImage:code];
    
    // 添加阴影
    self.imgBarCode.layer.shadowColor = [UIColor grayColor].CGColor;
    self.imgBarCode.layer.shadowOffset = CGSizeMake(3, -1);
    self.imgBarCode.layer.shadowRadius = 3;
    self.imgBarCode.layer.shadowOpacity = 1.0;
}

@end









