//
//  XHRDownloadManager.h
//  大文件断点下载
//
//  Created by 胥鸿儒 on 16/8/11.
//  Copyright © 2016年 xuhongru. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XHRDownloadManager : NSObject

+ (instancetype)sharedManager;

- (void)downloadFromURL:(NSString *)urlString progress:(void(^)(CGFloat downloadProgress))downloadProgressBlock complement:(void(^)(NSString *filePath,NSError *error))completeBlock;
/**
 *  暂停某个url的下载任务
 */
- (void)suspendTaskWithURL:(NSString *)urlString;
/**
 *  暂停某个url的下载任务
 */
- (void)suspendAllTasks;
/**
 *  继续某个url的下载任务
 */
- (void)resumeTaskWithURL:(NSString *)urlString;
/**
 *  继续所有下载任务
 */
- (void)resumeAllTasks;
/**
 *  取消某个url的下载任务,取消以后必须重新设置任务
 */
- (void)cancelTaskWithURL:(NSString *)urlString;
/**
 *  取消所有下载任务,取消以后必须重新设置任务
 */
- (void)cancelAllTasks;
@end
