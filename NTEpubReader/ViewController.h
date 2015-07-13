//
//  ViewController.h
//  NTEpubReader
//
//  Created by 李莹 on 15/7/13.
//  Copyright (c) 2015年 NT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *epubData;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)reloadTable:(id)sender;

@end

