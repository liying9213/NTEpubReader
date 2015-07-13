//
//  NTContentViewController.m
//  NTCoreTextReader
//
//  Created by liying on 14-6-27.
//  Copyright (c) 2014年 liying. All rights reserved.
//

#import "NTContentViewController.h"

#import <CoreText/CoreText.h>

#import "NTView.h"

#import "define.h"   
@interface NTContentViewController ()

@end

@implementation NTContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //        self.view.backgroundColor=[UIColor whiteColor];
        // Custom initialization
        //        self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self NTResetView];
    [NSThread detachNewThreadSelector:@selector(writeReadHistory) toTarget:self withObject:nil];
//    [self performSelectorOnMainThread:@selector(writeReadHistory) withObject:nil waitUntilDone:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)NTResetView
{
    CGRect textFrame = CGRectInset(self.view.bounds, 11 , 40);
    CGRect colRect = CGRectMake(0, 0 , textFrame.size.width-22, textFrame.size.height);
    
    //    CTFrameRef frame =_iframe;
    
    UILabel *titleLabel =[[UILabel alloc] initWithFrame:CGRectMake(22, 23, 290, 20)];
    titleLabel.textAlignment=NSTextAlignmentLeft;
    titleLabel.font=[UIFont systemFontOfSize:12];
    titleLabel.text=[self getPageNameWith:self.columnIndex];
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.textColor=[UIColor orangeColor];
    [self.view addSubview:titleLabel];
    titleLabel=nil;
    
    NTView *iview=[[NTView alloc] initWithFrame:CGRectMake(22, 50, colRect.size.width, colRect.size.height)];
    iview.currentName=[_pageInfo objectForKey:@"html"];
    iview.delegate=_delegate;
    iview.isSearch=_isSearch;
    [iview setNCTFrame:[_pageInfo objectForKey:@"CTFrameRef"]];
    iview.imageAry=[_pageInfo objectForKey:@"imageInfo"];
    [self.view addSubview:iview];
    
    UILabel *Pagelabel =[[UILabel alloc] initWithFrame:CGRectMake(MainWidth-170, iview.frame.size.height+iview.frame.origin.y+5, 155, 20)];
    Pagelabel.textAlignment=NSTextAlignmentRight;
    Pagelabel.font=[UIFont systemFontOfSize:12];
    Pagelabel.text=[NSString stringWithFormat:@"%d/%d",self.columnIndex+1,_allColumnCount];
    Pagelabel.backgroundColor=[UIColor clearColor];
    Pagelabel.textColor=[UIColor orangeColor];
    [self.view addSubview:Pagelabel];
    Pagelabel=nil;
    iview=nil;

    //    CFRelease(frame);
}

-(void)ResetView
{
    CGMutablePathRef path = CGPathCreateMutable(); //2
    CGRect textFrame = CGRectInset(self.view.bounds, 11 , 40);
    CGPathAddRect(path, NULL, textFrame );
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_htmlStr);
    
    if (_textPos < [_htmlStr length])
    { //4
        CGRect colRect = CGRectMake(0, 0 , textFrame.size.width-22, textFrame.size.height);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, colRect);
        //use the column path
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(_textPos, 0), path, NULL);
        CFRange frameRange = CTFrameGetVisibleStringRange(frame); //5
        
        UILabel *titleLabel =[[UILabel alloc] initWithFrame:CGRectMake(22, 23, 290, 20)];
        titleLabel.textAlignment=NSTextAlignmentLeft;
        titleLabel.font=[UIFont systemFontOfSize:12];
        titleLabel.text=_bookName;
        titleLabel.backgroundColor=[UIColor clearColor];
        titleLabel.textColor=[UIColor orangeColor];
        [self.view addSubview:titleLabel];
        titleLabel=nil;
        
        NTView *iview=[[NTView alloc] initWithFrame:CGRectMake(22, 50, colRect.size.width, colRect.size.height)];
        iview.delegate=_delegate;
        [iview setNCTFrame:(__bridge id)frame];
        [self.view addSubview:iview];
        
        
        UILabel *Pagelabel =[[UILabel alloc] initWithFrame:CGRectMake(150, iview.frame.size.height+iview.frame.origin.y+5, 155, 20)];
        Pagelabel.textAlignment=NSTextAlignmentRight;
        Pagelabel.font=[UIFont systemFontOfSize:12];
        Pagelabel.text=[NSString stringWithFormat:@"%d/%d",self.columnIndex+1,_allColumnCount];
        Pagelabel.backgroundColor=[UIColor clearColor];
        Pagelabel.textColor=[UIColor orangeColor];
        [self.view addSubview:Pagelabel];
        Pagelabel=nil;
        iview=nil;
        //prepare for next frame
        _beforePos=_textPos;
        _currentlength=frameRange.length;
        _textPos += frameRange.length;
        
        iview=nil;
        CFRelease(frame);
        CFRelease(path);
        CFRelease(framesetter);
    }
}

-(void)dealloc
{
    _delegate=nil;
    _pageInfo=nil;
    _htmlStr=nil;
}

-(void)writeReadHistory
{
    if (_pageInfo)
    {
        NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        int productID=9;
        if (_isGuide)
        {
            productID=6;
        }
        NSString *myDirectory = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"download/%d/%d/BookHistory",productID,_NTbookID]];
        NSFileManager *fileManager=[[NSFileManager alloc] init];
        if ([fileManager fileExistsAtPath:myDirectory])
        {
            [fileManager removeItemAtPath:myDirectory error:nil];
        }
        int currentPage;
        switch (_PageType) {
            case 0:
                currentPage=self.columnIndex;
                break;
            case -1:
                currentPage=self.columnIndex+1;
                break;
            case 1:
                currentPage=self.columnIndex-1;
                break;
            default:
                currentPage=self.columnIndex;
                break;
        }
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        [dic setObject:[NSNumber numberWithInt:currentPage] forKey:@"ReadPage"];
        [dic setObject:[_pageInfo objectForKey:@"html"] forKey:@"currentHtml"];
        [dic setObject:[NSNumber numberWithInt:_allColumnCount] forKey:@"allPage"];
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:dic forKey:@"NO Key Value"];
        [archiver finishEncoding];
        [data writeToFile:myDirectory atomically:YES];
        dic=nil;
        data=nil;
    }
}

-(NSString *)getPageNameWith:(int)pageNum
{
    for (NSMutableDictionary *dic in _catalogArray)
    {
        if ([[dic objectForKey:@"localPoint"] intValue]<=pageNum)
        {
            _bookName=[dic objectForKey:@"title"];
        }
        else
        {
            break;
        }
    }
     return _bookName;
}

@end
