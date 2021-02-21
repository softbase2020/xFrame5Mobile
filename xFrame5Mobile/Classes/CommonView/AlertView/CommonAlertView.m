//
//  CommonAlertView.h
//  Elandmall
//
//  Created by 한상홍 on 2016. 1. 19..
//  Copyright © 2016년 pionnet. All rights reserved.
//

#import "CommonAlertView.h"
#import "xFrame5Mobile.h"

#define kAlertViewSize      290
#define kAlertDuration      0.3f

@interface CommonAlertView()
{
}

@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnOK;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnOKLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertTopLeading;

@end

@implementation CommonAlertView

#pragma mark - private

- (void)removeAlertView
{
    [UIView animateWithDuration:kAlertDuration
                     animations:^{
                         self.alpha = 0.f;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }
     ];
}

#pragma mark - Event

- (IBAction)btnCancelPress:(id)sender {
    
    [self removeAlertView];
    
    if (self.cancelClick) {
        self.cancelClick();
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:buttonIndex:)]) {
            [self removeAlertView];
            [self.delegate alertView:self buttonIndex:CommonAlertViewCancelButtonIndex];
        }
    }
}

- (IBAction)btnOKPress:(id)sender {
    [self removeAlertView];
    
    if (self.okClick) {
        self.okClick();
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:buttonIndex:)]) {
            [self.delegate alertView:self buttonIndex:CommonAlertViewOKButtonIndex];
        }
    }
}

#pragma mark -

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSBundle *ltBundle = [NSBundle bundleWithIdentifier:kFramworkBundle];
        NSString *className = NSStringFromClass([self class]);
        UIView *v = [[ltBundle loadNibNamed:className owner:self options:nil] firstObject];
        v.frame = self.bounds;
        [self addSubview:v];
    }
    
    return self;
}

- (void)setButton:(NSString *)cancelButtonName okButton:(NSString *)okButtonName
{
    if (cancelButtonName) {
        self.buttonWidth.constant = (kAlertViewSize - 100) / 2.f;;
        self.btnOKLeading.constant = 40;
        [self.btnCancel setTitle:cancelButtonName forState:UIControlStateNormal];
        self.btnCancel.hidden = YES;
    }
    else {
        self.btnCancel.hidden = YES;
        self.buttonWidth.constant = 0;
        self.btnOKLeading.constant = 0;
    }
    
    [self.btnOK setTitle:okButtonName forState:UIControlStateNormal];
    
    self.alertLeading.constant = (self.frame.size.width - 290)/2.f;
    self.alertTopLeading.constant = 250;
}

- (void)showCustomAlertView:(id)sender title:(NSString *)title message:(NSString *)message cancelButtonTitle:(nullable NSString *)buttonCancel okButtonTitle:(NSString *)buttonOK
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    self.frame = window.bounds;
    [window addSubview:self];
    
    self.titleLabel.text = title;
    self.messageLabel.text = message;
    
    self.alertView.layer.cornerRadius = 10.f;
    
    if (buttonCancel) {
        self.buttonWidth.constant = (kAlertViewSize - 100) / 2.f;;
        self.btnOKLeading.constant = 40;
        [self.btnCancel setTitle:buttonCancel forState:UIControlStateNormal];
        self.btnCancel.hidden = NO;
        self.btnCancel.layer.cornerRadius = 5.f;
    }
    else {
        self.btnCancel.hidden = YES;
        self.buttonWidth.constant = 0;
        self.btnOKLeading.constant = 0;
    }
    
    self.btnOK.layer.cornerRadius = 5.f;
    [self.btnOK setTitle:buttonOK forState:UIControlStateNormal];
    
    self.alertLeading.constant = (self.frame.size.width - 290)/2.f;
    self.alertTopLeading.constant = (self.frame.size.height - self.alertView.frame.size.height)/2.f;
    
    self.delegate = sender;
}

@end
