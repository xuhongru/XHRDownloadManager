//
//  XHRDownloadManager.m
//  大文件断点下载
//
//  Created by 胥鸿儒 on 16/8/11.
//  Copyright © 2016年 xuhongru. All rights reserved.
//

#import "XHRDownloadManager.h"
#import "XHRDownloadSessionManager.h"
#import "NSString+Hash.h"

@interface XHRDownloadManager()

/**存放任务session以及其对应的URL的字典*/
@property(nonatomic,strong)NSMutableDictionary *sessionDictionary;

@end

@implementation XHRDownloadManager

- (void)downloadFromURL:(NSString *)urlString progress:(void(^)(CGFloat downloadProgress))downloadProgressBlock complement:(void(^)(NSString *filePath,NSError *error))completeBlock
{
    if (![self.sessionDictionary.allKeys containsObject:urlString.md5String]) {
        XHRDownloadSessionManager *downloadSessionManager = [[XHRDownloadSessionManager alloc]init];
        self.sessionDictionary[urlString.md5String] = downloadSessionManager;
        [downloadSessionManager downloadFromURL:urlString progress:^(CGFloat downloadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                !downloadProgressBlock?:downloadProgressBlock(downloadProgress);
            });
        }complement:^(NSString *filePath, NSError *error) {
            if (!error) {
                [self.sessionDictionary removeObjectForKey:urlString.md5String];
                dispatch_async(dispatch_get_main_queue(), ^{
                    !completeBlock?:completeBlock(filePath,nil);
                });
            }
        }];
        [downloadSessionManager start];
    }
}

- (void)resumeTaskWithURL:(NSString *)urlString
{
    XHRDownloadSessionManager *downloadSessionManager = self.sessionDictionary[urlString.md5String];
    if (!downloadSessionManager) {
        [NSException raise:@"There are no this task" format:@"Can not find the given url task"];
        return;
    }
    [downloadSessionManager resume];
}
- (void)resumeAllTasks
{
    [self.sessionDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, XHRDownloadSessionManager  *_Nonnull obj, BOOL * _Nonnull stop) {
        [obj resume];
    }];
}
- (void)suspendTaskWithURL:(NSString *)urlString
{
    XHRDownloadSessionManager *downloadSessionManager = self.sessionDictionary[urlString.md5String];
    [downloadSessionManager suspend];
}
- (void)suspendAllTasks
{
    [self.sessionDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, XHRDownloadSessionManager  *_Nonnull obj, BOOL * _Nonnull stop) {
        [obj suspend];
    }];
}
- (void)cancelTaskWithURL:(NSString *)urlString
{
    XHRDownloadSessionManager *downloadSessionManager = self.sessionDictionary[urlString.md5String];
    [downloadSessionManager cancel];
}
- (void)cancelAllTasks
{
   [self.sessionDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, XHRDownloadSessionManager  *_Nonnull obj, BOOL * _Nonnull stop) {
       [obj cancel];
   }];
}
- (NSMutableDictionary *)sessionDictionary
{
    if (!_sessionDictionary) {
        _sessionDictionary = [NSMutableDictionary dictionary];
    }
    return _sessionDictionary;
}
//单例的实现
static XHRDownloadManager *instance;
+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}
- (id)copyWithZone:(NSZone *)zone
{
    return instance;
}

@end
