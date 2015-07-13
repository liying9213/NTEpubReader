//
//  NTCatalogTableViewCell.m
//  NTCoreTextReader
//
//  Created by liying on 14-7-18.
//  Copyright (c) 2014年 liying. All rights reserved.
//

#import "NTCatalogTableViewCell.h"
#import "UIColor+MyColor.h"
#import "define.h"
@implementation NTCatalogTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(15, 0, MainWidth-70, 50)];
        _titleLabel.backgroundColor=[UIColor clearColor];
        _titleLabel.numberOfLines=0;
        _titleLabel.lineBreakMode=NSLineBreakByWordWrapping;
        _titleLabel.textColor=[UIColor blackColor];
        _titleLabel.textAlignment=NSTextAlignmentLeft;
        [self.contentView addSubview:_titleLabel];
        
        _pageLabel=[[UILabel alloc] initWithFrame:CGRectMake(MainWidth-50, 0, 40, 50)];
        _pageLabel.backgroundColor=[UIColor clearColor];
        _pageLabel.textColor=[UIColor grayColor];
        _pageLabel.textAlignment=NSTextAlignmentRight;
        _pageLabel.font=[UIFont systemFontOfSize:15];
        [self.contentView addSubview:_pageLabel];
        _lineView=[[UIView alloc] initWithFrame:CGRectMake(15, _pageLabel.frame.size.height+_pageLabel.frame.origin.y-0.5, MainWidth-30, 0.5)];
        _lineView.backgroundColor = CELL_LINE_COLOR;
        [self.contentView addSubview:_lineView];
//        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
//        self.selectedBackgroundView.backgroundColor = [UIColor colorWithHexString:cellSelectColor];
        self.contentView.backgroundColor=[UIColor colorWithHexString:@"#F6F6EE"];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
