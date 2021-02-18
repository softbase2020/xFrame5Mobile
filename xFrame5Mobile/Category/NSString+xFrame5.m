//
//  NSString+xFrame5.m
//  xFrame5
//
//  Created by HanSanghong on 2016. 7. 14..
//  Copyright © 2016년 softbase. All rights reserved.
//

#import "NSString+xFrame5.h"

#import "CommonFunc.h"

#define documentPath    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@implementation NSString (xFrame5)

- (NSDictionary *)parseURLParams {
    NSArray *pairs = [self componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        if ([kv count] == 2) {
            NSString *val = kv[1];
            //[kv[1] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            params[kv[0]] = val;
        }
        
    }
    return params;
}

- (BOOL)isExistsFile
{
    NSString *sFilePath = [documentPath stringByAppendingPathComponent:self];
  
    if ([[NSFileManager defaultManager] fileExistsAtPath:sFilePath]) {
        NSLog(@"파일이 존재함....");
        return YES;
    }
    else {
        NSLog(@"파일이 존재하지 않음....");
        return NO;
    }
}

- (void)createFolder:(NSString *)sFolder
{
    NSString *sFilePath = [documentPath stringByAppendingPathComponent:sFolder];

    if ([[NSFileManager defaultManager] fileExistsAtPath:sFilePath] == NO)  {
        NSError *error;
        
        if (![[NSFileManager defaultManager] createDirectoryAtPath:sFilePath
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error]) {
            NSLog(@"Create directory error: %@", error);
        }
    }
}

- (void)createLocalFolder
{
    NSArray *arrFolders = [self pathComponents];
    NSString *sFolderName = @"";
    
    for (int i=0; i < [arrFolders count]-1; i++) {
        if ([sFolderName isEqualToString:@""]) {
            sFolderName = arrFolders[i];
        }
        else {
            sFolderName = [NSString stringWithFormat:@"%@/%@", sFolderName, arrFolders[i]];
        }
        [self createFolder:sFolderName];
    }
}

- (NSData *)dataValue
{
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)yyyymmdd
{
    NSString *sExt = [self pathExtension];
    if (sExt && ([sExt isEqualToString:@""] == NO)) {
        NSString *sFilename = [self substringToIndex:([self length]-[sExt length]-2)];
        return [NSString stringWithFormat:@"%@-%@-00.%@", sFilename, [CommonFunc todayStr], sExt];
    }
    else {
        return [NSString stringWithFormat:@"%@-%@-00", self, [CommonFunc todayStr]];
    }
}

@end
