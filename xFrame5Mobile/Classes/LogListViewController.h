//
//  LogListViewController.h
//  xFrame5
//
//  Created by HanSanghong on 2016. 8. 25..
//  Copyright © 2016년 softbase. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogListViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITableView *tblView;

- (IBAction)btnClosePress:(id)sender;

@end
