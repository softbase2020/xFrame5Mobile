//
//  FileHandle.h
//  xFrame5
//
//  Created by HanSanghong on 2016. 8. 14..
//  Copyright © 2016년 softbase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "xFrame5Mobile.h"

@interface FileHandle : NSObject

+ (BOOL)isFileExists:(NSString *)filename;
+ (void)writeFile:(NSString *)filename data:(NSString *)sContents mode:(NSString *)filemode;
+ (BOOL)deleteFile:(NSString *)filename;
+ (NSString *)contentsOfFile:(NSString *)filename;
+ (NSArray *)listFiles;
+ (NSString *)getFilesize:(NSString *)filename;
+ (NSDate *)getFileTime:(NSString *)filename;

@end
