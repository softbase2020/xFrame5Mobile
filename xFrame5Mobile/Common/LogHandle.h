//
//  LogHandle.h
//  xFrame5
//
//  Created by HanSanghong on 2016. 8. 21..
//  Copyright © 2016년 softbase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogHandle : NSObject

@property (nonatomic, strong) NSString      *logFileName;
@property (nonatomic, strong) NSString      *sFilename;;
@property (nonatomic, assign) NSInteger     nLogLevel;
@property (nonatomic, assign) NSInteger     nIndex;

- (void)logWrite:(NSString *)sContents level:(NSString *)sLevel;
- (NSArray *)getLogFileList;
- (NSString *)contentsOfFile:(NSString *)filename;
- (NSDate *)fileCreationDate:(NSString *)filename;
- (void)deleteFile:(NSString *)filename;
+ (NSString *)todayLogFilename;

@end
