//
//  CommonAlertView.h
//  Elandmall
//
//  Created by 한상홍 on 2016. 1. 19..
//  Copyright © 2016년 pionnet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CommonAlertViewButtonIndex) {
    CommonAlertViewOKButtonIndex = 1000,     // 확인 버튼
    CommonAlertViewCancelButtonIndex      // 취소 버튼
};

@class CommonAlertView;

@protocol CommonAlertViewDelegate <NSObject>

- (void)alertView:(CommonAlertView *_Nonnull)alertView buttonIndex:(NSInteger)buttonIndex;

@end

@interface CommonAlertView : UIView

@property (nonatomic, assign) id<CommonAlertViewDelegate> _Nullable delegate;

- (void)removeAlertView;
- (void)showCustomAlertView:(id _Nullable )sender title:(NSString *_Nullable)title message:(NSString *_Nullable)message cancelButtonTitle:(nullable NSString *)buttonCancel okButtonTitle:(nullable NSString *)buttonOK;

@property (nonatomic, copy) void(^ _Nullable okClick)(void);
@property (nonatomic, copy) void(^ _Nullable cancelClick)(void);

@end
