//
//  NSDate+xFrame5.m
//  xFrame5
//
//  Created by HanSanghong on 2016. 8. 25..
//  Copyright © 2016년 softbase. All rights reserved.
//

#import "NSDate+xFrame5.h"

@implementation NSDate (xFrame5)

- (NSInteger)CompareFromNow
{
    NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
    [mdf setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:self]];
    return (int)[midnight timeIntervalSinceNow] / (60*60*24);
}

- (NSString *)yyyymmdd
{
    NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
    [mdf setDateFormat:@"yyyyMMdd"];
    
    return [mdf stringFromDate:self];
}

- (NSString *)hhmmss
{
    NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
    [mdf setDateFormat:@"HHmmss"];
    
    return [mdf stringFromDate:self];
}

- (int)dd
{
    NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
    [mdf setDateFormat:@"dd"];
    
    return [[mdf stringFromDate:self] intValue];
}

@end
