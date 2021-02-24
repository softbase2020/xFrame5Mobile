//
//  MainViewController.m
//  appbuilder
//
//  Created by HanSanghong on 2016. 6. 20..
//  Copyright © 2016년 directionsoft. All rights reserved.
//

#import "MainViewController.h"
#import "SettingViewController.h"
#import "LogListViewController.h"
#import "LogViewController.h"

#import "xFrame5WebView.h"
#import "xDimmedView.h"
#import "ToastView.h"
//#import "NetworkManager.h"

#import "xFrame5Mobile.h"
#import "Reachability.h"
#import "SystemInfo.h"
#import "FileHandle.h"
#import "LogHandle.h"
#import "CommonFunc.h"
#import "CommonAlertView.h"
#import "PermissionManager.h"

#import "NSDate+xFrame5.h"
#import "NSString+xFrame5.h"
#import "NSDictionary+xFrame5.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioServices.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <ContactsUI/ContactsUI.h>

//#import <DYQRCodeDecoder/DYQRCodeDecoderViewController.h>

@interface MainViewController ()    <
                                    xFrame5WebViewDelegate,
                                    CLLocationManagerDelegate,
                                    UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate,
                                    MFMessageComposeViewControllerDelegate,
                                    MFMailComposeViewControllerDelegate,
                                    ABPeoplePickerNavigationControllerDelegate,
                                    CNContactPickerDelegate
                                    >
{
    xFrame5WebView              *_webView;
    
    NSMutableDictionary         *_dictUserFunction;
    NSMutableDictionary         *_dictSharedData;
    NSDictionary                *_dictCurrent;
    
    xDimmedView                 *_dimmedView;
    xDimmedView                 *_updateView;
    
    NSString                    *_locationCallback;
    
    NSString                    *_logName;
    NSInteger                   _logMaxSize;
    NSInteger                   _logLevel;
    
    // 로그관련
    DebugType                   _currentDebugType;
    LogHandle                   *_logWriter;
}

@end

@implementation MainViewController

#pragma mark - Public Method

/**
 네트웍이 변경된 경우 네트웍의 상태를 웹뷰에 전달
 네트웍 변경에 따른 이벤트가 등록된 경우에만 호출
 @param networkType : "WIFI" / "3G/LTE" / "Not Connected"
 */
- (void)setNetworkType:(NSString *)networkType
{
    if (_webView) {
        
        NSString *jsName = _dictUserFunction[@"network"];
        //
        // jsName이 존재하는 경우에만.....
        //
        if (jsName && ([jsName isEqualToString:@""] == NO)) {
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:@"200" forKey:@"code"];
            [dict setValue:networkType forKey:@"networkstatus"];
            
            NSString *sScriptName = [NSString stringWithFormat:@"%@('network', '%@');", jsName, [dict convertJSONString]];
            NSLog(@"sScriptName is %@", sScriptName);
            [_webView callJavaScript:sScriptName];
        }
    }
}

- (void)setApplicationState:(UIApplicationState)state
{
    NSString *jsName = (state == UIApplicationStateActive) ? _dictUserFunction[@"enterForeground"] : _dictUserFunction[@"enterBackground"];
    NSString *event_name = (state == UIApplicationStateActive) ? @"enterForeground" : @"enterBackground";
    
    if (_webView) {
        // jsName이 존재하는 경우에만.....
        if (jsName && ([jsName isEqualToString:@""] == NO)) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:@"200" forKey:@"code"];
            [dict setValue:@"success" forKey:@"result"];
            
            NSString *sScriptName = [NSString stringWithFormat:@"%@('%@', '%@');", jsName, event_name, [dict convertJSONString]];
            NSLog(@"sScriptName is %@", sScriptName);
            [_webView callJavaScript:sScriptName];
        }
    }
}

#pragma mark - private

- (NSString *)getDeviceOrientation
{
    if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) ||
        ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)) {
        return @"2"; //Landscape
        
    } else if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) ||
               ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown)) {
        return @"1"; //Portrait
    }
    else {
        return @"99"; //Unkwown
    }
}

- (void)showMessage:(NSString *)sMessage
{
     dispatch_async(dispatch_get_main_queue(), ^{
         CommonAlertView *alert = [[CommonAlertView alloc] init];
         [alert showCustomAlertView:nil
                            title:@""
                          message:sMessage
                cancelButtonTitle:nil
                    okButtonTitle:@"확인"];
         alert.okClick = ^{

         };
     });
}

#pragma mark - Orientatin

/**
    디바이스 로테이션이 발생한 경우 Landscape / Portrait 모두 지원 : return YES
 */
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskPortrait;
}

/**
    디바이스 로테이션이 변경된 경우 호출됨.
 */
- (void) detectOrientation {

    NSString *jsName = _dictUserFunction[@"orientation"];
    //
    // jsName이 존재하는 경우에만.....
    //
    if (jsName && ([jsName isEqualToString:@""] == NO)) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"200" forKey:@"code"];
        [dict setValue:[self getDeviceOrientation] forKey:@"orientation"];
        
        NSString *sScriptName = [NSString stringWithFormat:@"%@('orientation', '%@');", jsName, [dict convertJSONString]];
        NSLog(@"sScriptName is %@", sScriptName);
        [_webView callJavaScript:sScriptName];
    }
}

- (void)LogInfoChangeNotification
{
    
}

#pragma mark - xFrameWebViewDelegate

/**
    이벤트를 등록하는 기능
 */
- (void)registerEventWithKey:(NSString *)aKey value:(NSString *)aValue
{
    [_dictUserFunction setValue:aValue forKey:aKey];
    //NSLog(@"_dictUserFunction is %@", _dictUserFunction);
}

#pragma mark - xFrameWebViewDelegate : 시스템정보획득 API

/**
 시스템 정보 가져오기
 */
- (void)getSystemInformation:(NSString *)aCallback
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[NSString stringWithFormat:@"%d", 200] forKey:@"code"];
    [dict setValue:[NSString stringWithFormat:@"%dx%d", (int)kScreenBoundsWidth, (int)kScreenBoundsHeight] forKey:@"resolution"];
    [dict setValue:[NSString stringWithFormat:@"%@", [SystemInfo platform]] forKey:@"devicemodel"];
    [dict setValue:@"2" forKey:@"os"];
    [dict setValue:[NSString stringWithFormat:@"%@", [SystemInfo getOSVersion]] forKey:@"osversion"];
    [dict setValue:[NSString stringWithFormat:@"%@", [SystemInfo getCurrierName]] forKey:@"telecom"];
    [dict setValue:[NSString stringWithFormat:@"%@", [self getDeviceOrientation]] forKey:@"orientation"];
    
    NSString *sScriptName = [NSString stringWithFormat:@"%@('infosys', '%@');", aCallback, [dict convertJSONString]];
    NSLog(@"sScriptName is %@", sScriptName);
    [_webView callJavaScript:sScriptName];
}

/**
 위/경도 값 리턴하기
 */
- (void)getGeoInfo:(NSString *)aCallback
{
    if ([CLLocationManager locationServicesEnabled]) {
        
        if (self.locationManager == nil) {
            
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.distanceFilter = kCLDistanceFilterNone;
        }
        
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager startUpdatingLocation];
        
        NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.softbase.xFrame5"];
        NSArray *arrDimmedViews = [bundle loadNibNamed:@"xDimmedView" owner:self options:nil];
        _dimmedView = (xDimmedView *)[arrDimmedViews objectAtIndex:0];
        _dimmedView.frame = self.view.bounds;
        [self.view addSubview:_dimmedView];
        
        _updateView = (xDimmedView *)[arrDimmedViews objectAtIndex:1];
        _updateView.frame = self.view.bounds;
        [self.view addSubview:_updateView];
        
        _updateView.infoLabel.text = @"위치 정보를 가져오는 중입니다.";
        
        _locationCallback = aCallback;
    }
}

#pragma mark - xFrameWebViewDelegate : Message API

- (void)showToastMessage:(NSDictionary *)dict
{
    if (dict[@"message"]) {
        ToastView *toastView = [[ToastView alloc] init];
        toastView.toastMsg = dict[@"message"];
        [self.view addSubview:toastView];
        //[toastView showToastWithTime:([dict[@"timeout"] intValue]/1000.f)];
        [toastView showToast];
    }
    else {
        NSLog(@"[toast]파라미터 오류입니다.");
    }
}


#pragma mark - xFrameWebViewDelegate : 어플리케이션 API


- (void)eventLock:(NSDictionary *)dict
{
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.softbase.xFrame5"];
    NSArray *arrDimmedViews = [bundle loadNibNamed:@"xDimmedView" owner:self options:nil];
    
    _dimmedView = (xDimmedView *)[arrDimmedViews objectAtIndex:0];
    _dimmedView.frame = self.view.bounds;
    [self.view addSubview:_dimmedView];
    
    _updateView = (xDimmedView *)[arrDimmedViews objectAtIndex:1];
    _updateView.frame = self.view.bounds;
    [self.view addSubview:_updateView];
    
    _updateView.infoLabel.text = @"데이터 처리 중입니다.";
    
    if (dict && dict[@"timeout"] && ([dict[@"timeout"] isEqualToString:@""] == NO)) {
        [self performSelector:@selector(eventUnLock) withObject:nil afterDelay:([dict[@"timeout"] intValue]/1000.f)];
    }
}

- (void)eventUnLock
{
    [_updateView removeFromSuperview];
    [_dimmedView removeFromSuperview];
    
    _updateView = nil;
    _dimmedView = nil;
}

//- (void)appdata:(NSString *)aKey value:(NSString *)aValue
//{
//    NSLog(@"aKey is %@", aKey);
//    NSLog(@"aValue is %@", aValue);
//
//    [_dictSharedData setValue:aValue forKey:aKey];
//}

- (void)appdata:(NSDictionary *)dict callback:(NSString *)aCallback
{
    NSLog(@"_dictSharedData is %@", _dictSharedData);
    
    if (dict[@"value"]) {
        [_dictSharedData setValue:dict[@"value"] forKey:dict[@"key"]];
    }
    else {
        NSString *aKey = dict[@"key"];
        NSString *sValue = _dictSharedData[aKey];
        
        [dict setValue:@"200" forKey:@"code"];
        [dict setValue:@"성공" forKey:@"result"];
        [dict setValue:sValue forKey:@"value"];
        
        NSString *sScriptName = [NSString stringWithFormat:@"%@('appdata', '%@');", aCallback, [dict convertJSONString]];
        NSLog(@"sScriptName is %@", sScriptName);
        [_webView callJavaScript:sScriptName];
    }
}

#pragma mark - xFrameWebViewDelegate : Play API

/**
    전화걸기
     @params aDict :
        name=홍길동
        phoneno=01012345678
 */
- (void)phonecall:(NSDictionary *)aDict
{
    _dictCurrent = aDict;
    if (aDict && ([aDict[@"telno"] isEqualToString:@""] == NO)) {
        NSString *callStr = [NSString stringWithFormat:@"tel://%@", aDict[@"telno"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callStr] options:@{}
                                completionHandler:^(BOOL success) {
            if (success == NO) {
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"전화걸기가 지원되지 않습니다.", @"message", nil];
                [self showToastMessage:dict];
            }
        }
        ];
    }
    else {
        [self showMessage:@"전화번호가 필요합니다."];
    }
}

/**
 카메라 열기
 */
- (void)openCamera
{
    [PermissionManager requestPermission:PermissionTypeCamera completionHandler:^(BOOL granted) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
                [imgPicker setDelegate:self];
                [imgPicker setAllowsEditing:YES];
                [imgPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
                [self presentViewController:imgPicker animated:YES completion:nil];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                CommonAlertView *alert = [[CommonAlertView alloc] init];
                [alert showCustomAlertView:nil
                                   title:@""
                                 message:@"카메라권한 승인이 필요합니다."
                       cancelButtonTitle:@"닫기"
                           okButtonTitle:@"권한승인"];
                alert.okClick = ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                                           options:@{}
                                                 completionHandler:^(BOOL success) {}
                         ];
                    });
                };
            });
        }
    }];
}

/**
    사운드 재생
 */
- (void)playSound:(NSString *)filename
{
    NSString *soundPath = [documentPath stringByAppendingPathComponent:filename];
    if (filename && [[NSFileManager defaultManager] fileExistsAtPath:soundPath]) {
        SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundPath], &soundID);
        AudioServicesPlaySystemSound (soundID);
    }
    else {
        [self showMessage:@"사운드파일이 필요합니다."];
    }
}

/**
    진동
 */
- (void)vibrate
{
    if (IS_IPAD) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"진동이 지원되지 않는 단말입니다.", @"message", nil];
        [self showToastMessage:dict];
    }
    else {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

/**
    SMS 보내기
 */
- (void)sendSMS:(NSDictionary *)dict
{
    if([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.body = dict[@"message"];
        controller.recipients = [NSArray arrayWithObjects:dict[@"telno"], nil];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
    else {
        [self showMessage:@"SMS 전송이 불가능한 디바이스입니다."];
    }
}

/**
    이메일 보내기
 */
- (void)sendEmail:(NSDictionary *)dict
{
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:dict[@"subject"]];
        [mc setMessageBody:dict[@"message"] isHTML:NO];
        [mc setToRecipients:[NSArray arrayWithObject:dict[@"mailaddr"]]];
        [self presentViewController:mc animated:YES completion:nil];
    }
    else {
        [self showMessage:@"메일 보내기를 할 수 없습니다."];
    }
}

/**
    주소록 열기
 */
- (void)openContacts
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    // above iOS 9.0
    CNContactPickerViewController *contactPicker = [CNContactPickerViewController new];
    contactPicker.delegate = self;
    [self presentViewController:contactPicker animated:YES completion:nil];
#else
    ABPeoplePickerNavigationController *addressBookController = [[ABPeoplePickerNavigationController alloc] init];
    [addressBookController setPeoplePickerDelegate:self];
    [self presentViewController:addressBookController animated:YES completion:nil];
#endif
    
}

/**
    앨범 열기
 */
- (void)openAlbum
{
    [PermissionManager requestPermission:PermissionTypeAlbum completionHandler:^(BOOL granted) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
                [imgPicker setDelegate:self];
                [imgPicker setAllowsEditing:YES];
                [imgPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                [self presentViewController:imgPicker animated:YES completion:nil];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                CommonAlertView *alert = [[CommonAlertView alloc] init];
                [alert showCustomAlertView:nil
                                   title:@""
                                 message:@"앨범사용을 위한 승인이 필요합니다."
                       cancelButtonTitle:@"닫기"
                           okButtonTitle:@"권한승인"];
                alert.okClick = ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                                           options:@{}
                                                 completionHandler:^(BOOL success) {}
                         ];
                    });
                };
            });
        }
    }];
}

#pragma mark - xFrameWebViewDelegate : 파일 API

- (void)writeFile:(NSDictionary *)dict
{
    NSString *filename = dict[@"filename"];
    NSString *contents = dict[@"data"];
    NSString *mode = dict[@"mode"];
    
    if (filename && ([filename isEqualToString:@""] == NO) && contents && ([contents isEqualToString:@""] == NO)) {
        [FileHandle writeFile:filename data:contents mode:mode];
    }
    else { // 에러
        NSLog(@"[writeFile]파라미터 오류입니다.");
    }
}

- (void)listFiles:(NSString *)aCallback
{
    NSArray *arrFiles = [FileHandle listFiles];
    
    NSMutableDictionary *dictResult = [NSMutableDictionary dictionary];
    [dictResult setValue:[NSString stringWithFormat:@"%d", 200] forKey:@"code"];
    [dictResult setValue:@"성공" forKey:@"result"];
    if (arrFiles && [arrFiles count] > 0) {
        [dictResult setValue:arrFiles forKey:@"list"];
    }
    else {
        [dictResult setValue:[NSArray array] forKey:@"list"];
    }
    
    NSString *sScriptName = [NSString stringWithFormat:@"%@('filelist', '%@');", aCallback, [dictResult convertJSONString]];
    NSLog(@"sScriptName is %@", sScriptName);
    [_webView callJavaScript:sScriptName];
}

- (void)readFile:(NSDictionary *)dict callback:(NSString *)aCallback
{
    NSString *filename = dict[@"filename"];
    
    NSMutableDictionary *dictResult = [NSMutableDictionary dictionary];
    
    if (filename && ([filename isEqualToString:@""] == NO)) {
        if ([FileHandle isFileExists:filename]) {
            NSString *sContents = [FileHandle contentsOfFile:filename];
            sContents = [sContents stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
            [dictResult setValue:[NSString stringWithFormat:@"%d", 200] forKey:@"code"];
            [dictResult setValue:@"성공" forKey:@"result"];
            [dictResult setValue:sContents forKey:@"data"];
        }
        else {
            [dictResult setValue:@"-200" forKey:@"code"];
            [dictResult setValue:@"파일이 존재하지 않습니다." forKey:@"result"];
        }
    }
    else { // 에러
        [dictResult setValue:@"-100" forKey:@"code"];
        [dictResult setValue:@"파라미터 오류입니다." forKey:@"result"];
    }
    
    NSString *sScriptName = [NSString stringWithFormat:@"%@('fileread', '%@');", aCallback, [dictResult convertJSONString]];
    NSLog(@"sScriptName is %@", sScriptName);
    [_webView callJavaScript:sScriptName];
}

- (void)deleteFile:(NSString *)filename callback:(NSString *)aCallback
{
    NSMutableDictionary *dictResult = [NSMutableDictionary dictionary];
    
    if ([filename isEqualToString:@""] == NO) {
        BOOL bResult = [FileHandle deleteFile:filename];
        if (bResult) {
            [dictResult setValue:@"200" forKey:@"code"];
            [dictResult setValue:@"성공입니다." forKey:@"result"];
        }
        else {
            [dictResult setValue:@"-200" forKey:@"code"];
            [dictResult setValue:@"파일삭제 오류입니다." forKey:@"result"];
        }
    }
    else {
        [dictResult setValue:@"-100" forKey:@"code"];
        [dictResult setValue:@"파라미터 오류입니다." forKey:@"result"];
    }
    
    NSString *sScriptName = [NSString stringWithFormat:@"%@('deleteFile', '%@');", aCallback, [dictResult convertJSONString]];
    NSLog(@"sScriptName is %@", sScriptName);
    [_webView callJavaScript:sScriptName];
}

- (void)fileexist:(NSDictionary *)dict callback:(NSString *)aCallback
{
    NSMutableDictionary *dictResult = [NSMutableDictionary dictionary];
    
    if (dict[@"filename"] && ([dict[@"filename"] isEqualToString:@""] == NO)) {
        NSString *fname = dict[@"filename"];
        if ([FileHandle isFileExists:fname]) {
            [dictResult setValue:@"200" forKey:@"code"];
            [dictResult setValue:@"성공" forKey:@"result"];
        }
        else {
            [dictResult setValue:@"-200" forKey:@"code"];
            [dictResult setValue:@"파일이 존재하지 않습니다." forKey:@"result"];
        }
    }
    else {
        [dictResult setValue:@"-100" forKey:@"code"];
        [dictResult setValue:@"파라미터오류입니다." forKey:@"result"];
    }
    
    NSString *sScriptName = [NSString stringWithFormat:@"%@('fileexist', '%@');", aCallback, [dictResult convertJSONString]];
    NSLog(@"sScriptName is %@", sScriptName);
    [_webView callJavaScript:sScriptName];
}

- (void)filesize:(NSDictionary *)dict callback:(NSString *)aCallback
{
    NSMutableDictionary *dictResult = [NSMutableDictionary dictionary];
    
    if (dict[@"filename"] && ([dict[@"filename"] isEqualToString:@""] == NO)) {
        NSString *fname = dict[@"filename"];
        if ([FileHandle isFileExists:fname]) {
            [dictResult setValue:@"200" forKey:@"code"];
            [dictResult setValue:@"성공" forKey:@"result"];
            [dictResult setValue:[FileHandle getFilesize:fname] forKey:@"size"];
        }
        else {
            [dictResult setValue:@"-200" forKey:@"code"];
            [dictResult setValue:@"파일이 존재하지 않습니다." forKey:@"result"];
        }
    }
    else {
        [dictResult setValue:@"-100" forKey:@"code"];
        [dictResult setValue:@"파라미터오류입니다." forKey:@"result"];
    }
    
    NSString *sScriptName = [NSString stringWithFormat:@"%@('filesize', '%@');", aCallback, [dictResult convertJSONString]];
    NSLog(@"sScriptName is %@", sScriptName);
    [_webView callJavaScript:sScriptName];
}

- (void)filetime:(NSDictionary *)dict callback:(NSString *)aCallback
{
    NSMutableDictionary *dictResult = [NSMutableDictionary dictionary];
    
    if (dict[@"filename"] && ([dict[@"filename"] isEqualToString:@""] == NO)) {
        NSString *fname = dict[@"filename"];
        if ([FileHandle isFileExists:fname]) {
            
            NSDate *fDate = [FileHandle getFileTime:fname];
            [dictResult setValue:@"200" forKey:@"code"];
            [dictResult setValue:@"성공" forKey:@"result"];
            [dictResult setValue:[fDate yyyymmdd] forKey:@"date"];
            [dictResult setValue:[fDate hhmmss] forKey:@"time"];
        }
        else {
            [dictResult setValue:@"-200" forKey:@"code"];
            [dictResult setValue:@"파일이 존재하지 않습니다." forKey:@"result"];
        }
    }
    else {
        [dictResult setValue:@"-100" forKey:@"code"];
        [dictResult setValue:@"파라미터오류입니다." forKey:@"result"];
    }
    
    NSString *sScriptName = [NSString stringWithFormat:@"%@('filetime', '%@');", aCallback, [dictResult convertJSONString]];
    NSLog(@"sScriptName is %@", sScriptName);
    [_webView callJavaScript:sScriptName];
}

#pragma mark - xFrame5WebViewDelegate 로그 API

- (void)logStart
{
    _currentDebugType = DebugTypeStart;
}

- (void)logStop
{
    _currentDebugType = DebugTypeStop;
}

- (void)logSetLevel:(NSDictionary *)dict
{
    if (dict && dict[@"level"] && ([dict[@"level"] isEqualToString:@""] == NO)) {
        _logWriter.nLogLevel = [LogLevels indexOfObject:dict[@"level"]];
    }
}

- (void)logView:(NSDictionary *)dict
{
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.softbase.xFrame5"];
    
    NSLog(@"logview is %@", dict);
    
    if (dict && ([dict[@"filename"] isEqualToString:@""] == NO) ) {
    
        NSString *sContents = [_logWriter contentsOfFile:dict[@"filename"]];
        
        LogViewController *controller = [[LogViewController alloc] initWithNibName:@"LogViewController" bundle:bundle];
        controller.sDatas = sContents;
        UINavigationController *nav  = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:nav animated:YES completion:nil];
    }
    else {
        
        LogListViewController *controller = [[LogListViewController alloc] initWithNibName:@"LogListViewController" bundle:bundle];
        UINavigationController *nav  = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:nav animated:YES completion:nil];
    }
    
}

- (void)logWrite:(NSString *)sLevel data:(NSString *)sContents
{
    if (_currentDebugType == DebugTypeStop) {
        
        [self showToastMessage:[NSDictionary dictionaryWithObjectsAndKeys:@"로그 중지상태입니다.", @"message", nil]];
    }
    else if (_currentDebugType == DebugTypeNone) {
        
        [self showToastMessage:[NSDictionary dictionaryWithObjectsAndKeys:@"로그 시작상태가 아닙니다.", @"message", nil]];
    }
    else {
        NSInteger nLevel = [LogLevels indexOfObject:sLevel];
        if (nLevel >= _logWriter.nLogLevel) {
            
            NSString *logFilename = [LogHandle todayLogFilename];
            _logWriter.logFileName = logFilename;
            [_logWriter logWrite:sContents level:sLevel];
        }
        else {
            [self showToastMessage:[NSDictionary dictionaryWithObjectsAndKeys:@"로그레벨 오류입니다.", @"message", nil]];
        }
    }
}

- (void)loginfo:(NSString *)callback
{
    NSString *logLevel = [LogLevels objectAtIndex:_logWriter.nLogLevel];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"200" forKey:@"code"];
    [dict setValue:@"성공" forKey:@"result"];
    [dict setValue:logLevel forKey:@"level"];
    [dict setValue:[LogHandle todayLogFilename] forKey:@"filename"];
    [dict setValue:[NSString stringWithFormat:@"%d", (int)_currentDebugType] forKey:@"status"];
    
    NSString *sScriptName = [NSString stringWithFormat:@"%@('loginfo', '%@');", callback, [dict convertJSONString]];
    NSLog(@"sScriptName is %@", sScriptName);
    [_webView callJavaScript:sScriptName];
}


#pragma mark - xFrame5WebViewDelegate 기타

/**
 설정화면 로드
 */
- (void)openSettingView
{
    //NSBundle *bundle = [NSBundle bundleWithIdentifier:kFramworkBundle];
    
    SettingViewController *controller = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)readNFCTag:(NSString *)callback
{
    [self showMessage:@"NFC기능은 현재 지원되지 않습니다."];
}

- (void)qrcode:(NSString *)callback
{
//    DYQRCodeDecoderViewController *vc = [[DYQRCodeDecoderViewController alloc] initWithCompletion:^(BOOL succeeded, NSString *result) {
//        if (succeeded) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//                [dict setValue:@"200" forKey:@"code"];
//                [dict setValue:@"성공" forKey:@"result"];
//                [dict setValue:result forKey:@"value"];
//
//                NSString *sScriptName = [NSString stringWithFormat:@"%@('qrcode', '%@');", callback, [dict convertJSONString]];
//                [self->_webView callJavaScript:sScriptName];
//            });
//        } else {
//            [self showMessage:@"QR코드 인식에 실패하였습니다."];
//        }
//    }];
//
//    [[vc rightBarButtonItem] setTitle:@""];
//    [[vc leftBarButtonItem] setTitle:@"닫기"];
//
//    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:NULL];
}

- (void)sendPushToken:(NSDictionary *)dict callback:(NSString *)aCallback
{
    [self showMessage:@"Push 기능은 현재 지원되지 않습니다."];
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    
    CLLocation *curLocation = [locations lastObject];
    
    NSString *lat = [NSString stringWithFormat:@"%lf", curLocation.coordinate.latitude];
    NSString *lon = [NSString stringWithFormat:@"%lf", curLocation.coordinate.longitude];
    
    //{"code":200, "lat":"37.4824922", "lon":"126.8921247"}

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"200" forKey:@"code"];
    [dict setValue:@"성공" forKey:@"result"];
    [dict setValue:lat forKey:@"latitude"];
    [dict setValue:lon forKey:@"longitude"];
    
    NSString *sScriptName = [NSString stringWithFormat:@"%@('infogeo', '%@');", _locationCallback, [dict convertJSONString]];
    NSLog(@"sScriptName is %@", sScriptName);
    [_webView callJavaScript:sScriptName];
    
    [_updateView removeFromSuperview];
    [_dimmedView removeFromSuperview];
    
    _updateView = nil;
    _dimmedView = nil;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultSent:
            break;
        case MessageComposeResultFailed:
            break;
        default:
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (error) {
      
    }
    else {
        switch (result) {
            case MFMailComposeResultCancelled:
                break;
            case MFMailComposeResultSaved:
                break;
            case MFMailComposeResultSent:
                break;
            case MFMailComposeResultFailed:
                break;
            default:
                break;
        }
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person
{
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - LongTouch Gesture

- (void)didTouchLongPress:(UIGestureRecognizer *)gesture
{
    NSString *jsName = _dictUserFunction[@"longclick"];

    // jsName이 존재하는 경우에만.....
    if (jsName && ([jsName isEqualToString:@""] == NO)) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"200" forKey:@"code"];
        [dict setValue:@"success" forKey:@"message"];
        
        NSString *sScriptName = [NSString stringWithFormat:@"%@('longclick', '%@');", jsName, [dict convertJSONString]];
        NSLog(@"sScriptName is %@", sScriptName);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_webView callJavaScript:sScriptName];
        });
    }
}

#pragma mark - init

- (void)initSetUp
{
    // Notification 등록
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(detectOrientation)
                                                 name:@"UIDeviceOrientationDidChangeNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(LogInfoChangeNotification)
                                                 name:@"LogInfoChangeNotification"
                                               object:nil];
    
    // 지원되는 함수 목록 설정
    _dictUserFunction = [NSMutableDictionary dictionary];
    
    // 공유 데이터 저장을 위한 변수
    _dictSharedData = [NSMutableDictionary dictionary];
    
    // 로그클래스 생성
    _logWriter = [[LogHandle alloc] init];
    _logWriter.nLogLevel = 0;
}

- (NSString *)getStartUrl
{
    NSDictionary *dict = [UserDefaults objectForKey:@"xFrame5"];
    if (dict && dict[@"START_PAGE"]) {
        return dict[@"START_PAGE"];
    }
    else return @"";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:YES];
    
    _currentDebugType = DebugTypeStart;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initSetUp];
    
    CGFloat xPos = 0;
    CGFloat yPos = 0; //StartY;
    
    _webView = [[xFrame5WebView alloc] initWithFrame:CGRectMake(xPos, yPos, kScreenBoundsWidth, kScreenBoundsHeight-yPos)];
    _webView.xFrameDelegate = self;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_webView];

    NSString *sUrl = [self getStartUrl];
    NSLog(@"Start Page is %@", sUrl);
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sUrl]]];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchLongPress:)];
    [_webView addGestureRecognizer:longPress];
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
   [super viewDidAppear:animated];
   [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
 }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if(event.type == UIEventSubtypeMotionShake) {
        NSLog(@"shake...");
        NSLog(@"call openSettingView..");
        [self openSettingView];
    }
}

@end
