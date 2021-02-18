//
//  xFrame5Delegate.h
//  xFrame5
//
//  Created by HanSanghong on 2016. 6. 20..
//  Copyright © 2016년 directionsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface xFrame5Delegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow          *window;
@property (nonatomic, strong) NSString          *networkType;

- (NSString *)getNetworkStatus;
- (void)AppExit;

@end
