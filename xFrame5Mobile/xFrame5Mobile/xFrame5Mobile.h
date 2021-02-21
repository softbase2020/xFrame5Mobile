//
//  xFrame5Mobile.h
//  xFrame5Mobile
//
//  Created by Sanghong Han on 2021/02/19.
//

#import <UIKit/UIKit.h>

#import <xFrame5Delegate.h>

#define kScreenBoundsWidth              [[UIScreen mainScreen] bounds].size.width
#define kScreenBoundsHeight             [[UIScreen mainScreen] bounds].size.height

//
// Kinds of Device
//
#define IS_IPAD                         (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE                       (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_6PLUS                 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && kScreenBoundsHeight == 736)
#define IS_IPHONE_6                     (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && kScreenBoundsHeight == 667)
#define IS_IPHONE_5                     (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && kScreenBoundsHeight == 568)
#define IS_IPHONE_4                     (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && kScreenBoundsHeight == 480)
#define IS_IPHONE_XR_XSMAX              (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && kScreenBoundsHeight == 896)
#define IS_IPHONE_X                     (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && kScreenBoundsHeight == 812)

#define StartY                          [[UIApplication sharedApplication] statusBarFrame].size.height

#define ABBundle                        [[NSBundle mainBundle] infoDictionary]
#define documentPath                    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define xFrameAppDelegate                (xFrame5Delegate *)[[UIApplication sharedApplication] delegate]

#define UserDefaults                    [NSUserDefaults standardUserDefaults]

#define LogLevels                       [NSArray arrayWithObjects:@"debug", @"info", @"warn", @"error", @"fatal", nil]

#define APPVERSION                       [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define NETWORK_TIMEOUT                 10.f
#define kHeaderHeight                   48.f

#define kTagAlertApply                  1000

#define kFrameworkName                  @"xFrame5Mobile mobile framework"
#define kDebugFolderName                @"xFrame5Debug"
#define kFramworkBundle                 @"com.softbase.xFrame5Mobile"
#define LocalizedString(key)            NSLocalizedString(key , nil)

typedef NS_ENUM(NSInteger, DebugType) {
    DebugTypeStop = 0,
    DebugTypeStart = 1,
    DebugTypeNone = -1,

};
