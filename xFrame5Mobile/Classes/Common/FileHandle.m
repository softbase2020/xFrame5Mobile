//
//  FileHandle.m
//  xFrame5
//
//  Created by HanSanghong on 2016. 8. 14..
//  Copyright © 2016년 softbase. All rights reserved.
//

#import "FileHandle.h"
#import "NSString+xFrame5.h"

@implementation FileHandle

+ (NSString *)fileFullPath:(NSString *)filename
{
    NSString *sFilename = [documentPath stringByAppendingPathComponent:@"files"];
    return [sFilename stringByAppendingPathComponent:filename];
}

+ (BOOL)isFileExists:(NSString *)filename
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self fileFullPath:filename]];
}

+ (void)writeFile:(NSString *)filename data:(NSString *)sContents mode:(NSString *)filemode
{
    NSString *s = @"";
    
    if ([self isFileExists:filename]) {
        
        if ([filemode isEqualToString:@"overwrite"]) {
            [self deleteFile:filename];
            
            s = sContents;
        }
        else {
            NSData *dataBuffer = [[NSFileManager defaultManager] contentsAtPath:[self fileFullPath:filename]];
            NSString *sResult = [[NSString alloc] initWithData:dataBuffer encoding:NSUTF8StringEncoding];
            s = [NSString stringWithFormat:@"%@\n%@", sResult, sContents];
        }
    }
    else {
        s = sContents;
        NSString *sFolder = [documentPath stringByAppendingPathComponent:@"files"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:sFolder] == NO) {
            [[NSFileManager defaultManager] createDirectoryAtPath:sFolder withIntermediateDirectories:YES attributes:NULL error:nil];
        }
    }
    
    NSString *sFilePath = [self fileFullPath:filename];
    NSLog(@"sFIlePath is %@", sFilePath);
    [[NSFileManager defaultManager] createFileAtPath:sFilePath contents:[s dataValue] attributes:NULL];
}

+ (BOOL)deleteFile:(NSString *)filename
{
    return [[NSFileManager defaultManager] removeItemAtPath:[self fileFullPath:filename] error:nil];
}

+ (NSString *)contentsOfFile:(NSString *)filename
{
    NSData *dataBuffer = [[NSFileManager defaultManager] contentsAtPath:[self fileFullPath:filename]];
    return [[NSString alloc] initWithData:dataBuffer encoding:NSUTF8StringEncoding];
}

+ (NSArray *)listFiles
{
    NSString *sFolder = [documentPath stringByAppendingPathComponent:@"files"];
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sFolder error:NULL];
}

+ (NSString *)getFilesize:(NSString *)filename
{
    NSString *sFullPath = [self fileFullPath:filename];
    unsigned long long nFilesize = [[[NSFileManager defaultManager] attributesOfItemAtPath:sFullPath error:nil] fileSize];
    
    return [NSString stringWithFormat:@"%lld", nFilesize];
}

+ (NSDate *)getFileTime:(NSString *)filename
{
    NSString *sFullpath = [self fileFullPath:filename];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDictionary* attrs = [fm attributesOfItemAtPath:sFullpath error:nil];
    
    return (NSDate*)[attrs objectForKey:NSFileModificationDate];
}

@end
