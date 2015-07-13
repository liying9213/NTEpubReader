//
//  NTBackView.m
//  MPlatform
//
//  Created by 李莹 on 14-8-18.
//
//

#import "NTBackView.h"

@implementation NTBackView

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
    _backButton =[UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame=CGRectMake(10, 25, 60, 60);
    [_backButton setImage:[UIImage imageNamed:@"btn_pages_back_n.png"] forState:UIControlStateNormal];
    [self addSubview:_backButton];
    
    _SearchButton =[UIButton buttonWithType:UIButtonTypeCustom];
    _SearchButton.frame=CGRectMake(self.frame.size.width-70, 25, 60, 60);
    [_SearchButton setImage:[UIImage imageNamed:@"btn_pages_search_n.png"] forState:UIControlStateNormal];
    [self addSubview:_SearchButton];
}

@end
