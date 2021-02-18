//
//  LogHandle.m
//  xFrame5
//
//  Created by HanSanghong on 2016. 8. 21..
//  Copyright © 2016년 softbase. All rights reserved.
//

#import "LogHandle.h"
#import "CommonFunc.h"

#import "xFrame5Define.h"
#import "NSString+xFrame5.h"
#import "NSDate+xFrame5.h"

#define kFileUnit       1024

@implementation LogHandle

@synthesize logFileName = _logFileName;

- (NSString *)fileFullPath:(NSString *)filename
{
    NSString *sFilename = [documentPath stringByAppendingPathComponent:kDebugFolderName];
    return [sFilename stringByAppendingPathComponent:filename];
}

- (BOOL)isFileExists:(NSString *)filename
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self fileFullPath:filename]];
}

- (double)getFileSize
{
    NSString *sFullPath = [self fileFullPath:_logFileName];
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:sFullPath error:nil] fileSize];
}

#pragma mark - Public Mthod

- (void)logWrite:(NSString *)sContents level:(NSString *)sLevel
{
    if ([self isFileExists:_logFileName]) {
        
        NSDate *createDate = [self fileCreationDate:_logFileName];
        if ([createDate CompareFromNow] == 0) {
            NSString *sData = [self contentsOfFile:_logFileName];
            sContents = [NSString stringWithFormat:@"%@\n[%@][%@]%@", sData, [CommonFunc todayStr:@"yyyy-MM-dd hh:mm:ss"], sLevel, sContents];
        }
        else {
            sContents = [NSString stringWithFormat:@"[%@][%@]%@", [CommonFunc todayStr:@"yyyy-MM-dd hh:mm:ss"], sLevel, sContents];
        }
    }
    else {
        sContents = [NSString stringWithFormat:@"[%@][%@]%@", [CommonFunc todayStr:@"yyyy-MM-dd hh:mm:ss"], sLevel, sContents];
    }
    
    NSString *sFilePath = [self fileFullPath:_logFileName];
    [[NSFileManager defaultManager] createFileAtPath:sFilePath contents:[sContents dataValue] attributes:NULL];
}

- (NSArray *)getLogFileList
{
    NSString *sDebugPath = [documentPath stringByAppendingPathComponent:kDebugFolderName];
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sDebugPath error:nil];
}

- (NSString *)contentsOfFile:(NSString *)filename
{
    NSData *dataBuffer = [[NSFileManager defaultManager] contentsAtPath:[self fileFullPath:filename]];
    return [[NSString alloc] initWithData:dataBuffer encoding:NSUTF8StringEncoding];
}

- (NSDate *)fileCreationDate:(NSString *)filename
{
    NSString *sFullpath = [self fileFullPath:filename];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDictionary* attrs = [fm attributesOfItemAtPath:sFullpath error:nil];
    
    return (NSDate*)[attrs objectForKey: NSFileCreationDate];
}

- (void)deleteFile:(NSString *)filename
{
    NSString *sFullPath = [self fileFullPath:filename];
    [[NSFileManager defaultManager] removeItemAtPath:sFullPath error:nil];
}

+ (NSString *)todayLogFilename
{
    int num = [[NSDate date] dd];
    return [NSString stringWithFormat:@"xframe5_%02d.log", num];
}

@end
