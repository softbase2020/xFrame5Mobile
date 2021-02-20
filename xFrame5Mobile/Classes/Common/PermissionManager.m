//
//  PermissionManager.m
//  Common
//
//  Created by Tommy Kim on 2019. 1. 22..
//  Copyright directionsoft. All rights reserved.
//

#import "PermissionManager.h"
#import <UIKit/UIApplication.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <Contacts/Contacts.h>
#import <EventKit/EKEventStore.h>
#import <Photos/Photos.h>
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>

static PermissionManager *_permisionManager = nil;

@interface PermissionManager ()

@property (nonatomic, copy) void(^locationCallback)(BOOL granted);

@end

@implementation PermissionManager

- (instancetype)init {
    self = [super init];
    if (self) {
//        self.locationManager = CLLocationManager.new;
//        self.locationManager.delegate = self;
    }
    return self;
}

+ (PermissionManager *)sharedInstance{
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _permisionManager = PermissionManager.new;
    });
    
    return _permisionManager;
}

+ (PermissionState)getPermissionState:(PermissionTypes)type {
    
    if (type == PermissionTypeMic) {
        return ([AVAudioSession sharedInstance].recordPermission == AVAudioSessionRecordPermissionGranted) ? PermissionStateAgree : PermissionStatedisAgree;
    }
    else if (type == PermissionTypeAlbum) {
        return ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) ? PermissionStateAgree : PermissionStatedisAgree;
    }
    else if (type == PermissionTypeCamera) {
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        return (status == AVAuthorizationStatusAuthorized) ? PermissionStateAgree : PermissionStatedisAgree;
    }
//    else if(type == PermissionTypeContact) {
//        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
//        return (status == CNAuthorizationStatusAuthorized) ? PermissionStateAgree : PermissionStatedisAgree;
//    }
//    else if(type == PermissionTypeCalendar) {
//        EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
//        return (status == EKAuthorizationStatusAuthorized) ? PermissionStateAgree : PermissionStatedisAgree;
//    }
//    else if(type == PermissionTypeLocation) {
//        if([CLLocationManager locationServicesEnabled] &&
//           [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
//            return PermissionStateAgree;
//        }
//    }
    else if(type == PermissionTypeBioId) {
        NSError *authError = nil;
        LAContext *bioContext = LAContext.new;
        if ([bioContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
            return PermissionStateAgree;
        } else {
            NSLog(@"error=%@", authError);
        }
    }
    
    return PermissionStatedisAgree;
}

+ (void)requestPermission:(PermissionTypes)type completionHandler:(void(^)(BOOL granted))completionHandler {
    if (!completionHandler) {
        return;
    }
    
    if (type == PermissionTypeCamera) {
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if (status == AVAuthorizationStatusAuthorized) {
            completionHandler(YES);
        } else {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                completionHandler(granted);
            }];
        }
    }
    else if (type == PermissionTypeAlbum) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusAuthorized) {
            completionHandler(YES);
        }
        else {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                completionHandler(status == PHAuthorizationStatusAuthorized);
            }];
        }
    }
    else if (type == PermissionTypeMic) {
        if ([AVAudioSession sharedInstance].recordPermission == AVAudioSessionRecordPermissionGranted) {
            completionHandler(YES);
        }
        else { 
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                completionHandler(granted);
            }];
        }
    }
//    else if (type == PermissionTypeContact) {
//        CNContactStore *contactStore = CNContactStore.new;
//        if (contactStore) {
//            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
//                completionHandler(granted);
//            }];
//        } else {
//            completionHandler(NO);
//        }
//    }
//    else if (type == PermissionTypeCalendar) {
//        EKEventStore *eventStore = EKEventStore.new;
//        if (eventStore) {
//            [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
//                completionHandler(granted);
//            }];
//        } else {
//            completionHandler(NO);
//        }
//    }
//    else if (type == PermissionTypeLocation) {
//        PermissionManager *manager = [PermissionManager sharedInstance];
//        [manager.locationManager requestAlwaysAuthorization];
//        manager.locationCallback = ^(BOOL granted) {
//            completionHandler(granted);
//        };
//    }
    else if (type == PermissionTypeBioId) {
        NSError *authError = nil;
        LAContext *bioContext = LAContext.new;
        if ([bioContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
            [bioContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"" reply:^(BOOL success, NSError * _Nullable error) {
                completionHandler(success);
            }];
            
        } else {
            completionHandler(NO);
        }
    }
}

// 생체 인증은 필요한 내용을 추가하여 사용
// 참고: https://codeburst.io/biometric-authentication-using-swift-bb2a1241f2be
//
+ (void)tryBiometricsAuthentication:(NSString*)localizedReason success:(void (^)(void))callback fail:(void (^)(NSInteger))failCallback {
    LAContext *myContext = LAContext.new;
    //myContext.localizedFallbackTitle = @""; //인식실패할 때 뜨는 팝업창의 오른쪽 암호입력 버튼제거.
    NSError *authError = nil;
    
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:localizedReason
                            reply:^(BOOL success, NSError *error) {
                                if (success) {
                                    if (callback) {
                                        callback();
                                    }
                                } else {
                                    if (failCallback) {
                                        failCallback(error.code);
                                    }
                                }
                            }];
    } else {
        if (failCallback) {
            failCallback(LAErrorAuthenticationFailed);
        }
    }
}

#pragma mark - CLLocationManagerDelegate

//- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
//    if (status != kCLAuthorizationStatusNotDetermined) {
//        if ((status == kCLAuthorizationStatusAuthorizedAlways) || (status == kCLAuthorizationStatusAuthorizedWhenInUse)) {
//            self.locationCallback(YES);
//        } else {
//            self.locationCallback(NO);
//        }
//    }
//}

@end
