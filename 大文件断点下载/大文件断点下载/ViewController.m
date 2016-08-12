//
//  ViewController.m
//  大文件断点下载
//
//  Created by 胥鸿儒 on 16/6/7.
//  Copyright © 2016年 xuhongru. All rights reserved.
//

#import "ViewController.h"
#import "XHRDownloadManager.h"
#import <objc/runtime.h>
@interface ViewController ()
/**downloadManager*/
@property(nonatomic,strong)XHRDownloadManager *downloadManager;
@end

@implementation ViewController
- (XHRDownloadManager *)downloadManager
{
    if (!_downloadManager) {
        _downloadManager = [XHRDownloadManager sharedManager];
    }
    return _downloadManager;
}

- (IBAction)start1:(id)sender {
    [[XHRDownloadManager sharedManager] downloadFromURL:@"http://dldir1.qq.com/qqfile/qq/QQ8.3/18038/QQ8.3.exe" progress:^(CGFloat downloadProgress) {
        NSLog(@"task1-------- %.2f%%",downloadProgress * 100);
    } complement:^(NSString *filePath, NSError *error) {
        NSLog(@"task1-----%@,%@",filePath,error);
    }];
    
}

- (IBAction)start2:(id)sender {
        [self.downloadManager downloadFromURL:@"http://dldir1.qq.com/qqfile/qq/tm/2013Preview2/10913/TM2013Preview2.exe" progress:^(CGFloat downloadProgress) {
            NSLog(@"task2=========%@%.2f%%",[NSThread currentThread],downloadProgress * 100);
        } complement:^(NSString *filePath, NSError *error) {
            NSLog(@"task2=========%@,%@",filePath,error);
        }];
}
- (IBAction)suspend1:(id)sender {
    [self.downloadManager suspendTaskWithURL:@"http://dldir1.qq.com/qqfile/qq/QQ8.3/18038/QQ8.3.exe"];
}
- (IBAction)suspendAll:(id)sender {
    [self.downloadManager suspendAllTasks];
}
- (IBAction)resume1:(id)sender {
    [self.downloadManager resumeTaskWithURL:@"http://dldir1.qq.com/qqfile/qq/QQ8.3/18038/QQ8.3.exe"];
}
- (IBAction)resumeAll:(id)sender {
    [self.downloadManager resumeAllTasks];
}
- (IBAction)cancel1:(id)sender {
    [self.downloadManager cancelTaskWithURL:@"http://dldir1.qq.com/qqfile/qq/QQ8.3/18038/QQ8.3.exe"];
}
- (IBAction)cancelAll:(id)sender {
    [self.downloadManager cancelAllTasks];
}

@end
