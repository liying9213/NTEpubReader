//
//  NTChangeAttributedString.m
//  NTCoreTextReader
//
//  Created by liying on 14-6-28.
//  Copyright (c) 2014年 liying. All rights reserved.
//

#import "NTChangeAttributedString.h"
#import <UIKit/UIKit.h>
@implementation NTChangeAttributedString

+(NSMutableAttributedString *)ChangeTheString:(NSString *)str
{
    NSMutableAttributedString *_htmlStr=[[NSMutableAttributedString alloc] initWithString:str];
    NSRange editRg = NSMakeRange(0, _htmlStr.length);
    [_htmlStr addAttribute:(id)NSFontAttributeName value:(id)[UIFont systemFontOfSize:17.0f] range:editRg];
    CGFloat lineSp = 8.5f; //行间距
    NSMutableParagraphStyle *paragStyle = [[NSMutableParagraphStyle alloc] init];
    [paragStyle setLineSpacing:lineSp];
    [paragStyle setAlignment:NSTextAlignmentLeft]; //对齐，其他属性看NSMutableParagraphStyle
    [_htmlStr addAttribute:NSParagraphStyleAttributeName value:(id)paragStyle range:editRg];
    return _htmlStr;
}

@end
