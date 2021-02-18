//
//  SystemInfo.h
//  xFrame5
//
//  Created by HanSanghong on 2016. 8. 2..
//  Copyright © 2016년 softbase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemInfo : NSObject

+ (NSString *)getDeviceName;
+ (NSString *)platform;
+ (NSString *)getCurrierName;
+ (NSString *)getDeviceOS;
+ (NSString *)getOSVersion;
+ (NSString *)getOrientation;
+ (NSString *)getUUID;

@end
