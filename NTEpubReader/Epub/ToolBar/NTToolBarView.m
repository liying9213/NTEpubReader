//
//  NTToolBarView.m
//  NTCoreTextReader
//
//  Created by liying on 14-6-29.
//  Copyright (c) 2014年 liying. All rights reserved.
//

#import "NTToolBarView.h"

@implementation NTToolBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)ResetView
{
    _menuButton =[UIButton buttonWithType:UIButtonTypeCustom];
    _menuButton.frame=CGRectMake(10, 0, 60, 60);
    [_menuButton setImage:[UIImage imageNamed:@"btn_pages_contents_n.png"] forState:UIControlStateNormal];
    [self addSubview:_menuButton];
}

@end
