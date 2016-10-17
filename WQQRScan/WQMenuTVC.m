//
//  WQMenuTVC.m
//  WQQRScan
//
//  Created by admin on 16/10/14.
//  Copyright © 2016年 SUWQ. All rights reserved.
//

#import "WQMenuTVC.h"
#import "WQScanVC.h"
#import "WQCreateVC.h"

@interface WQMenuTVC ()

@end

@implementation WQMenuTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WQCode 扫码工具";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"生成条码或二维码";
    }else {
        cell.textLabel.text = @"扫描条码或二维码";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"ToCreated"
                                  sender:nil];
    }else {
        [self performSegueWithIdentifier:@"ToScan"
                                  sender:nil];
    }
}
@end
