//
//  XHRDownloadManager.h
//  大文件断点下载
//
//  Created by 胥鸿儒 on 16/6/8.
//  Copyright © 2016年 xuhongru. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface XHRDownloadSessionManager : NSObject
/**开启下载任务*/
- (void)start;
/**
 *  继续任务
 */
- (void)resume;
/**
 *  停止下载任务
 */
- (void)suspend;
/**
 *  取消任务
 */
- (void)cancel;
/**下载方法*/
- (void)downloadFromURL:(NSString *)urlString progress:(void(^)(CGFloat downloadProgress))downloadProgressBlock complement:(void(^)(NSString *filePath,NSError *error))completeBlock;

@end
