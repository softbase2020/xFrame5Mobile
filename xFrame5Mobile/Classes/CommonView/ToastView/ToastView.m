//
//  ToastView.m
//  xFrame5
//
//  Created by HanSanghong on 2016. 8. 9..
//  Copyright © 2016년 softbase. All rights reserved.
//

#import "ToastView.h"
#import "xFrame5Define.h"

#define kToastViewBottomGap         50
#define kToastViewTextGap           10
#define kToastViewDisplayTime       3

@interface ToastView()
{
    UILabel     *_msgLabel;
    NSTimer     *_showTimer;
}
@end

@implementation ToastView

#pragma mark - Property set

- (void)setToastMsg:(NSString *)toastMsg
{
    _toastMsg = toastMsg;
    _msgLabel.text = toastMsg;
    
    CGFloat nWidth = kScreenBoundsWidth - 40;
    
    CGRect curFrame = [_msgLabel textRectForBounds:CGRectMake(0, 0, nWidth, 100) limitedToNumberOfLines:0];
    
    CGFloat xPos = (kScreenBoundsWidth - curFrame.size.width - 20) / 2;
    CGFloat yPos = (kScreenBoundsHeight - curFrame.size.height - 10 - kToastViewBottomGap);
    
    self.frame = CGRectMake(xPos, yPos, curFrame.size.width+20, curFrame.size.height+10);

    _msgLabel.frame = CGRectMake(10, 5, curFrame.size.width, curFrame.size.height);
}

#pragma mark - Private Function

- (void)hideToast
{
    [self removeFromSuperview];
}

#pragma mark - Public Method

- (void)showToastWithTime:(float)nDuration
{
    self.hidden = _msgLabel.hidden = NO;
    
    _showTimer = [NSTimer scheduledTimerWithTimeInterval:nDuration target:self selector:@selector(hideToast) userInfo:nil repeats:NO];
}

- (void)showToast
{
    self.hidden = _msgLabel.hidden = NO;
    
    _showTimer = [NSTimer scheduledTimerWithTimeInterval:kToastViewDisplayTime target:self selector:@selector(hideToast) userInfo:nil repeats:NO];
}

#pragma mark - init

- (id)init
{
    self = [super init];
    if (self) {
        
        self.hidden = YES;
        
        self.backgroundColor = [UIColor lightGrayColor];
        self.layer.cornerRadius = 5.f;
        self.clipsToBounds = YES;
        
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _msgLabel.font = [UIFont systemFontOfSize:13.f];
        _msgLabel.backgroundColor = [UIColor clearColor];
        _msgLabel.textColor = [UIColor whiteColor];
        _msgLabel.hidden = YES;
        _msgLabel.numberOfLines = 0;
        [self addSubview:_msgLabel];
    }
    
    return self;
}

@end
