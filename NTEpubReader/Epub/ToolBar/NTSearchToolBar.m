//
//  NTSearchToolBar.m
//  MPlatform
//
//  Created by 李莹 on 15/1/8.
//
//

#import "NTSearchToolBar.h"

@implementation NTSearchToolBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(void)ResetView
{
    _UpPageButton =[UIButton buttonWithType:UIButtonTypeCustom];
    _UpPageButton.frame=CGRectMake(0, 0, 60, 60);
    [_UpPageButton setImage:[UIImage imageNamed:@"search_prev.png"] forState:UIControlStateNormal];
    [self addSubview:_UpPageButton];
    
    _SearchButton =[UIButton buttonWithType:UIButtonTypeCustom];
    _SearchButton.frame=CGRectMake(70, 0, 60, 60);
    [_SearchButton setImage:[UIImage imageNamed:@"btn_pages_search_n.png"] forState:UIControlStateNormal];
    [self addSubview:_SearchButton];
    
    _NextPageButton =[UIButton buttonWithType:UIButtonTypeCustom];
    _NextPageButton.frame=CGRectMake(140, 0, 60, 60);
    [_NextPageButton setImage:[UIImage imageNamed:@"search_next.png"] forState:UIControlStateNormal];
    [self addSubview:_NextPageButton];
}


@end
