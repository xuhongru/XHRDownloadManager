//
//  XHRDownloadManager.m
//  大文件断点下载
//
//  Created by 胥鸿儒 on 16/6/8.
//  Copyright © 2016年 xuhongru. All rights reserved.
//
/**文件存放路径*/
#define XHRFilePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:self.fileName]
/**文件总长度字典存放的路径*/
#define XHRTotalDataLengthDictionaryPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"totalDataLengththDictionaryPath.data"]
/**已经下载的文件长度*/
#define XHRAlreadyDownloadLength [[[NSFileManager defaultManager]attributesOfItemAtPath:XHRFilePath error:nil][NSFileSize] integerValue]

#import "XHRDownloadSessionManager.h"
#import "NSString+Hash.h"
@interface XHRDownloadSessionManager()<NSURLSessionDataDelegate>
/**
 *  根据文件名来存储文件的总大小
 */
@property(nonatomic,strong)NSMutableDictionary *totalDataLengthDictionary;
/**
 *  下载进度
 */
@property(nonatomic,assign)CGFloat downloadProgress;
/**
 *  下载的URL地址
 */
@property(nonatomic,copy)NSString *urlString;
/**
 *  存储的文件名
 */
@property(nonatomic,copy)NSString *fileName;
/**
 *  任务
 */
@property(nonatomic,strong)NSURLSessionDataTask *dataTask;
/**
 *  会话
 */
@property(nonatomic,strong)NSURLSession *session;
/**
 *  下载流
 */
@property(nonatomic,strong)NSOutputStream *stream;
/**
 *  错误信息
 */
@property(nonatomic,strong)NSError *downloadError;
/**下载过程中调用的block*/
@property(nonatomic,copy)void (^downloadProgressBlock)(CGFloat progress);
;
/**记录是否处于暂停状态*/
@property(nonatomic,assign)BOOL isSuspend;
/**记录是否处于下载状态*/
@property(nonatomic,assign)BOOL isDownloading;
/**下载完成后调用的block*/
@property(nonatomic,copy)void (^completeBlock)(NSString *, NSError *);
@end

@implementation XHRDownloadSessionManager


- (NSOutputStream *)stream
{
    if (!_stream) {
        
        _stream = [[NSOutputStream alloc]initToFileAtPath:XHRFilePath append:YES];
    }
    return _stream;
}
- (NSURLSessionDataTask *)dataTask
{
    if (!_dataTask) {
        NSError *error = nil;
        NSInteger alreadyDownloadLength = XHRAlreadyDownloadLength;
        //说明已经下载完毕
        if ([self.totalDataLengthDictionary[self.fileName]integerValue] && [self.totalDataLengthDictionary[self.fileName] integerValue] == XHRAlreadyDownloadLength)
        {
            !self.completeBlock?:self.completeBlock(XHRFilePath,nil);
            return nil;
        }
        //如果已经存在的文件比目标大说明下载文件错误执行删除文件重新下载
        else if ([self.totalDataLengthDictionary[self.fileName] integerValue] < XHRAlreadyDownloadLength)
        {
            [[NSFileManager defaultManager]removeItemAtPath:XHRFilePath error:&error];
            if (!error) {
                alreadyDownloadLength = 0;
            }
            else
            {
                NSLog(@"创建任务失败请重新开始");
                return nil;
            }
        }
        //这里是已经下载的小于总文件大小执行继续下载操作
            //创建mutableRequest对象
            NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
            
            //设置request的请求头
            //Range:bytes=xxx-xxx
            [mutableRequest setValue:[NSString stringWithFormat:@"bytes=%ld-",alreadyDownloadLength] forHTTPHeaderField:@"Range"];
            _dataTask = [self.session dataTaskWithRequest:mutableRequest];
    }
    return _dataTask;
}
- (NSMutableDictionary *)totalDataLengthDictionary
{
    if (!_totalDataLengthDictionary) {
        _totalDataLengthDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:XHRTotalDataLengthDictionaryPath];
        if (!_totalDataLengthDictionary) {
            _totalDataLengthDictionary = [NSMutableDictionary dictionary];
        }
    }
    return _totalDataLengthDictionary;
}
- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc]init]];
    }
    return _session;
}

- (void)resume
{
    if (!self.isDownloading) {
        [self.dataTask resume];
        self.isDownloading = YES;
        self.isSuspend = NO;
    }
}
- (void)suspend
{
    if (!self.isSuspend) {
        [self.dataTask suspend];
        self.isSuspend = YES;
        self.isDownloading = NO;
    }
}
- (void)cancel
{
    [self.session invalidateAndCancel];
    self.session = nil;
    self.dataTask = nil;
    !self.completeBlock?:self.completeBlock(XHRFilePath,nil);
}
//服务器响应以后调用的代理方法
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    //接受到服务器响应
    //获取文件的全部长度
    self.totalDataLengthDictionary[self.fileName] = @([response.allHeaderFields[@"Content-Length"] integerValue] + XHRAlreadyDownloadLength);
    [self.totalDataLengthDictionary writeToFile:XHRTotalDataLengthDictionaryPath atomically:YES];
    //打开outputStream
    [self.stream open];
    
    //调用block设置允许进一步访问
    completionHandler(NSURLSessionResponseAllow);
    
}
//接收到数据后调用的代理方法
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    //把服务器传回的数据用stream写入沙盒中
    [self.stream write:data.bytes maxLength:data.length];
    self.downloadProgress = 1.0 * XHRAlreadyDownloadLength / [self.totalDataLengthDictionary[self.fileName] integerValue];
}
//任务完成后调用的代理方法
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        self.downloadError = error;
        return;
    }
    //关闭流
    [self.stream close];
    //清空task
    [self.session invalidateAndCancel];
    self.dataTask = nil;
    self.session = nil;
    //清空总长度的字典
    [self.totalDataLengthDictionary removeObjectForKey:self.fileName];
    [self.totalDataLengthDictionary writeToFile:XHRTotalDataLengthDictionaryPath atomically:YES];
    !self.completeBlock?:self.completeBlock(XHRFilePath,nil);
    
}
- (void)downloadFromURL:(NSString *)urlString progress:(void (^)(CGFloat))downloadProgressBlock complement:(void (^)(NSString *, NSError *))completeBlock
{
    self.urlString = urlString;
    self.fileName = urlString.md5String;
    self.downloadProgressBlock = downloadProgressBlock;
    self.completeBlock = completeBlock;
}
- (void)setDownloadProgress:(CGFloat)downloadProgress
{
    _downloadProgress = downloadProgress;
    !self.downloadProgressBlock?:self.downloadProgressBlock(downloadProgress);
}
- (void)setDownloadError:(NSError *)downloadError
{
    _downloadError = downloadError;
    !self.completeBlock?:self.completeBlock(nil,downloadError);
}

@end
