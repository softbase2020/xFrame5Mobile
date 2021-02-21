//
//  SettingViewController.h
//  xFrame5
//
//  Created by HanSanghong on 2016. 7. 28..
//  Copyright © 2016년 softbase. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIView                 *headerView;
@property (nonatomic, weak) IBOutlet UIView                 *mainView;
@property (nonatomic, weak) IBOutlet UITextField            *txtStartPage;


- (IBAction)btnClosePress:(id)sender;
- (IBAction)btnApplyPress:(id)sender;

@end
