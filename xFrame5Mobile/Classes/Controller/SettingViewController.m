//
//  SettingViewController.m
//  xFrame5
//
//  Created by HanSanghong on 2016. 7. 28..
//  Copyright © 2016년 softbase. All rights reserved.
//

#import "SettingViewController.h"

#import "xFrame5Mobile.h"
#import "CommonAlertView.h"

@interface SettingViewController ()
{
    
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topContraints;

@end

@implementation SettingViewController

#pragma mark - Private Function

- (void)saveChanges
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setValue:self.txtStartPage.text forKey:@"START_PAGE"];
    [UserDefaults setValue:dict forKey:@"xFrame5"];
    [UserDefaults synchronize];
    
    [xFrameAppDelegate AppExit];
}

#pragma mark - IBAction Method

- (IBAction)btnClosePress:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnApplyPress:(id)sender
{
    [self.txtStartPage resignFirstResponder];
    
    CommonAlertView *alert = [[CommonAlertView alloc] init];
      [alert showCustomAlertView:nil
                           title:@""
                         message:@"적용되었습니다.\n앱을 다시 실행해야 적용됩니다."
               cancelButtonTitle:@"취소"
                   okButtonTitle:@"확인"];
      alert.okClick = ^{
          [self saveChanges];
      };
}

#pragma mark - init

- (void)loadSettingData
{
    NSDictionary *dict =  [UserDefaults objectForKey:@"xFrame5"];
    self.txtStartPage.text = dict[@"START_PAGE"] ? dict[@"START_PAGE"] : @"";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.topContraints.constant = StartY;
    [self loadSettingData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
