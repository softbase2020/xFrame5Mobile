//
//  LogListViewController.m
//  xFrame5
//
//  Created by HanSanghong on 2016. 8. 25..
//  Copyright © 2016년 softbase. All rights reserved.
//

#import "LogListViewController.h"
#import "LogViewController.h"

#import "LogHandle.h"

@interface LogListViewController () <
                                    UITableViewDelegate,
                                    UITableViewDataSource
                                    >
{
    NSArray         *_arrLogFileList;
    LogHandle       *_logger;
}

@end

@implementation LogListViewController

#pragma mark - IBAction Method

- (IBAction)btnClosePress:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_arrLogFileList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogListCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"LogListCell"];
    }
    
    cell.textLabel.text = [_arrLogFileList objectAtIndex:indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *filename = [_arrLogFileList objectAtIndex:indexPath.row];
    NSString *sContents = [_logger contentsOfFile:filename];
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.softbase.xFrame5"];
    
    LogViewController *controller = [[LogViewController alloc] initWithNibName:@"LogViewController" bundle:bundle];
    controller.sDatas = sContents;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController setNavigationBarHidden:YES];
    
    _logger = [[LogHandle alloc] init];
    _arrLogFileList = [_logger getLogFileList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
