//
//  LogViewController.h
//  xFrame5
//
//  Created by HanSanghong on 2016. 8. 21..
//  Copyright © 2016년 softbase. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextView     *txtLogView;

@property (nonatomic, strong) NSString  *sDatas;

- (IBAction)btnClosePress:(id)sender;

@end
