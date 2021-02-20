//
//  NSString+xFrame5.h
//  xFrame5
//
//  Created by HanSanghong on 2016. 7. 14..
//  Copyright © 2016년 softbase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (xFrame5)

- (NSDictionary *)parseURLParams;
- (BOOL)isExistsFile;
- (void)createLocalFolder;
- (NSData *)dataValue;
- (NSString *)yyyymmdd;

@end
