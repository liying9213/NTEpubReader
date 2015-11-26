//
//  NTTestParser.m
//  NTCoreTextReader
//
//  Created by liying on 14-7-7.
//  Copyright (c) 2014年 liying. All rights reserved.
//

#import "NTTestParser.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>
#import "YTKKeyValueStore.h"
//static void deallocCallback( void* ref )
//{
//    (__bridge id)ref;
//}
//static CGFloat ascentCallback( void *ref )
//{
//    return [(NSString*)[(__bridge NSDictionary*)ref objectForKey:@"height"] floatValue];
//}
//
//static CGFloat descentCallback( void *ref )
//{
//    return 0;
//}
//static CGFloat widthCallback( void* ref )
//{
//    return [(NSString*)[(__bridge NSDictionary*)ref objectForKey:@"width"] floatValue];
//}
@implementation NTTestParser

-(id)initWithThe:(CGRect)frame WithTheLocalPath:(NSString *)path
{
    self=[super init];
    if (self) {
        _localPath=path;
        _NTFrame=frame;
    }
    return self;
}

-(NSMutableAttributedString *)ParserHtml:(NSString *)html withName:(NSString *)Name
{
    if ([Name isEqualToString:@"copyright.html"])
    {
        _iscopyright=YES;
    }
    int imageLength=0;
    self.images=[[NSMutableArray alloc] init];
    NSMutableAttributedString *attributedString=[[NSMutableAttributedString alloc] initWithString:@""]; //1
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];
    _CatalogArray=[[NSMutableArray alloc] init];
    _pointDic=[[NSMutableDictionary alloc] init];
    _testAry=[[NSMutableArray alloc] init];
    if (error) {
//        NSLog(@"Error: %@", error);
        return nil;
    }
    for (HTMLNode *node in [[parser body] children])
    {
        if([node.tagName isEqualToString:@"h1"])
        {
            if (!(node.className&&[node.className isEqualToString:@"singlepage"]))
            {
                [_testAry addObject:node.rawContents];
                [_CatalogArray addObject:[NSNumber numberWithUnsignedInteger:([attributedString length]-imageLength)]];
                if (node.children&&node.children.count>2)
                {
                    for (HTMLNode *inode in node.children)
                    {
                        if ([inode.tagName isEqualToString:@"sub"])
                        {
                            NSMutableAttributedString *str=[self changeString:inode.allContents AndFontSize:13 AndFontName:nil isbold:YES];
                            [attributedString appendAttributedString:str];
                            str=nil;
                        }
                        else if ([inode.tagName isEqualToString:@"sup"])
                        {
                            NSMutableAttributedString *str=[self changeString:inode.allContents AndFontSize:13 AndFontName:nil isbold:YES];
                            [str addAttribute:(NSString *)kCTSuperscriptAttributeName value:@(1) range:NSMakeRange(0, str.length)];
                            [attributedString appendAttributedString:str];
                            str=nil;
                        }
                        else if ([inode.tagName isEqualToString:@"a"]){
                        }
                        else if ([inode.tagName isEqualToString:@"br"])
                        {
                            NSMutableAttributedString *str=[[NSMutableAttributedString alloc] initWithString:@"\n "];
                            [attributedString appendAttributedString:str];
                            str=nil;
                        }
                        else
                        {
                            NSMutableAttributedString *str=[self changeString:inode.allContents AndFontSize:20 AndFontName:nil isbold:NO];
                            [attributedString appendAttributedString:str];
                            str=nil;
                        }
                    }
                }
                else
                {
                     NSMutableAttributedString *str=[self changeString:node.allContents AndFontSize:20 AndFontName:nil isbold:NO];
                    [attributedString appendAttributedString:str];
                    str=nil;
                }
            }
        }
        else if([node.tagName isEqualToString:@"h2"])
        {
            [_testAry addObject:node.rawContents];
            [_CatalogArray addObject:[NSNumber numberWithUnsignedInteger:([attributedString length]-imageLength)]];
            if (node.children&&node.children.count>2)
            {
                for (HTMLNode *inode in node.children)
                {
                    if ([inode.tagName isEqualToString:@"sub"])
                    {
                        NSMutableAttributedString *str=[self changeString:inode.allContents AndFontSize:12 AndFontName:nil isbold:NO];
                        [attributedString appendAttributedString:str];
                        str=nil;
                    }
                    else if ([inode.tagName isEqualToString:@"sup"])
                    {
                        NSMutableAttributedString *str=[self changeString:inode.allContents AndFontSize:12 AndFontName:nil isbold:NO];
                        [str addAttribute:(NSString *)kCTSuperscriptAttributeName value:@(1) range:NSMakeRange(0, str.length)];
                        [attributedString appendAttributedString:str];
                        str=nil;
                    }
                    else if ([inode.tagName isEqualToString:@"a"]){
                    }
                    else if ([inode.tagName isEqualToString:@"br"]){
                        NSMutableAttributedString *str=[[NSMutableAttributedString alloc] initWithString:@"\n "];
                        [attributedString appendAttributedString:str];
                        str=nil;
                    }
                    else
                    {
                        NSMutableAttributedString *str=[self changeString:inode.allContents AndFontSize:19 AndFontName:nil isbold:NO];
                        [attributedString appendAttributedString:str];
                        str=nil;
                    }
                }
            }
            else
            {
                NSMutableAttributedString *str=[self changeString:node.allContents AndFontSize:19 AndFontName:nil isbold:NO];
                [attributedString appendAttributedString:str];
                str=nil;
            }
        }
        else if([node.tagName isEqualToString:@"h3"])
        {
            [_testAry addObject:node.rawContents];
            [_CatalogArray addObject:[NSNumber numberWithUnsignedInteger:([attributedString length]-imageLength)]];
            if (node.children&&node.children.count>2)
            {
                for (HTMLNode *inode in node.children)
                {
                    if ([inode.tagName isEqualToString:@"sub"])
                    {
                        NSMutableAttributedString *str=[self changeString:inode.allContents AndFontSize:11 AndFontName:nil isbold:NO];
                        [attributedString appendAttributedString:str];
                        str=nil;
                    }
                    else if ([inode.tagName isEqualToString:@"sup"])
                    {
                        NSMutableAttributedString *str=[self changeString:inode.allContents AndFontSize:11 AndFontName:nil isbold:NO];
                        [str addAttribute:(NSString *)kCTSuperscriptAttributeName value:@(1) range:NSMakeRange(0, str.length)];
                        [attributedString appendAttributedString:str];
                        str=nil;
                    }
                    else if ([inode.tagName isEqualToString:@"a"]){
                    }
                    else if ([inode.tagName isEqualToString:@"br"]){
                        NSMutableAttributedString *str=[[NSMutableAttributedString alloc] initWithString:@"\n "];
                        [attributedString appendAttributedString:str];
                        str=nil;
                    }
                    else
                    {
                        NSMutableAttributedString *str=[self changeString:inode.allContents AndFontSize:18 AndFontName:nil isbold:NO];
                        [attributedString appendAttributedString:str];
                        str=nil;
                    }
                }
            }
            else
            {
                NSMutableAttributedString *str=[self changeString:node.allContents AndFontSize:18 AndFontName:nil isbold:NO];
                [attributedString appendAttributedString:str];
                str=nil;
            }
        }
        else if([node.tagName isEqualToString:@"h4"])
        {
            if (node.children&&node.children.count>1)
            {
                for (HTMLNode *inode in node.children)
                {
                    if ([inode.tagName isEqualToString:@"sub"])
                    {
                        NSMutableAttributedString *str=[self changeString:inode.allContents AndFontSize:11 AndFontName:nil isbold:NO];
                        [attributedString appendAttributedString:str];
                        str=nil;
                    }
                    else if ([inode.tagName isEqualToString:@"sup"])
                    {
                        NSMutableAttributedString *str=[self changeString:inode.allContents AndFontSize:11 AndFontName:nil isbold:NO];
                        [str addAttribute:(NSString *)kCTSuperscriptAttributeName value:@(1) range:NSMakeRange(0, str.length)];
                        [attributedString appendAttributedString:str];
                        str=nil;
                    }
                    else if ([inode.tagName isEqualToString:@"a"]){
                    }
                    else if ([inode.tagName isEqualToString:@"br"]){
                        NSMutableAttributedString *str=[[NSMutableAttributedString alloc] initWithString:@"\n "];
                        [attributedString appendAttributedString:str];
                        str=nil;
                    }
                    else
                    {
                        NSMutableAttributedString *str=[self changeString:inode.allContents AndFontSize:17 AndFontName:nil isbold:NO];
                        [attributedString appendAttributedString:str];
                        str=nil;
                    }
                }
            }
            else
            {
                NSMutableAttributedString *str=[self changeString:node.allContents AndFontSize:17 AndFontName:nil isbold:NO];
               [attributedString appendAttributedString:str];
                str=nil;
            }
        }
        else if ([node.className isEqualToString:@"center"]&&[node.rawContents rangeOfString:@"src"].location!=NSNotFound&&[node.rawContents rangeOfString:@"img"].location!=NSNotFound)
        {
            if (node.contents!=nil)
            {
                NSAttributedString *str=[self changeString:node.allContents AndFontSize:16 AndFontName:nil isbold:NO];
                [attributedString appendAttributedString:str];
                str=nil;
            }
            else
            {
                NSAttributedString *string=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"<img src=\"%@\"/>",[[node.children firstObject] getAttributeNamed:@"src"]]];
                [attributedString appendAttributedString:string];
                string=nil;
            }
        }
        else if ([node.className isEqualToString:@"singlepage"])
        {
            [_testAry addObject:node.rawContents];
            NSAttributedString *string=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"<img src=\"%@\"/>",[[node.children firstObject] getAttributeNamed:@"src"]]];
            NSMutableAttributedString *iattributedString=[[NSMutableAttributedString alloc] initWithAttributedString:string];
            [_CatalogArray addObject:[NSNumber numberWithInt:0]];
            return iattributedString;
        }
        else if ([node.className isEqualToString:@"right"]&&[[node.children firstObject] getAttributeNamed:@"src"])
        {
            NSAttributedString *string=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"<img src=\"%@\"/>",[[node.children firstObject] getAttributeNamed:@"src"]]];
            [attributedString appendAttributedString:string];
            string=nil;
        }
//        else if ([node.className isEqualToString:@"tp"])
//        {
//            [attributedString appendAttributedString:[self changeString:node.allContents AndFontSize:14 isbold:NO]];
//        }
        else if ([node.className isEqualToString:@"reference"])
        {
            NSAttributedString *str=[self changeString:node.allContents AndFontSize:13 AndFontName:nil isbold:NO];
            [attributedString appendAttributedString:str];
            str=nil;
        }
        else if ([node.className isEqualToString:@"qt"])//quote,文章引用 “高山第三部图书添加”
        {
            NSAttributedString *str=[self changeString:node.allContents AndFontSize:16 AndFontName:@"FZFSK--GBK1-0" isbold:NO];
            [attributedString appendAttributedString:str];
            str=nil;
        }
//        else if ([node.tagName isEqualToString:@"a"])
//        {
//            [attributedString appendAttributedString:[self changeString:node.allContents AndFontSize:13 isbold:NO]];
//        }
        else
        {
            if (node.children&&node.children.count>0)
            {
                if (![node.className isEqualToString:@"xsl-footnote-link"])
                {
                    for (HTMLNode *inode in node.children)
                    {
                        if ([inode.tagName isEqualToString:@"sub"])
                        {
                            NSMutableAttributedString *str=[self changeString:inode.allContents AndFontSize:11 AndFontName:nil isbold:NO];
                            [attributedString appendAttributedString:str];
                            str=nil;
                        }
                        else if ([inode.tagName isEqualToString:@"sup"])
                        {
                            NSMutableAttributedString *str=[self changeString:inode.allContents AndFontSize:11 AndFontName:nil isbold:NO];
                            [str addAttribute:(NSString *)kCTSuperscriptAttributeName value:@(1) range:NSMakeRange(0, str.length)];
                            [attributedString appendAttributedString:str];
                            str=nil;
                        }
                        else if ([inode.tagName isEqualToString:@"b"])
                        {
                            NSMutableAttributedString *str=[self changeString:inode.allContents AndFontSize:16 AndFontName:nil isbold:YES];
                            [attributedString appendAttributedString:str];
                            str=nil;
                        }
                        else if ([inode.tagName isEqualToString:@"img"]&&[[inode getAttributeNamed:@"class"] isEqualToString:@"in-line"])
                        {
                            NSString *imagePath=[NSString stringWithFormat:@"<ContentImg src=\"%@\"/>",[inode getAttributeNamed:@"src"]];
                            NSMutableAttributedString *string=[[NSMutableAttributedString alloc] initWithString:imagePath];
                            imageLength+=(imagePath.length-1);
                            [attributedString appendAttributedString:string];
                            string=nil;
                        }
                        else if ([inode.className isEqualToString:@"xsl-footnote-link"])
                        {
                            NSMutableAttributedString *str=[self changeString:inode.allContents AndFontSize:14 AndFontName:nil isbold:YES];
                            [str addAttribute:@"footnote" value:[inode getAttributeNamed:@"href"] range:NSMakeRange(0, str.length)];
                            [str addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(0,str.length)];
                            [str addAttribute:(NSString *)kCTSuperscriptAttributeName value:@(1) range:NSMakeRange(0, str.length)];
                            [attributedString appendAttributedString:str];
                            str=nil;
                        }
                        else if ([inode.tagName isEqualToString:@"a"]&&[inode getAttributeNamed:@"href"])
                        {
                            NSMutableAttributedString *str=[self changeString:inode.allContents AndFontSize:16 AndFontName:nil isbold:NO];
                            [str addAttribute:@"URL" value:[inode getAttributeNamed:@"href"] range:NSMakeRange(0, str.length)];
                            [str addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(0,str.length)];
                            [attributedString appendAttributedString:str];
                            str=nil;
                        }
                        else
                        {
                            NSMutableAttributedString *str=[self changeString:inode.allContents AndFontSize:16 AndFontName:nil isbold:NO];
                            [attributedString appendAttributedString:str];
                            str=nil;
                        }
                    }
                }
                else
                {
                    NSMutableArray *ary=[[NSMutableArray alloc] init];
                    for (HTMLNode *inode in node.children)
                    {
                        if ([inode.tagName isEqualToString:@"li"])
                        {
                            NSArray *iary=[NSArray arrayWithObjects:Name,[inode getAttributeNamed:@"id"],[inode allContents], nil];
                            [ary addObject:iary];
                            iary=nil;
                        }
                    }
                    NSString *tableName = @"FootNote";
                    YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:[NSString stringWithFormat:@"%@/BookFoot.db",_localPath]];
                    [store createTableWithName:tableName];
                    [store putObjectAry:ary intoTable:tableName];
                    ary=nil;
                    [store close];
                    store=nil;
                }
            }
            else
            {
                if (node.rawContents)
                {
                    NSMutableAttributedString *str=[self changeString:node.allContents AndFontSize:16 AndFontName:nil isbold:NO];
                    [attributedString appendAttributedString:str];
                    str=nil;
                }
            }
        }
    }
    return attributedString;
}

-(void)changeWidth:(float)width AndHeight:(float)height
{
    float iwidth=_NTFrame.size.width-44;
    float iheight=_NTFrame.size.height-85;
    if (width>iwidth&&width>height)
    {
        _NTHeight=(iwidth*height)/width;
        _NTWidth=iwidth;
    }
    else if(width>iwidth&&width<height)
    {
        _NTHeight=(iwidth*height)/width;
        if (_NTHeight>iheight)
        {
            _NTWidth=(width*iheight)/height;
            _NTHeight=iheight;
        }
        else
        {
            _NTWidth=iwidth;
        }
    }
    else if(width<iwidth&&width>height)
    {
        _NTHeight=iheight;
        _NTWidth=iwidth;
    }
    else if(width<iwidth&&width<height)
    {
        if (height<iheight)
        {
            _NTHeight=iheight;
            _NTWidth=iwidth;
        }
        else
        {
            _NTWidth=(width*iheight)/height;
            _NTHeight=height;
        }
    }
}

-(NSMutableAttributedString *)changeString:(NSString *)string AndFontSize:(float)size AndFontName:(NSString *)fontName isbold:(BOOL)isBold
{
    UIFont *font;
    CGFloat lineSp=9.5f;//行间距
    CGFloat ParagraphSp=0.0f;
    if (size==20)
    {
        ParagraphSp=20.0f;
        font=[self customBoldFontWithsize:size withFontName:fontName];
    }
    else if (size==19)
    {
        ParagraphSp=15.0f;
        font=[self customBoldFontWithsize:size withFontName:fontName];
    }
    else if (size==18)
    {
        ParagraphSp=10.0f;
        font=[self customBoldFontWithsize:size withFontName:fontName];
    }
    else if (size==17)
    {
        ParagraphSp=8.0f;
        font=[self customBoldFontWithsize:size withFontName:fontName];
    }
    else
    {
        if (isBold)
        {
            font=[self customBoldFontWithsize:size withFontName:fontName];
        }
        else
            font=[self customFontWithsize:size withFontName:fontName];
        if (_iscopyright) {
            ParagraphSp=1.0f;
        }
        else
            ParagraphSp=5.0f;
        
    }
    if (fontName) {
        lineSp=7.5;
    }
    
    NSMutableParagraphStyle *paragStyle = [[NSMutableParagraphStyle alloc] init];
    [paragStyle setLineSpacing:lineSp];
    [paragStyle setParagraphSpacing:ParagraphSp];
    [paragStyle setParagraphSpacingBefore:ParagraphSp];
//    [paragStyle setAlignment:NSTextAlignmentLeft];
    [paragStyle setAlignment:NSTextAlignmentNatural];
    NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           font, NSFontAttributeName,
                           (id)paragStyle, NSParagraphStyleAttributeName,
                           nil];
    
    return [[NSMutableAttributedString alloc] initWithString:string attributes:attrs];
}

-(UIFont*)customFontWithsize:(CGFloat)size withFontName:(NSString *)fontName
{
    if (!fontName) {
//        fontName=@"NotoSansCJKsc-DemiLight";
        fontName=@"FZLanTingHei-R-GB18030";
    }
    float isize;
    isize=size+1;
    UIFont *font=[UIFont fontWithName:fontName size:isize];
    return font;
}

-(UIFont*)customBoldFontWithsize:(CGFloat)size withFontName:(NSString *)fontName
{
    if (!fontName) {
//        fontName=@"NotoSansCJKsc-Bold";
        fontName=@"FZLanTingHei-B_GB18030";
    }
    float isize;
    isize=size+1;

    UIFont *font=[UIFont fontWithName:fontName size:isize];
    return font;
}

-(NSMutableAttributedString *)changeString:(NSString *)string AndLineSpacing:(float)height
{
    CGFloat lineSp=height;//行间距
    NSMutableParagraphStyle *paragStyle = [[NSMutableParagraphStyle alloc] init];
    [paragStyle setLineSpacing:lineSp];
    NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)paragStyle, NSParagraphStyleAttributeName,
                           nil];
    return [[NSMutableAttributedString alloc] initWithString:string attributes:attrs];
}


-(void)getImagesArrayWithStr:(NSString *)str withLocation:(int)length withWidth:(float)width withheight:(float)height
{
    __block NSString* fileName = @"";
    NSRegularExpression* srcRegex = [[NSRegularExpression alloc] initWithPattern:@"(?<=src=\")[^\"]+" options:0 error:NULL];
    [srcRegex enumerateMatchesInString:str options:0 range:NSMakeRange(0, [str length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        fileName = [str substringWithRange: match.range];
    }];
    [_images addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",width], @"width",[NSString stringWithFormat:@"%f",height], @"height",fileName, @"fileName",[NSNumber numberWithInt:length], @"location",nil]];
}

-(void)dealloc
{
//    NSLog(@"==dealloc==%@",self.class);
    [self.images removeAllObjects];
    _images=nil;
    _CatalogArray=nil;
}

@end
