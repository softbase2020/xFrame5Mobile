//
//  SystemInfo.m
//  xFrame5
//
//  Created by HanSanghong on 2016. 8. 2..
//  Copyright © 2016년 softbase. All rights reserved.
//

#import "SystemInfo.h"

#import <sys/utsname.h>
#import <sys/sysctl.h>

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <UIKit/UIDevice.h>

@implementation SystemInfo

+ (NSString *)getDeviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (NSString *)platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

+ (NSString*)getCurrierName
{
    // Setup the Network Info and create a CTCarrier object
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    
    NSString* str = @"";
    
    // Get carrier name
    str = [carrier carrierName];
    if (str != nil)
        NSLog(@"Carrier: %@", str);

    return str;
}

+ (NSString *)getDeviceOS
{
    return @"iOS";
}

+ (NSString *)getOSVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)getOrientation
{
    if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) ||
        ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)) {
        return @"Landscape";
        
    } else {
        return @"Portrait";
    }
}

+ (NSString *)getUUID
{
    NSString *oldUUID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];
    if ((oldUUID == nil) || ([oldUUID isEqualToString:@""])) {
        NSString *uuid = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setValue:uuid forKey:@"UUID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        return uuid;
    }
    else return oldUUID;
}

@end
