//
//  xFrame5WebView.m
//  xFrame5
//
//  Created by Sanghong Han on 2019/11/08.
//  Copyright © 2019 softbase. All rights reserved.
//

#import "xFrame5WebView.h"

#import "xFrame5Mobile.h"
#import "NSString+xFrame5.h"
#import "CommonAlertView.h"

#import <WebKit/WebKit.h>

@interface xFrame5WebView() <WKUIDelegate, WKNavigationDelegate>
{
    BOOL _shouldCancelNavigation;
}

@property (nonatomic, strong) WKWebView *wkWeb;

@end

@implementation WKWebViewPoolHandler

+ (WKProcessPool *) pool
{
    static dispatch_once_t onceToken;
    static WKProcessPool *_pool;
    dispatch_once(&onceToken, ^{
        _pool = [[WKProcessPool alloc] init];
    });
    return _pool;
}

@end

@implementation xFrame5WebView

- (void)registerUserFunction:(NSString *)aQuery
{
    NSDictionary *dictParam = [aQuery parseURLParams];
    
    NSString *sKey = dictParam[@"event"];
    NSString *sValue = dictParam[@"func"];
    
    if (sValue && ([sValue isEqualToString:@""] == NO)) {
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(registerEventWithKey:value:)] ) {
            [self.xFrameDelegate registerEventWithKey:sKey value:sValue];
        }
    }
}

- (void)appinterface:(NSString *)aQuery
{
    NSDictionary *dictQuery = [aQuery parseURLParams];
    
    NSString *sFuncName = dictQuery[@"func"];
    NSString *sParam = dictQuery[@"params"];
    sParam = [sParam stringByRemovingPercentEncoding];
    sParam = [sParam stringByRemovingPercentEncoding];
    NSString *callback = dictQuery[@"callback"];
    
    sFuncName = [sFuncName isEqualToString:@""] ? @"" : [sFuncName lowercaseString];
    
    NSLog(@"sFuncName is %@", sFuncName);
    
    // ------------------------------------------------------------------------------------------------
    //  1. 시스템정보획득 API
    //  - 기본 시스템정보 : xFrame5.web2app('systemInfo', '', 'setSystemInfo');
    //  - 위/경도얻기  : xFrame5.web2app('geoinfo', '', 'setGeoInfo');
    //  - 네트웍크상태얻기 : xFrame5.web2app('networkstatus', '', 'setGeoInfo');
    // ------------------------------------------------------------------------------------------------

    // 시스템 정보 취득
    if ([sFuncName isEqualToString:@"infosys"]) {
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(getSystemInformation:)]) {
            [self.xFrameDelegate getSystemInformation:callback];
        }
    }
    // 위/경도 얻기
    else if ([sFuncName isEqualToString:@"infogeo"]) {
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(getGeoInfo:)]) {
            [self.xFrameDelegate getGeoInfo:callback];
        }
    }
    // 네트웍크연결 상태 얻기
    else if ([sFuncName isEqualToString:@"infonet"]) {
        if ([callback isEqualToString:@""] == NO) {
            NSString *response = [NSString stringWithFormat:@"{\"code\":200, \"result\":\"성공\", \"network\":\"%@\"}", [xFrameAppDelegate getNetworkStatus]];
            NSString *sJavaScript = [NSString stringWithFormat:@"%@('infonet', '%@')", callback, response];
            [self callJavaScript:sJavaScript];
        }
        else {
            
        }
    }
    
    // ------------------------------------------------------------------------------------------------
    //  2. 어플리케이션 API
    //  - 앱 종료 : xFrame5.web2app('appExit', '', '');
    //  - 메시지 박스  : xFrame5.web2app('msgBox', 'title=테스트&message=메시지박스예제입니다.', '');
    //  - 토스트 메시지 : xFrame5.web2app('toastMsg', 'message=토스트예제입니다.', '');
    //  - 이벤트 Lock : xFrame5.web2app('eventLock', '', '');
    //  - 이벤트 UnLock : xFrame5.web2app('eventUnLock', '', '');
    // ------------------------------------------------------------------------------------------------
    
    // 앱 종료
    else if ([sFuncName isEqualToString:@"appexit"]) {
        [xFrameAppDelegate AppExit];
    }
    // 메시지 박스 표시
    else if ([sFuncName isEqualToString:@"msgbox"]) {
        NSDictionary *dictParam = [sParam parseURLParams];
        if (dictParam && dictParam[@"message"]) {
            NSString *sMessage = dictParam[@"message"];
            NSString *sTitle = dictParam[@"title"] ? dictParam[@"title"] : [ABBundle objectForKey:@"AppName"];
            
            if (sMessage && ([sMessage isEqualToString:@""] == NO)) {
                
                CommonAlertView *alert = [[CommonAlertView alloc] init];
                [alert showCustomAlertView:nil
                                     title:sTitle
                                   message:sMessage
                         cancelButtonTitle:nil
                             okButtonTitle:@"확인"];
                alert.okClick = ^{
                   
                };
            }
        }
    }
    // 토스트 표시
    else if ([sFuncName isEqualToString:@"toast"]) {
        NSDictionary *dictParam = [sParam parseURLParams];
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(showToastMessage:)]) {
            [self.xFrameDelegate showToastMessage:dictParam];
        }
    }
    // 이벤트 Lock
    else if ([sFuncName isEqualToString:@"applock"]) {
        NSDictionary *dictParam = [sParam parseURLParams];
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(eventLock:)]) {
            [self.xFrameDelegate eventLock:dictParam];
        }
    }
    // 이벤트 UnLock
    else if ([sFuncName isEqualToString:@"appunlock"]) {
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(eventUnLock)]) {
            [self.xFrameDelegate eventUnLock];
        }
    }
    // 공유 데이터 가져오기
    else if ([sFuncName isEqualToString:@"appdata"]) {
        NSDictionary *dictParam = [sParam parseURLParams];
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(appdata:callback:)]) {
            [self.xFrameDelegate appdata:dictParam callback:callback];
        }
    }
    //
    // 설정화면 표시하기
    //
    else if ([sFuncName isEqualToString:@"appsetup"]) {
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(openSettingView)]) {
            [self.xFrameDelegate openSettingView];
        }
    }
    
    // ------------------------------------------------------------------------------------------------
    //  4. Play API
    //  - 전화걸기 : xFrame5.web2app('phonecall', 'phoneno=01012345678', '');
    //  - 카메라구동 : xFrame5.web2app('openCamera', '', '');
    //  - 사운드재생 : xFrame5.web2app('playSound', 'file=test.mp3', '');
    //  - 진동 : xFrame5.web2app('vibrate', '', '');
    //  - SMS 전송 : xFrame5.web2app('sendSMS', 'to=01012345678&message=메시지전송테스트입니다.', '');
    //  - Email 전송 : xFrame5.web2app('sendEmail', 'to=test@test.com&subject=제목입니다.&message=메일 내용입니다...', '');
    //  - 주소록 : xFrame5.web2app('openContacts', '', '');
    //  - 갤러리열기 : xFrame5.web2app('openAlbum', '', '');
    //  - 타앱열기 : xFrame5.web2app('executeApp', 'app=kakaotalk://', ''); // for iOS
    // ------------------------------------------------------------------------------------------------
    
    // 전화걸기
    if ([sFuncName isEqualToString:@"sendcall"]) {
        NSDictionary *dictParam = [sParam parseURLParams];
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(phonecall:)]) {
            [self.xFrameDelegate phonecall:dictParam];
        }
    }
    // 카메라 동작하기
    else if ([sFuncName isEqualToString:@"playcamera"]) {
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(openCamera)]) {
            [self.xFrameDelegate openCamera];
        }
    }
    // 사운드 재생
    else if ([sFuncName isEqualToString:@"playsound"]) {
        NSDictionary *dictParam = [sParam parseURLParams];
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(playSound:)]) {
            [self.xFrameDelegate playSound:dictParam[@"filename"]];
        }
    }
    // Vibrate
    else if ([sFuncName isEqualToString:@"playvibrate"]) {
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(vibrate)]) {
            [self.xFrameDelegate vibrate];
        }
    }
    // send SMS
    else if ([sFuncName isEqualToString:@"sendsms"]) {
        NSDictionary *dictParam = [sParam parseURLParams];
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(sendSMS:)]) {
            [self.xFrameDelegate sendSMS:dictParam];
        }
    }
    // send Email
    else if ([sFuncName isEqualToString:@"sendemail"]) {
        NSDictionary *dictParam = [sParam parseURLParams];
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(sendEmail:)]) {
            [self.xFrameDelegate sendEmail:dictParam];
        }
    }
    // 주소록 열기
    else if ([sFuncName isEqualToString:@"opencontact"]) {
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(openContacts)]) {
            [self.xFrameDelegate openContacts];
        }
    }
    // 앨범 선택하기
    else if ([sFuncName isEqualToString:@"openalbum"]) {
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(openAlbum)]) {
            [self.xFrameDelegate openAlbum];
        }
    }
    // 타앱 실행하기
    else if ([sFuncName isEqualToString:@"openapp"]) {
        NSDictionary *dictParam = [sParam parseURLParams];
        if (dictParam && dictParam[@"app"]) {
            NSString *sAppScheme = dictParam[@"app"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sAppScheme]
                                               options:@{}
                                    completionHandler:^(BOOL success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *response = success ? @"{\"code\":200, \"result\":\"성공\"}" : @"{\"code\":-100, \"result\":\"앱이 존재하지 않습니다.\"}";
                    NSString *sJavaScript = [NSString stringWithFormat:@"%@('openapp', '%@')", callback, response];
                    [self callJavaScript:sJavaScript];
                });
            }];
        }
    }
    // ------------------------------------------------------------------------------------------------
    //  5. 파일 API
    //  - 파일쓰기 : xFrame5.web2app('writeFile', 'filename=test&c=xxxxxxxx', '');
    //  - 파일목록 : xFrame5.web2app('listFiles', '', '');
    //  - 파일읽기 : xFrame5.web2app('readFile', 'file=test.mp3', '');
    //  - 파일삭제 : xFrame5.web2app('deleteFile', 'filename=test', '');
    // ------------------------------------------------------------------------------------------------
    
    // 파일존재확인
    else if ([sFuncName isEqualToString:@"fileexist"]) {
        NSDictionary *dictParam = [sParam parseURLParams];
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(fileexist:callback:)]) {
            [self.xFrameDelegate fileexist:dictParam callback:callback];
        }
    }
    // 파일사이즈
    else if ([sFuncName isEqualToString:@"filesize"]) {
        NSDictionary *dictParam = [sParam parseURLParams];
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(filesize:callback:)]) {
            [self.xFrameDelegate filesize:dictParam callback:callback];
        }
    }
    // 파일시간
    else if ([sFuncName isEqualToString:@"filetime"]) {
        NSDictionary *dictParam = [sParam parseURLParams];
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(filetime:callback:)]) {
            [self.xFrameDelegate filetime:dictParam callback:callback];
        }
    }
    // 파일쓰기
    else if ([sFuncName isEqualToString:@"filewrite"]) {
        NSDictionary *dictParam = [sParam parseURLParams];
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(writeFile:)]) {
            [self.xFrameDelegate writeFile:dictParam];
        }
    }
    // 파일목록 가져오기
    else if ([sFuncName isEqualToString:@"filelist"]) {
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(listFiles:)]) {
            [self.xFrameDelegate listFiles:callback];
        }
    }
    // 파일읽기
    else if ([sFuncName isEqualToString:@"fileread"]) {
        NSDictionary *dictParam = [sParam parseURLParams];
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(readFile:callback:)]) {
            [self.xFrameDelegate readFile:dictParam callback:callback];
        }
    }
    // 파일삭제
    else if ([sFuncName isEqualToString:@"filedelete"]) {
        NSDictionary *dictParam = [sParam parseURLParams];
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(deleteFile:callback:)]) {
            [self.xFrameDelegate deleteFile:dictParam[@"filename"] callback:callback];
        }
    }
    // ------------------------------------------------------------------------------------------------
    //  6. 로그 API
    //  - 로그 환경 설정 : xFrame5.web2app('logSetting', '', '');
    //  - 로그기록 : xFrame5.web2app('logWrite', 'level=info&data=xxxxxxxxxxxxxxx', '');
    //  - 로그레벨정의 : xFrame5.web2app('setLogLevel', 'level=debug', '');
    //  - 로그시작 : xFrame5.web2app('logStart', '', '');
    //  - 로그중지 : xFrame5.web2app('logStop', '', '');
    //  - 로그보기 : xFrame5.web2app('logView', '', '');
    // ------------------------------------------------------------------------------------------------

    // 로그시작
    else if ([sFuncName isEqualToString:@"logstart"]) {
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(logStart)]) {
            [self.xFrameDelegate logStart];
        }
    }
    // 로그중지
    else if ([sFuncName isEqualToString:@"logstop"]) {
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(logStop)]) {
            [self.xFrameDelegate logStop];
        }
    }
    // 로그보기
    else if ([sFuncName isEqualToString:@"logview"]) {
        NSDictionary *dictParam = [sParam parseURLParams];
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(logView:)]) {
            [self.xFrameDelegate logView:dictParam];
        }
    }
    // 로그정보
    else if ([sFuncName isEqualToString:@"loginfo"]) {
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(loginfo:)]) {
            [self.xFrameDelegate loginfo:callback];
        }
    }
    // 로그레벨정의
    else if ([sFuncName isEqualToString:@"loglevel"]) {
        NSDictionary *dictParam = [sParam parseURLParams];
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(logSetLevel:)]) {
            [self.xFrameDelegate logSetLevel:dictParam];
        }
    }
    // 로그쓰기
    else if ([sFuncName isEqualToString:@"logwrite"]) {
        NSDictionary *dictParam = [sParam parseURLParams];
        NSLog(@"dictParam is %@", dictParam);
        if (dictParam && dictParam[@"level"] && dictParam[@"message"]) {
            if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(logWrite:data:)]) {
                [self.xFrameDelegate logWrite:dictParam[@"level"] data:dictParam[@"message"]];
            }
        }
    }
    else if ([sFuncName isEqualToString:@"qrcode"]) {
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(qrcode:)]) {
            [self.xFrameDelegate qrcode:callback];
        }
    }
    else if ([sFuncName isEqualToString:@"nfctag"]) {
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(readNFCTag:)]) {
            [self.xFrameDelegate readNFCTag:callback];
        }
    }
    else if ([sFuncName isEqualToString:@"pushtoken"]) {
        NSDictionary *dictParam = [sParam parseURLParams];
        if (self.xFrameDelegate && [self.xFrameDelegate respondsToSelector:@selector(sendPushToken:callback:)]) {
            [self.xFrameDelegate sendPushToken:dictParam  callback:callback];
        }
    }
}

#pragma mark - WKWebView Delegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{

}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSString *scheme = navigationAction.request.URL.scheme.lowercaseString;
    NSURL *url = navigationAction.request.URL;
    
    NSLog(@"url is %@", url);

    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"] || [scheme isEqualToString:@"about"]) {
        //scheme이 http, https, about인 경우는 그냥 실행
        decisionHandler(WKNavigationActionPolicyAllow);
        return ;
    }
    else if ([scheme isEqualToString:@"itms-apps"] || [scheme isEqualToString:@"itms-appss"]) {
        [[UIApplication sharedApplication] openURL:url
                                           options:@{}
                                 completionHandler:^(BOOL success) {
            decisionHandler(WKNavigationActionPolicyAllow);
            return ;
        }];
    }
    else if ([scheme isEqualToString:@"xframe5"]) {
        if ([url.host isEqualToString:@"register"]) {
            [self registerUserFunction:url.query];
        }
        else if ([url.host isEqualToString:@"appinterface"]) {
            [self appinterface:url.query];
        }
        
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    else {
        [[UIApplication sharedApplication] openURL:url
                                           options:@{}
                                 completionHandler:^(BOOL success) {
            decisionHandler(WKNavigationActionPolicyCancel);
            return ;
        }];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    //Cookie 동기화...
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
    
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
//    [_wkWeb evaluateJavaScript:@"document.body.style.webkitTouchCallout='none';"
//             completionHandler:^(id result, NSError *error) {
//    }];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"webView error is %@", error);
}

#pragma mark - Public Method

- (void)callJavaScript:(NSString *)aScript
{
    [self.wkWeb evaluateJavaScript:aScript
                 completionHandler:^(id value, NSError *error) {
        
    }];
}

- (void)loadRequest:(NSURLRequest *)request
{
    [self.wkWeb loadRequest:request];
}

#pragma mark - init

- (void)setup
{
    self.backgroundColor = [UIColor whiteColor];
    
    WKPreferences *thisPref = [[WKPreferences alloc] init];
    thisPref.javaScriptCanOpenWindowsAutomatically = YES;
    thisPref.javaScriptEnabled = YES;
    
    WKWebViewConfiguration* configuration = WKWebViewConfiguration.new;
    configuration.processPool = [WKWebViewPoolHandler pool];
    configuration.allowsInlineMediaPlayback = YES;
    configuration.mediaTypesRequiringUserActionForPlayback = NO;
    configuration.allowsPictureInPictureMediaPlayback = YES;
    configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    configuration.applicationNameForUserAgent = [NSString stringWithFormat:@"xFrame5mobile/%@", APPVERSION];
    configuration.preferences = thisPref;
    
    self.wkWeb = [[WKWebView alloc] initWithFrame:self.bounds configuration:configuration];
    self.wkWeb.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.wkWeb.UIDelegate = self;
    self.wkWeb.navigationDelegate = self;
    self.wkWeb.multipleTouchEnabled = NO;
    //_wkWeb.allowsBackForwardNavigationGestures = YES;
    
    [self addSubview:_wkWeb];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }

    return self;
}


@end
