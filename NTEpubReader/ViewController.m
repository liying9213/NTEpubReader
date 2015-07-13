//
//  ViewController.m
//  NTEpubReader
//
//  Created by 李莹 on 15/7/13.
//  Copyright (c) 2015年 NT. All rights reserved.
//

#import "ViewController.h"
#import "NTEpubReadViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getTheEpubData];
    [_tableView reloadData];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_epubData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text=[_epubData objectAtIndex:indexPath.row];
    cell.textLabel.lineBreakMode=NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines=0;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *name=[[_epubData objectAtIndex:indexPath.row] stringByDeletingPathExtension];
    NTEpubReadViewController * viewController=[[NTEpubReadViewController alloc] init];
//    viewController.bookID=_bookID;
    viewController.bookName=name;
    viewController.isNeedChangeBar=YES;
    [self presentViewController:viewController animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)reloadTable:(id)sender {
    [self getTheEpubData];
    [_tableView reloadData];
}

- (void)getTheEpubData{
    _epubData=[[NSMutableArray alloc] init];
    NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *file=[NSFileManager defaultManager];
    NSArray *ary=[file contentsOfDirectoryAtPath:path error:nil];
    for (NSString *name in ary) {
        if([[name pathExtension]isEqualToString:@"epub"]){
            [_epubData addObject:name];
        }
    }
}

@end
