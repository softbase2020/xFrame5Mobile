//
//  LogViewController.m
//  xFrame5
//
//  Created by HanSanghong on 2016. 8. 21..
//  Copyright © 2016년 softbase. All rights reserved.
//

#import "LogViewController.h"

@interface LogViewController ()

@end

@implementation LogViewController

- (IBAction)btnClosePress:(id)sender
{
    int nCount = (int)[[self.navigationController viewControllers] count];
    if (nCount == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController setNavigationBarHidden:YES];
    
    self.txtLogView.text = self.sDatas;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
