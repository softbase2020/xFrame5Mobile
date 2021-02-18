//
//  NSDictionary+xFrame5.m
//  xFrame5
//
//  Created by HanSanghong on 2016. 8. 8..
//  Copyright © 2016년 softbase. All rights reserved.
//

#import "NSDictionary+xFrame5.h"

@implementation NSDictionary (xFrame5)

- (NSString *)convertJSONString
{
    NSError *err = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&err];
    if (err) {
        NSString *sResult =  @"{\"code\":-100, \"result\":\"%@\"}";
        return [NSString stringWithFormat:sResult, [err localizedDescription]];
    }
    else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end
