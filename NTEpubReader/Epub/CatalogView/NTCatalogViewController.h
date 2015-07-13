//
//  NTCatalogViewController.h
//  NTCoreTextReader
//
//  Created by liying on 14-7-4.
//  Copyright (c) 2014年 liying. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NTCatalogViewController;

@protocol NTCatalogViewControllerDelegate

@required

-(void)openTheViewPage:(NSMutableDictionary *)pageInfo;

@end




@interface NTCatalogViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *catalogTable;

@property (nonatomic, strong) NSMutableArray *catalogArray;

@property (nonatomic, weak) id delegate;

@end
