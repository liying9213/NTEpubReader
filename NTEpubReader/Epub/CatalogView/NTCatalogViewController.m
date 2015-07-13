//
//  NTCatalogViewController.m
//  NTCoreTextReader
//
//  Created by liying on 14-7-4.
//  Copyright (c) 2014年 liying. All rights reserved.
//

#import "NTCatalogViewController.h"
#import "NTCatalogTableViewCell.h"
#import "define.h"
#import "UIColor+MyColor.h"

@interface NTCatalogViewController ()

@end

@implementation NTCatalogViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self ReseveView];
    UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.backgroundColor=[UIColor clearColor];
    [backBtn setImage:[UIImage imageNamed:@"btn_contents_back_n.png"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"btn_contents_back_p.png"] forState:UIControlStateHighlighted];
    backBtn.frame=CGRectMake(self.view.frame.size.width-60, (self.view.frame.size.height-60)/2, 60, 60);
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)ReseveView
{
    UILabel *view=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44+20)];
    view.text=@"目 录";
    view.backgroundColor=[UIColor clearColor];
    view.textAlignment=NSTextAlignmentCenter;
    view.font=[UIFont boldSystemFontOfSize:18];
    [self.view addSubview:view];
    
    CALayer *bottomBorder = [CALayer layer];
    float height1=view.frame.size.height-0.5f;
    float width1=view.frame.size.width;
    bottomBorder.frame = CGRectMake(0.0f, height1, width1, 0.5f);
    bottomBorder.backgroundColor =CELL_LINE_COLOR.CGColor;
    [view.layer addSublayer:bottomBorder];
    
    _catalogTable = [[UITableView alloc] initWithFrame:CGRectMake(0, view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-44-20) style:UITableViewStylePlain];
    _catalogTable.backgroundColor = [UIColor clearColor];
    _catalogTable.showsHorizontalScrollIndicator = YES;
    _catalogTable.showsVerticalScrollIndicator = YES;
    _catalogTable.scrollEnabled = YES;
    _catalogTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _catalogTable.rowHeight=50;
    _catalogTable.delegate = self;
    _catalogTable.dataSource = self;
    [self.view addSubview:_catalogTable];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _catalogArray.count;
}

-(NTCatalogTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    tableView.separatorStyle=UITableViewCellSelectionStyleNone;
    static NSString * _cellIdentify = @"cell";
    NTCatalogTableViewCell * iCell = [tableView dequeueReusableCellWithIdentifier:_cellIdentify];
    iCell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (iCell == nil)
    {
        iCell = [[NTCatalogTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_cellIdentify];
    }
    iCell.titleLabel.text=[NSString stringWithFormat:@"%@",[[_catalogArray objectAtIndex:indexPath.row] objectForKey:@"title"]];
    int Tier=[[[_catalogArray objectAtIndex:indexPath.row] objectForKey:@"catalogTier"] intValue];
    iCell.titleLabel.font=[UIFont systemFontOfSize:16-Tier*1];
    CGRect rect=CGRectMake(15, 0, 250, 50);
    rect.origin.x+=Tier*12;
    rect.size.width-=Tier*12;
    iCell.titleLabel.frame=rect;
    iCell.pageLabel.text=[NSString stringWithFormat:@"%d",[[[_catalogArray objectAtIndex:indexPath.row] objectForKey:@"localPoint"] intValue]+1];
    
    return iCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self back];
    [_delegate openTheViewPage:[_catalogArray objectAtIndex:indexPath.row]];
}
-(void)back
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.type =kCATransitionPush;
    transition.subtype =kCATransitionFromRight;
    [self.view.layer addAnimation:transition forKey:@"animation"];
    self.view.hidden=YES;
//    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
