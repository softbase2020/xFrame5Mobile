//
//  MainViewController.h
//  appbuilder
//
//  Created by HanSanghong on 2016. 6. 20..
//  Copyright © 2016년 directionsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MainViewController : UIViewController

@property (nonatomic, strong) CLLocationManager *locationManager;

- (void)setNetworkType:(NSString *)networkType;
- (void)setApplicationState:(UIApplicationState)state;
- (void)openSettingView;

@end
