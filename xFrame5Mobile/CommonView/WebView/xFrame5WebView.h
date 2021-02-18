//
//  xFrame5WebView.h
//  xFrame5
//
//  Created by Sanghong Han on 2019/11/08.
//  Copyright © 2019 softbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WKProcessPool.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebViewPoolHandler : NSObject
{
}
+ (WKProcessPool *)pool;
@end

@protocol xFrame5WebViewDelegate <NSObject>

- (void)registerEventWithKey:(NSString *)aKey value:(NSString *)aValue;
- (void)phonecall:(NSDictionary *)aDict;
- (void)openSettingView;
- (void)getSystemInformation:(NSString *)aCallback;
- (void)getGeoInfo:(NSString *)aCallback;
- (void)showToastMessage:(NSDictionary *)dict;
- (void)openCamera;
- (void)openAlbum;
- (void)openContacts;
- (void)vibrate;
- (void)playSound:(NSString *)filename;
- (void)sendSMS:(NSDictionary *)dict;
- (void)sendEmail:(NSDictionary *)dict;
- (void)eventLock:(NSDictionary *)dict;
- (void)eventUnLock;
- (void)appdata:(NSDictionary *)dict callback:(NSString *)aCallback;
- (void)sendPushToken:(NSDictionary *)dict callback:(NSString *)aCallback;
//
// 파일관련
//
- (void)writeFile:(NSDictionary *)dict;
- (void)listFiles:(NSString *)aCallback;
- (void)readFile:(NSDictionary *)dict callback:(NSString *)aCallback;
- (void)deleteFile:(NSString *)filename callback:(NSString *)aCallback;
- (void)fileexist:(NSDictionary *)dict callback:(NSString *)aCallback;
- (void)filesize:(NSDictionary *)dict callback:(NSString *)aCallback;
- (void)filetime:(NSDictionary *)dict callback:(NSString *)aCallback;

//
// 로그관련
//
- (void)logStart;
- (void)logStop;
- (void)logSetLevel:(NSDictionary *)dict;
- (void)logWrite:(NSString *)sLevel data:(NSString *)sContents;
- (void)logView:(NSDictionary *)dict;
- (void)loginfo:(NSString *)callback;

//기타
- (void)qrcode:(NSString *)callback;
- (void)readNFCTag:(NSString *)callback;

@end

@interface xFrame5WebView : UIView

@property (nonatomic, assign) id<xFrame5WebViewDelegate> xFrameDelegate;

- (void)callJavaScript:(NSString *)aScript;
- (void)loadRequest:(NSURLRequest *)request;

@end

NS_ASSUME_NONNULL_END
