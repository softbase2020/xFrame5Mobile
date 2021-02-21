//
//  xFrame5Delegate.m
//  xFrame5
//
//  Created by HanSanghong on 2016. 6. 20..
//  Copyright © 2016년 directionsoft. All rights reserved.
//

#import "xFrame5Delegate.h"
#import "MainViewController.h"
#import "Reachability.h"
#import "xFrame5Mobile.h"


@interface xFrame5Delegate() <UIAlertViewDelegate>
{
    MainViewController *_mainViewController;
    Reachability *_reachability;
}
@end

@implementation xFrame5Delegate

#pragma mark - Public Method

- (NSString *)getNetworkStatus
{
    NSString *sNetworkType = @"";
    NetworkStatus netStatus =  [_reachability currentReachabilityStatus];
    switch (netStatus) {
        case ReachableViaWiFi:
            sNetworkType = @"1";
            break;
            
        case ReachableViaWWAN:
            sNetworkType = @"2";
            break;
            
        case NotReachable:
            sNetworkType = @"0";
            break;
            
        default:
            break;
    }
    
    return sNetworkType;
}

- (void)AppExit
{
    UIApplication *app = [UIApplication sharedApplication];
    [app performSelector:@selector(suspend)];
    [NSThread sleepForTimeInterval:0.5];
    exit(0);
}

#pragma mark - Network Detect

- (void)reachabilityDidChange:(NSNotification *)notification {
    
    self.networkType = [self getNetworkStatus];
    if (_mainViewController) {
        [_mainViewController setNetworkType:self.networkType];
    }
}

#pragma mark - init

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - init

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 네트워크 변경 Notification 등록
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityDidChange:)
                                                 name:kReachabilityChangedNotification
                                               object: nil];
    
    _reachability = [Reachability reachabilityForInternetConnection];
    [_reachability startNotifier];
    
    // 윈도우 생성
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    // 로그 환경 설정 정보 기본값 설정
    // 로그 기능은 제거하는 것으로 이야기 됨 : 2019.10.28
    NSDictionary *dictLog = [UserDefaults objectForKey:@"Logger"];
    if ((dictLog == nil) || ([dictLog isKindOfClass:[NSDictionary class]] == NO)){
        // Logger 데이터가 없으면 기본 값으로 설정
        NSMutableDictionary *dictTemp = [NSMutableDictionary dictionary];
        [dictTemp setValue:@"xFrame5Log" forKey:@"LogName"];
        [dictTemp setValue:@"1" forKey:@"LogMaxSize"];
        [dictTemp setValue:@"1" forKey:@"LogKeepDays"];
        [dictTemp setValue:@"0" forKey:@"LogLevel"];
        [UserDefaults setValue:dictTemp forKey:@"Logger"];
        [UserDefaults synchronize];
    }

    NSError *curError = nil;

    NSString *sDebugPath = [documentPath stringByAppendingPathComponent:kDebugFolderName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:sDebugPath] == NO) {
        BOOL bResult = [[NSFileManager defaultManager] createDirectoryAtPath:sDebugPath withIntermediateDirectories:YES attributes:nil error:&curError];
        if (bResult == NO) {
            NSLog(@"curError is %@", [curError localizedDescription]);
        }
    }
    
    NSDictionary *dictInfoKey = [UserDefaults objectForKey:@"xFrame5"];
    
    if (dictInfoKey == nil) {
        dictInfoKey = [ABBundle objectForKey:@"xFrame5"];
        [UserDefaults setValue:dictInfoKey forKey:@"xFrame5"];
    }
    
    if (dictInfoKey == nil) {
        [NSException raise:kFrameworkName format:@"%@", @"info.plist에 xFrame5 키가 존재해야 합니다."];
        return NO;
    }
    
//    if (dictInfoKey[@"START_PAGE"] && ![dictInfoKey[@"START_PAGE"] isEqualToString:@""]) {
//        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//        [dict setValue:dictInfoKey[@"START_PAGE"] forKey:@"initPage"];
//        [UserDefaults setValue:dict forKey:@"xFrame5"];
//        [UserDefaults synchronize];
//    }
//    else {
//        [NSException raise:kFrameworkName format:@"%@", @"xFrame5 항목에 START_PAGE가 올바르지 않습니다."];
//        return NO;
//    }
    
   _mainViewController = [[MainViewController alloc] init];
   UINavigationController *rootNav = [[UINavigationController alloc] initWithRootViewController:_mainViewController];
   self.window.rootViewController = rootNav;
   [self.window makeKeyAndVisible];
    
    application.applicationSupportsShakeToEdit = YES;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_mainViewController) {
            [self->_mainViewController setApplicationState:UIApplicationStateBackground];
        }
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
 
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        
        if (self->_mainViewController) {
            [self->_mainViewController setApplicationState:UIApplicationStateActive];
        }
    });
}

@end
