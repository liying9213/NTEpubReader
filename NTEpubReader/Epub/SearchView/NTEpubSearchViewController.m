//
//  NTEpubSearchViewController.m
//  MPlatform
//
//  Created by 李莹 on 14-12-29.
//
//

#import "NTEpubSearchViewController.h"
#import "NTEpubReadViewController.h"
#import "NTCatalogTableViewCell.h"
#import <CoreText/CoreText.h>
#import "NTGetPageInfo.h"
#import "XSLAESCrypt.h"
#import "UIColor+MyColor.h"
#import "NTDate.h"
#import "define.h"
static void deallocCallback( void* ref )
{
    (__bridge id)ref;
}
static CGFloat ascentCallback( void *ref )
{
    return [(NSString*)[(__bridge NSDictionary*)ref objectForKey:@"height"] floatValue];
}

static CGFloat descentCallback( void *ref )
{
    return 0;
}
static CGFloat widthCallback( void* ref )
{
    return [(NSString*)[(__bridge NSDictionary*)ref objectForKey:@"width"] floatValue];
}
@implementation NTEpubSearchViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithHexString:@"#F6F6EE"];
    _AllSearchAry=[[NSMutableArray alloc] init];
    _AllPageNumAry=[[NSMutableArray alloc] init];
    _PageNumDic=[[NSMutableDictionary alloc] init];
    [self ResetView];
    [_searchText becomeFirstResponder];
}

-(void)ResetView
{
    UIView *HeaderView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, MainWidth, 44+(iOS7?20:0))];
    HeaderView.backgroundColor=[UIColor colorWithHexString:@"#333333"];
    [self.view addSubview:HeaderView];
    
    UIImageView *headerImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0+(iOS7?20:0), 44, 44)];
    headerImage.image=[UIImage imageNamed:@"icon_search_white.png"];
    [HeaderView addSubview:headerImage];
    
    _searchText=[[UITextField alloc]  initWithFrame:CGRectMake(headerImage.frame.size.width, 10+(iOS7?20:0), self.view.frame.size.width-125, 24)];
    _searchText.delegate=self;
    _searchText.backgroundColor=[UIColor colorWithHexString:@"#333333"];
    _searchText.textColor=[UIColor colorWithHexString:NTWhiteColor];
    [_searchText addTarget:self action:@selector(textField:) forControlEvents:UIControlEventEditingChanged];
//    _searchText.clearButtonMode=UITextFieldViewModeWhileEditing;
    [HeaderView addSubview:_searchText];
    _searchText.returnKeyType=UIReturnKeySearch;
    
    _clearnBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _clearnBtn.backgroundColor=[UIColor clearColor];
    _clearnBtn.frame=CGRectMake(_searchText.frame.size.width+_searchText.frame.origin.x-8, 9+(iOS7?20:0), 26, 26);
    [_clearnBtn setImage:[UIImage imageNamed:@"icon_delete_black.png"] forState:UIControlStateNormal];
    [_clearnBtn addTarget:self action:@selector(clearnAction) forControlEvents:UIControlEventTouchUpInside];
    _clearnBtn.hidden=YES;
    [HeaderView addSubview:_clearnBtn];
    
    UIButton * backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:@"取消" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    backBtn.frame=CGRectMake(_searchText.frame.size.width+_searchText.frame.origin.x+25, 9+(iOS7?20:0), 46, 26);
    backBtn.titleLabel.font=[UIFont systemFontOfSize:14.5];
    backBtn.backgroundColor=[UIColor colorWithHexString:NTWhiteColor];
    backBtn.layer.cornerRadius=5;
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [HeaderView addSubview:backBtn];

    _tableView=[[UITableView alloc] initWithFrame:CGRectMake(10, HeaderView.frame.size.height+10, MainWidth-20, self.view.frame.size.height-HeaderView.frame.size.height-20)];
    _tableView.layer.cornerRadius=8;
    _tableView.layer.masksToBounds=YES;
    _tableView.layer.borderWidth=0.8;
    _tableView.layer.borderColor=[[UIColor colorWithHexString:@"#C3BDAF"] CGColor];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.backgroundColor=[UIColor colorWithHexString:@"#F6F6EE"];
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    _pageAry=[[NSMutableArray alloc] init];
}

-(void)ResetStatusBar
{
    if (iOS7)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [self setNeedsStatusBarAppearanceUpdate];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

-(void)removeStatusBar
{
    if (iOS7)
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        [self setNeedsStatusBarAppearanceUpdate];
    }
}


#pragma mark - TableViewDelegate -

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _AllSearchAry.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * _cellIdentify = @"cell";
    NTCatalogTableViewCell * iCell = [tableView dequeueReusableCellWithIdentifier:_cellIdentify];
    iCell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (iCell == nil)
    {
        iCell = [[NTCatalogTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_cellIdentify];
    }
    iCell.titleLabel.lineBreakMode=NSLineBreakByWordWrapping;
    iCell.titleLabel.numberOfLines=0;
    iCell.titleLabel.font=[UIFont systemFontOfSize:15];
   NSRange range=[self getTheString:[[_AllSearchAry objectAtIndex:indexPath.row] objectForKey:@"info"]WithKeyWord:_searchText.text];
    if (range.location!=NSNotFound)
    {
        NSMutableParagraphStyle *paragStyle = [[NSMutableParagraphStyle alloc] init];
        [paragStyle setLineSpacing:2];
        [paragStyle setAlignment:NSTextAlignmentNatural];
        NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               [UIFont systemFontOfSize:15], NSFontAttributeName,
                               (id)paragStyle, NSParagraphStyleAttributeName,
                               nil];
        NSMutableAttributedString *attributedString=[[NSMutableAttributedString alloc] initWithString:[[_AllSearchAry objectAtIndex:indexPath.row] objectForKey:@"info"] attributes:attrs];
        
        [attributedString addAttributes:[NSDictionary dictionaryWithObject:[UIColor orangeColor] forKey:NSForegroundColorAttributeName] range:range];
        iCell.titleLabel.attributedText=attributedString;
         attributedString=nil;
    }
    else
        iCell.titleLabel.text=[[_AllSearchAry objectAtIndex:indexPath.row] objectForKey:@"info"];
    iCell.pageLabel.text=[NSString stringWithFormat:@"%d",[[[_AllSearchAry objectAtIndex:indexPath.row] objectForKey:@"localPoint"] intValue]+1];
    iCell.pageLabel.textAlignment=NSTextAlignmentRight;
    iCell.pageLabel.font=[UIFont systemFontOfSize:11];
    iCell.titleLabel.frame=CGRectMake(12, 10, self.view.frame.size.width-40, 60);
    iCell.pageLabel.frame=CGRectMake(12, 55, self.view.frame.size.width-50, 10);
    iCell.lineView.frame=CGRectMake(0, 79.5, self.view.frame.size.width, 0.6);
    iCell.lineView.backgroundColor=[UIColor colorWithHexString:@"#C3BDAF"];
    return iCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self back];
    [_delegate openSearchTheViewPage:[_AllSearchAry objectAtIndex:indexPath.row]];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_searchText isFirstResponder])
    {
        [_searchText resignFirstResponder];
    }
}

-(NSRange)getTheString:(NSString *)str WithKeyWord:(NSString *)key
{
    NSRange range = [str rangeOfString:key];
    if (range.location !=NSNotFound)
    {
        return range;
    }
    else
        return range;
}

#pragma mark - textFieldDelegate -

-(void)textField:(UITextField *)textField
{
    if (textField.text.length>0)
    {
        _clearnBtn.hidden=NO;
    }
    else
        _clearnBtn.hidden=YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NTEpubReadViewController* _readView=(NTEpubReadViewController *)_delegate;
    [_readView showWaitView:@"搜索中..."];
    [self performSelector:@selector(searchActionWith:) withObject:textField.text afterDelay:0.01];
    _readView=nil;
    return YES;
}

-(void)searchActionWith:(NSString*)keyWord
{
    _OneSearchAry=[[NSMutableArray alloc] init];
    [_AllSearchAry removeAllObjects];
    [_AllPageNumAry removeAllObjects];
    [_PageNumDic removeAllObjects];
    [self parseHtmlAgain];
    for (NSDictionary *dic in _infoAry)
    {
        NSMutableAttributedString *istr=[self GetHtmlInfoWithName:[dic objectForKey:@"htmlName"]];
        NSMutableArray *ary= [self RangeOfString:istr.string WithKey:keyWord withpont:0];
        if (ary&&ary.count>0)
        {
            [self matchingPointWith:ary With:[dic objectForKey:@"htmlName"]];
            [_OneSearchAry removeAllObjects];
        }
        ary=nil;
    }
    NTEpubReadViewController* _readView=(NTEpubReadViewController *)_delegate;
    if (!_AllSearchAry||!_AllSearchAry.count>0) {
        [_readView showEndText:@"没有搜索到结果！"];
    }
    else
    {
        [_readView.waitingView hide:YES];
    }
    [_tableView reloadData];
    _readView=nil;
}

#pragma mark - GetCacheData -

-(void)parseHtmlAgain
{
    NSString *path=[_BasePath stringByAppendingPathComponent:@"PointCache"];
    NSFileManager *fileManager=[[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:path])
    {
        [_delegate NeedParseHtml];
    }
}

-(NSMutableDictionary *)GetPagePointInfoWithName:(NSString *)name
{
    NSString *path=[_BasePath stringByAppendingPathComponent:@"PointCache"];
    NSFileManager *fileManager=[[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:path])
    {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        return nil;
    }
    NSString *Name=[XSLAESCrypt xslmd5:name];
    NSString *myDirectory = [path stringByAppendingPathComponent:Name];
    NSData *data = [[NSMutableData alloc] initWithContentsOfFile:myDirectory];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSMutableDictionary *dic = [unarchiver decodeObjectForKey:@"NO Key Value"];
    [unarchiver finishDecoding];
    return dic;
}

-(NSMutableAttributedString *)GetHtmlInfoWithName:(NSString *)name
{
    NSString *Name=[XSLAESCrypt xslmd5:name];
    NSString *myDirectory = [_BasePath stringByAppendingPathComponent:Name];
    NSData *data = [[NSMutableData alloc] initWithContentsOfFile:myDirectory];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSMutableAttributedString *str = [unarchiver decodeObjectForKey:@"NO Key Value"];
    return [self getTheContentRegexString:str];
}

-(NSMutableDictionary *)GetHtmlPointWithName:(NSString *)name
{
    NSString *Name=[XSLAESCrypt xslmd5:name];
    NSString *path=[_BasePath stringByAppendingPathComponent:Name];
    NSFileManager *fileManager=[[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:path])
    {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        return nil;
    }
    NSData *data = [[NSMutableData alloc] initWithContentsOfFile:path];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSMutableDictionary *dic = [unarchiver decodeObjectForKey:@"NO Key Value"];
    [unarchiver finishDecoding];
    return dic;
}


-(NSMutableArray *)RangeOfString:(NSString *)str WithKey:(NSString *)key withpont:(NSInteger)point
{
    NSMutableArray *ary=[[NSMutableArray alloc] init];
    NSRange range = [[str substringFromIndex:point] rangeOfString:key];
    if (range.location !=NSNotFound)
    {
        [ary addObject:[NSNumber numberWithInteger:range.location+point]];
        [_OneSearchAry addObject:[self getThePoint:range.location+point WithStr:str]];
        if (range.location<str.length-1)
        {
            NSMutableArray *iary=[self RangeOfString:str WithKey:key withpont:range.location+range.length+point];
            [ary addObjectsFromArray:iary];
        }
    }
    return ary;
}

-(NSString *)getThePoint:(NSInteger)point WithStr:(NSString *)str
{
    NSString *lastString;
    if (point>23&&str.length>point+23)
    {
        NSString *theStr=[str substringWithRange:NSMakeRange(point-23,45)];
        lastString=[NSString stringWithFormat:@"...%@...",theStr];
    }
    else if(point>23&&str.length<point+23)
    {
        NSString *theStr=[str substringFromIndex:point-23];
        lastString = [NSString stringWithFormat:@"...%@",theStr];
    }
    else if(point<=23&&str.length>point+23)
    {
        NSString *theStr=[str substringToIndex:point+23];
        lastString =  [NSString stringWithFormat:@"%@...",theStr];
    }
    else
    {
        lastString =str;
    }
   return [[lastString stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

-(void)matchingPointWith:(NSArray *)PointAry With:(NSString *)htmlname
{
    NSMutableDictionary *dic=[self GetPagePointInfoWithName:htmlname];
    int num=[[dic objectForKey:@"Num"] intValue];
    NSUInteger pageNum;
    NSMutableArray *pageNumAry=[[NSMutableArray alloc] init];
    for (int i=0; i<PointAry.count; i++)
    {
       pageNum= [self FindPageWith:[dic objectForKey:@"point"] Withpoint:[[PointAry objectAtIndex:i] intValue]];
        [pageNumAry addObject:[NSNumber numberWithInteger:pageNum+num]];
    }
    [self getPageInfoWith:_OneSearchAry with:pageNumAry With:htmlname withPoint:PointAry];
    if (pageNumAry&&pageNumAry.count>0)
    {
        for (unsigned i = 0; i < [pageNumAry count]; i++)
        {
            if ([_AllPageNumAry containsObject:[pageNumAry objectAtIndex:i]] == NO)
            {
                [_AllPageNumAry addObject:[pageNumAry objectAtIndex:i]];
            }
        }
    }
    pageNumAry=nil;
}

-(NSUInteger)FindPageWith:(NSArray *)ary Withpoint:(int)point
{
    NSUInteger count =[ary count];
    int target = point;
    NSUInteger start = 0, end = count - 1, mid =0;
    while (start <= end) {
        mid = (start + end) /2;
        if ([[ary objectAtIndex:mid] intValue] > target)
        {
            end = mid -1;
        } else if ([[ary objectAtIndex:mid] intValue] < target&&mid!=count-1&&[[ary objectAtIndex:mid+1] intValue] < target)
        {
            start = mid +1;
        } else
        {
            break;
        }
    }
    if (start <= end)
    {
        return mid;
    }
    else
    {
        return 0;
    }
}

-(void)getPageInfoWith:(NSArray *)infoary with:(NSArray *)pageAry With:(NSString *)name withPoint:(NSArray*)pointAry
{
    if ([infoary count]==[pageAry count]&&[pageAry count]==[pointAry count])
    {
        for (int i=0; i<[infoary count]; i++)
        {
            NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
            [dic setObject:[infoary objectAtIndex:i] forKey:@"info"];
            [dic setObject:[pageAry objectAtIndex:i] forKey:@"localPoint"];
            [dic setObject:[pointAry objectAtIndex:i] forKey:@"searchPoint"];
            [dic setObject:pointAry forKey:@"searchPointAry"];
            [dic setObject:[NSNumber numberWithInteger:_searchText.text.length] forKey:@"searchlength"];
            [dic setObject:name forKey:@"htmlName"];
            [_AllSearchAry addObject:dic];
            [_PageNumDic setObject:name forKey:[pageAry objectAtIndex:i]];
            dic=nil;
        }
    }
}

-(void)clearnAction
{
    _searchText.text=@"";
    [_AllSearchAry removeAllObjects];
    [_tableView reloadData];
    _clearnBtn.hidden=YES;
    [_searchText becomeFirstResponder];
}

-(void)backAction
{
    [self back];
    [_delegate closeTheSearchView];
}

-(void)back
{
    [self removeStatusBar];
    [_searchText resignFirstResponder];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.type =kCATransitionPush;
    transition.subtype =kCATransitionFromBottom;
    [self.view.layer addAnimation:transition forKey:@"animation"];
    self.view.hidden=YES;
    //    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSMutableAttributedString *)getTheContentRegexString:(NSMutableAttributedString *)string
{
    if (!string) {
        return string;
    }
    
    NSError *error = nil;
    NSString *sReg =@"<ContentImg[^>]+src\\s*=\\s*['\"]([^'\"]+)['\"][^>]*>";
    NSRegularExpression * reg = [NSRegularExpression regularExpressionWithPattern:sReg options:NSRegularExpressionCaseInsensitive error:&error];
    if (error == nil && reg)
    {
        NSRange range=[reg rangeOfFirstMatchInString:string.string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
        if (range.location!=NSNotFound)
        {
            NSString * fileName = [string.string substringWithRange:NSMakeRange(range.location, range.length)];
            BOOL PageImage=YES;
            NSAttributedString *str=[self parseImageDataFromgetWith:fileName withLocation:range.location isPageImage:PageImage isLineImage:YES];
            [string replaceCharactersInRange:NSMakeRange(range.location, range.length) withAttributedString:str];
            [self getTheContentRegexString:string];
        }
    }
    return string;
}

- (NSAttributedString *)parseImageDataFromgetWith:(NSString *)name withLocation:(NSInteger)loaction isPageImage:(BOOL)pageImage isLineImage:(BOOL)isInLine;
{
    NSString * Name;
    NSString *sReg = @"(?<=src=\")[^\"]+";
    NSRegularExpression * reg = [NSRegularExpression regularExpressionWithPattern:sReg options:NSRegularExpressionCaseInsensitive error:nil];
    if (reg)
    {
        NSArray *match = [reg matchesInString:name
                                      options:NSMatchingReportProgress
                                        range:NSMakeRange(0, name.length)];
        if ([match count] > 0)
        {
            for (NSInteger i=match.count-1;i>=0;i--)
            {
                NSTextCheckingResult *result=[match objectAtIndex:i];
                Name= [name substringWithRange:result.range];
            }
        }
    }
    NSString *path=[_BasePath stringByAppendingPathComponent:Name];
    UIImage *image=[UIImage imageWithContentsOfFile:path];
    float width=image.size.width;
    float height=image.size.height;
    image=nil;
    
    if (isInLine)
    {
        [self changeInLineImageWidth:width AndHeight:height];
    }
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys: //2
                          [NSNumber numberWithFloat:_NTWidth], @"width",
                          [NSNumber numberWithFloat:_NTHeight], @"height",
                          nil];
    
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(dict));
    
    // 使用0xFFFC作为空白的占位符
    unichar objectReplacementChar = 0xFFFC;
    NSString * content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString * space = [[NSMutableAttributedString alloc] initWithString:content];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0,1),
                                   kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    return space;
}

-(void)changeInLineImageWidth:(float)width AndHeight:(float)height
{
    _NTHeight=height/3;
    _NTWidth=width/3;
}

@end
