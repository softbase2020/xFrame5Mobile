//
//  CommonFunc.m
//  xFrame5
//
//  Created by HanSanghong on 2016. 8. 21..
//  Copyright © 2016년 softbase. All rights reserved.
//

#import "CommonFunc.h"

@implementation CommonFunc

+ (NSString *)todayStr
{
    NSDateFormatter *dFormater = [[NSDateFormatter alloc] init];
    dFormater.dateFormat = @"yyyyMMdd";
    return [dFormater stringFromDate:[NSDate date]];
}

+ (NSString *)todayStr:(NSString *)sFormat
{
    NSDateFormatter *dFormater = [[NSDateFormatter alloc] init];
    dFormater.dateFormat = sFormat;
    return [dFormater stringFromDate:[NSDate date]];
}

@end
