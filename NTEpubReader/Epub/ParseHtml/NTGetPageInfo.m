
//
//  NTGetPageInfo.m
//  NTCoreTextReader
//
//  Created by liying on 14-6-27.
//  Copyright (c) 2014年 liying. All rights reserved.
//

#import "NTGetPageInfo.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import <CoreText/CoreText.h>
#import "NTChangeAttributedString.h"
#import "NTTestParser.h"
#import "SMXMLDocument.h"
#import "ZipArchive.h"
#import "XSLAESCrypt.h"
#import "NTDate.h"
#import "define.h"
#import "NSData+XSLCommonCrypto.h"
#import "UIColor+MyColor.h"
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
@implementation NTGetPageInfo

-(id)initWithTheBookID:(NSString *)bookName
{
    self = [super init];
    if (self)
    {
        _bookID=bookName;
    }
    return self;
}

-(NSMutableDictionary *)getTheEpubPageInfoWithPath:(NSString *)path  withFrame:(CGRect)frame
{
    _NTframe=frame;
    _AllPageInfo=[[NSMutableDictionary alloc] init];
    _CatalogArray=[[NSMutableArray alloc] init];
    _CatalogPageArray=[[NSMutableArray alloc] init];
    _NcxCatalogArray=[[NSMutableArray alloc] init];
    _currentPage=0;
    [self isHaveDecompressionWithPath:path];
    BasePath=path;
    LoadPath=[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/OPS",_bookID]];
    if ([self haveTheCatalog])
    {
        [self getCatalogInfoArry];
        [self getReadHistory];
        for (int i=0; i<_CatalogInfoArray.count; i++)
        {
            NSMutableDictionary *dic=[_CatalogInfoArray objectAtIndex:i];
            if ([[dic objectForKey:@"htmlName"] isEqualToString:_currentHtml])
            {
                [self getTheStringFromName:[dic objectForKey:@"htmlName"] withThepage:[[dic objectForKey:@"UpPageNum"] intValue]];
                int finishPage=[[dic objectForKey:@"FinPageNum"] intValue];
                int beginPage=[[dic objectForKey:@"UpPageNum"] intValue];
                if (finishPage-beginPage<10||(finishPage-_currentPage<10&&_currentPage-beginPage<10))
                {
                    [self loadPageViewWith:dic];
                }
                else if (finishPage-_currentPage<10)
                {
                    if ([dic objectForKey:@"afterHtmlPath"])
                    {
                        [self getTheStringFromName:[dic objectForKey:@"afterHtmlPath"] withThepage:[[dic objectForKey:@"FinPageNum"] intValue]];
                    }
                }
                else if (_currentPage-beginPage<10)
                {
                    if ([dic objectForKey:@"UPHtmlPath"])
                    {
                        NSMutableDictionary *dic1=[_CatalogInfoArray objectAtIndex:i-1];
                        if ([[dic1 objectForKey:@"htmlName"] isEqualToString:[dic objectForKey:@"UPHtmlPath"]])
                        {
                            [self getTheStringFromName:[dic1 objectForKey:@"htmlName"] withThepage:[[dic1 objectForKey:@"UpPageNum"] intValue]];
                        }
                    }
                }
                else
                {
                    [NSThread detachNewThreadSelector:@selector(loadPageViewWith:) toTarget:self withObject:dic];
                }
            }
            dic=nil;
        }
//        _allPage=page;
    }
    else
    {
        [self parseHtmlAgain:NO];
    }
    return _AllPageInfo;
}

-(void)parseHtmlAgain:(BOOL)isAgain
{
    if (isAgain)
    {
        _AllPageInfo=[[NSMutableDictionary alloc] init];
        _CatalogArray=[[NSMutableArray alloc] init];
        _CatalogPageArray=[[NSMutableArray alloc] init];
        _NcxCatalogArray=[[NSMutableArray alloc] init];
        _allPage=0;
    }
    BOOL isHaveNCX;
    BOOL isHaveOPF;
    isFirstParse=YES;
    NSFileManager *fileManager=[[NSFileManager alloc] init];
    __autoreleasing NSArray  *arr = [fileManager  contentsOfDirectoryAtPath:LoadPath error:nil];
    NSString *ncxName;
    NSString *opfName;
    for (NSString * name in arr)
    {
        //            content.opf
        if([[name pathExtension] isEqualToString:@"ncx"])
        {
            isHaveNCX=YES;
            ncxName=name;
        }
        if([[name pathExtension] isEqualToString:@"opf"])
        {
            isHaveOPF=YES;
            opfName=name;
        }
    }
    if (isHaveNCX&&isHaveOPF)
    {
        NSString *Ncxpath=[LoadPath stringByAppendingPathComponent:ncxName];
        NSString *Opfpath=[LoadPath stringByAppendingPathComponent:opfName];
        [self getTheCatalogWithNcxPath:Ncxpath OpfPath:Opfpath];
    }
    else
    {
        NSString *Ncxpath=[LoadPath stringByAppendingPathComponent:@"toc.ncx"];
        NSString *Opfpath=[LoadPath stringByAppendingPathComponent:@"content.opf"];
        [self getTheCatalogWithNcxPath:Ncxpath OpfPath:Opfpath];
    }
    
    _NTAllPage=_allPage;
    [self getTheCatalog];
}

-(void)loadPageViewWith:(NSMutableDictionary *)dic
{
    if ([dic objectForKey:@"afterHtmlPath"])
    {
        [self getTheStringFromName:[dic objectForKey:@"afterHtmlPath"] withThepage:[[dic objectForKey:@"FinPageNum"] intValue]];
    }
    if ([dic objectForKey:@"UPHtmlPath"])
    {
        for (int i=0; i<_CatalogInfoArray.count; i++)
        {
            NSMutableDictionary *dic1=[_CatalogInfoArray objectAtIndex:i];
            if ([[dic1 objectForKey:@"htmlName"] isEqualToString:[dic objectForKey:@"UPHtmlPath"]])
            {
                [self getTheStringFromName:[dic1 objectForKey:@"htmlName"] withThepage:[[dic1 objectForKey:@"UpPageNum"] intValue]];
            }
        }
    }
}

#pragma mark - decompressionEpub -

-(BOOL)isHaveDecompressionWithPath:(NSString *)path
{
    NSFileManager *filemanager=[[NSFileManager alloc] init];
    NSString *myDirectory = [NSString stringWithFormat:@"%@/%@",path,_bookID];
    if (![filemanager fileExistsAtPath:myDirectory])
    {
        @autoreleasepool {
            ZipArchive* za = [[ZipArchive alloc] init];
            if( [za UnzipOpenFile:[NSString stringWithFormat:@"%@.epub",path]])
            {
                NSFileManager *filemanager=[[NSFileManager alloc] init];
                if ([filemanager fileExistsAtPath:myDirectory])
                {
                    NSError *error;
                    [filemanager removeItemAtPath:myDirectory error:&error];
                }
                filemanager=nil;
                BOOL ret = [za UnzipFileTo:[NSString stringWithFormat:@"%@/",myDirectory] overWrite:YES];
                if( NO==ret )
                {
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error while unzipping the epub"delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    alert=nil;
                }
                [za UnzipCloseFile];
            }
        }
    }
    return YES;
}

#pragma mark - getInfoFromNCX -
-(void)NTgetTheCatalogWithPath:(NSString *)path
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error;
    SMXMLDocument *document = [SMXMLDocument documentWithData:data error:&error];
    SMXMLElement *books = [document childNamed:@"spine"];
    for (SMXMLElement *book in [books childrenNamed:@"itemref"])
    {
        NSString *htmlName=[book attributeNamed:@"idref"];
        NSString *isShow=[book attributeNamed:@"linear"];
        if (![isShow isEqualToString:@"no"])
        {
            [_PathAry addObject:[NSString stringWithFormat:@"%@.html",htmlName]];
        }
    }
    [self getTheStringFromArrray:_PathAry];
}

-(void)getTheCatalogWithNcxPath:(NSString *)ncxPath OpfPath:(NSString *)opfPath
{
    _PathAry=[[NSMutableArray alloc] init];
    NSData *data = [NSData dataWithContentsOfFile:ncxPath];
    NSError *error;
	SMXMLDocument *document = [SMXMLDocument documentWithData:data error:&error];
    if (error) {
        NSLog(@"Error while parsing the document: %@", error);
        return;
    }
    SMXMLElement *books = [document childNamed:@"navMap"];
    for (SMXMLElement *book in [books childrenNamed:@"navPoint"])
    {
		NSString *title = [book valueWithPath:@"navLabel.text"];
        NSString *htmlName=[[book descendantWithPath:@"content"] attributeNamed:@"src"];
        NSString *name=[[htmlName componentsSeparatedByString:@"#"] firstObject];
//        [_PathAry addObject:name];
        _catalogTier=0;
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        [dic setObject:title forKey:@"title"];
        [dic setObject:name forKey:@"htmlName"];
        [dic setObject:[NSNumber numberWithInt:_catalogTier] forKey:@"catalogTier"];
        [dic setObject:[NSNumber numberWithInt:_allPage] forKey:@"lastPageNum"];
        [_NcxCatalogArray addObject:dic];
        dic=nil;
        htmlName=nil;
        title=nil;
        [self getThe:book withName:name];
        name=nil;
    }
    books=nil;
    [self NTgetTheCatalogWithPath:opfPath];
//    [self getTheStringFromArrray:_PathAry];
}
-(void)getThe:(SMXMLElement*)books withName:(NSString *)pathName
{
    _catalogTier++;
    for (SMXMLElement *book in [books childrenNamed:@"navPoint"])
    {
		NSString *title = [book valueWithPath:@"navLabel.text"];
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        [dic setObject:title forKey:@"title"];
        [dic setObject:[NSNumber numberWithInt:_catalogTier] forKey:@"catalogTier"];
        NSString *htmlName=[[book descendantWithPath:@"content"] attributeNamed:@"src"];
        NSString *name=[[htmlName componentsSeparatedByString:@"#"] firstObject];
        [dic setObject:name forKey:@"htmlName"];
        [_NcxCatalogArray addObject:dic];
//        if (![_PathAry containsObject:name])
//        {
//            [_PathAry addObject:name];
//        }
        dic=nil;
        title=nil;
        [self getThe:book withName:pathName];
    }
    _catalogTier--;
}

#pragma mark - gerStringFromHtml -

-(void)getTheStringFromArrray:(NSArray *)ary
{
    _testAry=[[NSMutableArray alloc] init];
    _CatalogInfoArray=[[NSMutableArray alloc] init];
    for (int i=0;i<ary.count;i++)
    {
        NSString * name = [ary objectAtIndex:i];
        int pagenum=_allPage;
        [self getTheStringFromName:name];
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        [dic setObject:name forKey:@"htmlName"];
        [dic setObject:[NSNumber numberWithInt:pagenum] forKey:@"UpPageNum"];
        [dic setObject:[NSNumber numberWithInt:_allPage] forKey:@"FinPageNum"];
        if (i!=0)
        {
            [dic setObject:[ary objectAtIndex:i-1] forKey:@"UPHtmlPath"];
        }
        if (i!=ary.count-1)
        {
            [dic setObject:[ary objectAtIndex:i+1] forKey:@"afterHtmlPath"];
        }
        [_CatalogInfoArray addObject:dic];
        dic=nil;
    }
    [self writefileWithAry:_CatalogInfoArray];
}

-(NSMutableDictionary *)getTheSearchStringFromName:(NSString *)name withThepage:(int)page WithPoint:(NSArray *)pointAry WithLength:(float)length
{
    _imageArray=[[NSMutableArray  alloc] init];
    _allPage=page;
    CGRect rect=_NTframe;
    rect.size.width-=22;
    NSMutableAttributedString *attString=[self GetHtmlInfoWithName:name];
    attString= [self getTheRegexString:attString];
    for (NSNumber *point in pointAry)
    {
        [attString addAttribute: NSBackgroundColorAttributeName value:[UIColor colorWithHexString:getSMS] range:NSMakeRange([point intValue], length)];
    }
//
    [self imagegetPageInfoWith:attString  withHtml:name withframe:rect];
    _imageArray=nil; 
    return _AllPageInfo;
}

-(void)getTheStringFromName:(NSString *)name withThepage:(int)page
{
    _allPage=page;
    CGRect rect=_NTframe;
    rect.size.width-=22;
    NSMutableAttributedString *attString=[self GetHtmlInfoWithName:name];
    _imageArray=[[NSMutableArray  alloc] init];
    [self igetPageInfoWith:attString  withHtml:name withframe:rect];
    _imageArray=nil;
}

#pragma mark - getThePageInfoFromString -

-(void)imagegetPageInfoWith:(NSMutableAttributedString *)_htmlStr withHtml:(NSString *)name  withframe:(CGRect)rect
{
    NSMutableAttributedString *string=_htmlStr;
    
    CGFloat numq=1.0f;
    long number = numq;
    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &number);
    [string addAttribute:(id)kCTKernAttributeName value:(__bridge id)num range:NSMakeRange(0, [string length])];
    CFRelease(num);
    
    CGRect textFrame = CGRectInset(rect, 11 , 40);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFMutableAttributedStringRef)string);
    int textPos=0;
    CGRect colRect = CGRectMake(0, 0 , textFrame.size.width, textFrame.size.height);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, colRect);
    
    while (textPos < [string length])
    {
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        //        [dic setObject:[NSNumber numberWithInt:textPos] forKey:@"pos"];
        [dic setObject:name forKey:@"html"];
        
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, NULL);
        if (_imageArray.count>0)
        {
            _imageInfoArray=[[NSMutableArray alloc] init];
            [self attachImagesWithFrame:frame index:0];
            [dic setObject:_imageInfoArray forKey:@"imageInfo"];
        }
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        
        textPos += frameRange.length;
        [dic setObject:(__bridge id)(frame) forKey:@"CTFrameRef"];
        [_AllPageInfo setObject:dic forKey:[NSString stringWithFormat:@"%d",_allPage]];
        dic=nil;
        CFRelease(frame);
        _allPage++;
        _imageInfoArray=nil;
    }
    //    CFRelease(path);
    CFRelease(framesetter);
    _imageArray=nil;
    _imageInfoArray=nil;
    _htmlStr=nil;
}

-(void)igetPageInfoWith:(NSMutableAttributedString *)_htmlStr withHtml:(NSString *)name  withframe:(CGRect)rect
{
    NSMutableAttributedString *string=[self getTheRegexString:_htmlStr];
    
    CGFloat numq=1.0f;
    long number = numq;
    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &number);
    [string addAttribute:(id)kCTKernAttributeName value:(__bridge id)num range:NSMakeRange(0, [string length])];
    CFRelease(num);

    CGRect textFrame = CGRectInset(rect, 11 , 40);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFMutableAttributedStringRef)string);
    int textPos=0;
    CGRect colRect = CGRectMake(0, 0 , textFrame.size.width, textFrame.size.height);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, colRect);

    while (textPos < [string length])
    {
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
//        [dic setObject:[NSNumber numberWithInt:textPos] forKey:@"pos"];
        [dic setObject:name forKey:@"html"];
        
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, NULL);
        if (_imageArray.count>0)
        {
            _imageInfoArray=[[NSMutableArray alloc] init];
            [self attachImagesWithFrame:frame index:0];
            if (_imageInfoArray.count>0) {
               [dic setObject:_imageInfoArray forKey:@"imageInfo"];
            }
        }
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        
        textPos += frameRange.length;
        [dic setObject:(__bridge id)(frame) forKey:@"CTFrameRef"];
        [_AllPageInfo setObject:dic forKey:[NSString stringWithFormat:@"%d",_allPage]];
        dic=nil;
        CFRelease(frame);
        _allPage++;
        _imageInfoArray=nil;
    }
//    CFRelease(path);
    CFRelease(framesetter);
    _imageArray=nil;
    _imageInfoArray=nil;
    _htmlStr=nil;
}

-(void)getTheStringFromName:(NSString *)name
{
    NSString *path=[LoadPath stringByAppendingPathComponent:name];
    
//    NSData * data = [NSData dataWithContentsOfFile:path];
//    NSString * key = [[XSLAESCrypt xslmd5:AES_KEY] lowercaseString];
//    NSData * aesData = [data xsldecryptedAES256DataUsingKey:key error:nil];
//    NSString * html = [[NSString alloc] initWithData:aesData encoding:NSUTF8StringEncoding];
//    data=nil;
//    aesData=nil;

    NSString *html=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NTTestParser *Parser=[[NTTestParser alloc] initWithThe:_NTframe WithTheLocalPath:BasePath];
    NSMutableAttributedString *attString=[Parser ParserHtml:html withName:name];
    [self writeHtmlInfoWith:attString withName:name];
    _imageArray=[[NSMutableArray  alloc] init];
    _CatalogArray=Parser.CatalogArray;
    [_testAry addObjectsFromArray:Parser.testAry];
    CGRect rect=_NTframe;
    rect.size.width-=22;
    [self getPageInfoWith:attString withHtml:name withframe:rect];
    Parser=nil;
    html=nil;
    attString=nil;
}

#pragma mark - getThePageInfoFromString -

-(void)getPageInfoWith:(NSMutableAttributedString *)_htmlStr withHtml:(NSString *)name  withframe:(CGRect)rect
{
    NSMutableAttributedString *string=[self getTheRegexString:_htmlStr];
    CGRect textFrame = CGRectInset(rect, 11 , 40);
    
    CGFloat numq=1.0f;
    long number = numq;
    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &number);
    [string addAttribute:(id)kCTKernAttributeName value:(__bridge id)num range:NSMakeRange(0, [string length])];
    CFRelease(num);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFMutableAttributedStringRef)string);
    int textPos=0;
    CGRect colRect = CGRectMake(0, 0 , textFrame.size.width, textFrame.size.height);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, colRect);
    NSMutableArray *pointAry=[[NSMutableArray alloc] init];
    NSMutableDictionary *_AllPageNumInfo=[[NSMutableDictionary alloc] init];
    [_AllPageNumInfo setObject:[NSNumber numberWithInt:_allPage] forKey:@"Num"];
    while (textPos < [string length])
    {
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        [dic setObject:name forKey:@"html"];
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, NULL);
        if (_imageArray.count>0)
        {
            _imageInfoArray=[[NSMutableArray alloc] init];
            [self attachImagesWithFrame:frame index:0];
            [dic setObject:_imageInfoArray forKey:@"imageInfo"];
        }
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        if (_CatalogArray.count>0)
        {
            for (NSNumber *pagenum in _CatalogArray)
            {
                int point=[pagenum intValue];
                if (textPos <=point && textPos+frameRange.length >point)
                {
                    [_CatalogPageArray addObject:[NSNumber numberWithInt:_allPage]];
                }
                else if (point>textPos+frameRange.length)
                {
                    break;
                }
            }
        }
        [pointAry addObject:[NSNumber numberWithInt:textPos]];
        textPos += frameRange.length;
        [dic setObject:(__bridge id)(frame) forKey:@"CTFrameRef"];
        [_AllPageInfo setObject:dic forKey:[NSString stringWithFormat:@"%d",_allPage]];
        _allPage++;
        dic=nil;
        CFRelease(frame);
//        CFRelease(path);
    }
    [_AllPageNumInfo setObject:pointAry forKey:@"point"];
    [self writePagePointInfoWith:_AllPageNumInfo withName:name];
    CFRelease(framesetter);
    _imageArray=nil;
    _imageInfoArray=nil;
    _htmlStr=nil;
    _AllPageNumInfo=nil;
    pointAry=nil;
}

-(NSMutableAttributedString *)getTheRegexString:(NSMutableAttributedString *)string
{
    if (!string) {
        return string;
    }
    NSError *error = nil;
    NSString *sReg =@"<img[^>]+src\\s*=\\s*['\"]([^'\"]+)['\"][^>]*>";
    NSRegularExpression * reg = [NSRegularExpression regularExpressionWithPattern:sReg options:NSRegularExpressionCaseInsensitive error:&error];
    
    string=[self getTheContentRegexString:string];
    
    if (error == nil && reg)
    {
        NSArray *match = [reg matchesInString:string.string
                                      options:NSMatchingReportProgress
                                        range:NSMakeRange(0, string.length)];
        for (int i=0; i<[match count]; i++)
        {
            NSTextCheckingResult *result=[match objectAtIndex:i];
            NSUInteger location=result.range.location;
            NSString * fileName = [string.string substringWithRange:NSMakeRange(location, result.range.length)];
            BOOL PageImage=NO;
            if ([match count]==1&&result.range.length==string.length)
            {
                PageImage=YES;
            }
            NSMutableString *NTString=[[NSMutableString alloc] initWithFormat:@"                        "];
            NSInteger value=result.range.length-NTString.length;
            for (int i=0; i<value; i++)
            {
                [NTString appendString:@" "];
            }
            [string replaceCharactersInRange:NSMakeRange(location, result.range.length) withString:NTString];
            [string addAttributes: [self getTheStringAttributesWith:fileName withLocation:location isPageImage:PageImage isLineImage:NO] range:NSMakeRange(location, result.range.length)];
        }
    }
    NSArray *arr = _imageArray;
    NSArray *arr2 = [arr sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        NSComparisonResult result = [[obj1 objectForKey:@"location"] compare:[obj2 objectForKey:@"location"]];
        return result;
    }];
    _imageArray=[[NSMutableArray alloc] initWithArray:arr2];
    arr=nil;
    arr2=nil;
    return string;
}

-(NSMutableAttributedString *)getTheImageRegexString:(NSMutableAttributedString *)string with:(NSRange)range
{
    if (!string) {
        return string;
    }
    
    //    NSError *error = nil;
    //    NSString *sReg =@"<img[^>]+src\\s*=\\s*['\"]([^'\"]+)['\"][^>]*>";
    //    NSRegularExpression * reg = [NSRegularExpression regularExpressionWithPattern:sReg options:NSRegularExpressionCaseInsensitive error:&error];
    //    if (error == nil && reg)
    //    {
    //        NSRange range=[reg rangeOfFirstMatchInString:string.string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
    //        NSUInteger location=range.location;
    NSString * fileName = [string.string substringWithRange:NSMakeRange(range.location, range.length)];
    BOOL PageImage=NO;
    if (range.length==string.length)
    {
        PageImage=YES;
    }
    NSMutableString *NTString=[[NSMutableString alloc] initWithFormat:@"                        "];
    NSInteger value=range.length-NTString.length;
    for (int i=0; i<value; i++)
    {
        [NTString appendString:@" "];
    }
    [string replaceCharactersInRange:NSMakeRange(range.location, range.length) withString:NTString];
    [string addAttributes: [self getTheStringAttributesWith:fileName withLocation:range.location isPageImage:PageImage isLineImage:NO] range:NSMakeRange(range.location, range.length)];
    //    }
    return string;
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
            //            NSUInteger location=range.location;
            NSString * fileName = [string.string substringWithRange:NSMakeRange(range.location, range.length)];
            BOOL PageImage=YES;
            NSAttributedString *str=[self parseImageDataFromgetWith:fileName withLocation:range.location isPageImage:PageImage isLineImage:YES];
            [string replaceCharactersInRange:NSMakeRange(range.location, range.length) withAttributedString:str];
            [self getTheContentRegexString:string];
        }
    }
    return string;
}

-(NSMutableAttributedString *)getTheContentRegexString:(NSMutableAttributedString *)string with:(NSRange)range
{
    if (!string) {
        return string;
    }
    
//    NSError *error = nil;
//    NSString *sReg =@"<ContentImg[^>]+src\\s*=\\s*['\"]([^'\"]+)['\"][^>]*>";
//    NSRegularExpression * reg = [NSRegularExpression regularExpressionWithPattern:sReg options:NSRegularExpressionCaseInsensitive error:&error];
//    if (error == nil && reg)
//    {
//        NSRange range=[reg rangeOfFirstMatchInString:string.string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
        if (range.location!=NSNotFound)
        {
//            NSUInteger location=range.location;
            NSString * fileName = [string.string substringWithRange:NSMakeRange(range.location, range.length)];
            BOOL PageImage=YES;
            NSAttributedString *str=[self parseImageDataFromgetWith:fileName withLocation:range.location isPageImage:PageImage isLineImage:YES];
            [string replaceCharactersInRange:NSMakeRange(range.location, range.length) withAttributedString:str];
            [self getTheContentRegexString:string];
        }
//    }
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
    NSString *path=[LoadPath stringByAppendingPathComponent:Name];
    UIImage *image=[UIImage imageWithContentsOfFile:path];
    float width=image.size.width;
    float height=image.size.height;
    image=nil;
    
    if (isInLine)
    {
        [self changeInLineImageWidth:width AndHeight:height];
    }
    else
        [self changeWidth:width AndHeight:height];
    
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
    
    [_imageArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",_NTWidth], @"width",[NSString stringWithFormat:@"%f",_NTHeight], @"height",Name, @"fileName",[NSNumber numberWithUnsignedInteger:loaction], @"location",[NSNumber numberWithBool:pageImage],@"PageImage",[NSNumber numberWithBool:isInLine],@"inLineImage",nil]];
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(dict));
    
    // 使用0xFFFC作为空白的占位符
    unichar objectReplacementChar = 0xFFFC;
    NSString * content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString * space = [[NSMutableAttributedString alloc] initWithString:content];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1),
                                   kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    return space;
}

-(NSDictionary *)getTheStringAttributesWith:(NSString *)name withLocation:(NSUInteger)loaction isPageImage:(BOOL)pageImage isLineImage:(BOOL)isInLine;
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
    NSString *path=[LoadPath stringByAppendingPathComponent:Name];
    UIImage *image=[UIImage imageWithContentsOfFile:path];
    float width=image.size.width;
    float height=image.size.height;
    image=nil;
    
    if (isInLine)
    {
        [self changeInLineImageWidth:width AndHeight:height];
    }
    else
        [self changeWidth:width AndHeight:height];

    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    callbacks.dealloc = deallocCallback;
    NSDictionary* imgAttr = [NSDictionary dictionaryWithObjectsAndKeys: //2
                             [NSNumber numberWithFloat:_NTWidth], @"width",
                             [NSNumber numberWithFloat:_NTHeight], @"height",
                             nil];
    [_imageArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",_NTWidth], @"width",[NSString stringWithFormat:@"%f",_NTHeight], @"height",Name, @"fileName",[NSNumber numberWithUnsignedInteger:loaction], @"location",[NSNumber numberWithBool:pageImage],@"PageImage",[NSNumber numberWithBool:isInLine],@"inLineImage",nil]];
    
    
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(imgAttr)); //3
    NSDictionary *attrDictionaryDelegate = [NSDictionary dictionaryWithObjectsAndKeys:
                                            //set the delegate
                                            (__bridge id)delegate, (NSString*)kCTRunDelegateAttributeName,
                                            nil];
    CFRelease(delegate);
    return attrDictionaryDelegate;
}

-(void)changeInLineImageWidth:(float)width AndHeight:(float)height
{
//    float iheight=19;
    _NTHeight=5*height/12;
    _NTWidth=5*width/12;
}

-(void)changeWidth:(float)width AndHeight:(float)height
{
    float iwidth=_NTframe.size.width-44;
    float iheight=_NTframe.size.height-85;
    if (width>iwidth&&width>=height)
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
    else if(width<iwidth&&width>=height)
    {
        _NTWidth=width;
        _NTHeight=height;
    }
    else if(width<iwidth&&width<height)
    {
        if (height<iheight)
        {
            _NTHeight=height;
            _NTWidth=width;
        }
        else
        {
            _NTWidth=(width*iheight)/height;
            _NTHeight=iheight;
        }
    }
}

-(void)attachImagesWithFrame:(CTFrameRef)f index:(int)iindex
{
    NSArray *lines = (NSArray *)CTFrameGetLines(f); //1
    CGPoint origins[[lines count]];
    CTFrameGetLineOrigins(f, CFRangeMake(0, 0), origins); //2
    
    int imgIndex = iindex; //3
    NSDictionary* nextImage = [_imageArray objectAtIndex:imgIndex];
    int imgLocation = [[nextImage objectForKey:@"location"] intValue];
    
    //find images for the current column
    CFRange frameRange = CTFrameGetVisibleStringRange(f); //4
    while ( imgLocation < frameRange.location )
    {
        imgIndex++;
        if (imgIndex>=[_imageArray count]) return; //quit if no images for this column
        nextImage = [_imageArray objectAtIndex:imgIndex];
        imgLocation = [[nextImage objectForKey:@"location"] intValue];
    }
    NSUInteger lineIndex = 0;
    for (id lineObj in lines)
    { //5
        CTLineRef line = (__bridge CTLineRef)lineObj;
        
        for (id runObj in (NSArray *)CTLineGetGlyphRuns(line))
        { //6
            CTRunRef run = (__bridge CTRunRef)runObj;
            CFRange runRange = CTRunGetStringRange(run);
            if ( runRange.location <= imgLocation && runRange.location+runRange.length > imgLocation )
            { //7
                CGRect runBounds;
                runBounds.origin.x = origins[lineIndex].x;
                runBounds.origin.y = origins[lineIndex+1].y;
                runBounds.origin.y = origins[lineIndex].y;
                float value=  CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                runBounds.origin.x =value;
                NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
                [dic setObject:[NSString stringWithFormat:@"%@/%@",LoadPath,[nextImage objectForKey:@"fileName"]] forKey:@"imageName"];
                [dic setObject:[NSNumber numberWithFloat:runBounds.origin.x] forKey:@"imageX"];
                [dic setObject:[NSNumber numberWithFloat:runBounds.origin.y] forKey:@"imageY"];
                [dic setObject:[nextImage objectForKey:@"width"] forKey:@"imageWidth"];
                [dic setObject:[nextImage objectForKey:@"height"] forKey:@"imageHeight"];
                [dic setObject:[nextImage objectForKey:@"PageImage"] forKey:@"PageImage"];
                [dic setObject:[nextImage objectForKey:@"inLineImage"] forKey:@"inLineImage"];
                [_imageInfoArray addObject:dic];
                dic=nil;
            }
        }
        lineIndex++;
    }
    imgIndex++;
    if (imgIndex>=[_imageArray count]) return; //quit if no images for this column
    nextImage = [_imageArray objectAtIndex:imgIndex];
    imgLocation = [[nextImage objectForKey:@"location"] intValue];
    if (imgLocation>frameRange.location&&imgLocation<frameRange.location+frameRange.length)
    {
        [self attachImagesWithFrame:f index:imgIndex];
    }
    lines=nil;
    nextImage=nil;
}

#pragma mark - getCatalog -

-(void)getTheCatalog
{
    //_testAry
    if (_NcxCatalogArray.count==_CatalogPageArray.count)
    {
        for (int i=0;i<_NcxCatalogArray.count;i++)
        {
            NSMutableDictionary *dic=[_NcxCatalogArray objectAtIndex:i];
            [dic setObject:[_CatalogPageArray objectAtIndex:i] forKey:@"localPoint"];
        }
    }
    _CatalogPageArray=nil;
    NSString *myDirectory = [BasePath stringByAppendingPathComponent:@"Catalog"];
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:_NcxCatalogArray forKey:@"catalog"];
    [dic setObject:[NSNumber numberWithInt:_NTAllPage] forKey:@"pageNum"];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dic forKey:@"NO Key Value"];
    [archiver finishEncoding];
    [data writeToFile:myDirectory atomically:YES];
    data=nil;
    dic=nil;
}

-(BOOL)haveTheCatalog
{
    NSString *myDirectory = [BasePath stringByAppendingPathComponent:@"Catalog"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:myDirectory])
    {
        NSData *data = [[NSMutableData alloc] initWithContentsOfFile:myDirectory];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        NSMutableDictionary *dic = [unarchiver decodeObjectForKey:@"NO Key Value"];
        [unarchiver finishDecoding];
        _NcxCatalogArray =[dic objectForKey:@"catalog"];
        _NTAllPage=[[dic objectForKey:@"pageNum"] intValue];
        dic=nil;
        data=nil;
        return YES;
    }
    return NO;
}

#pragma mark - 读写目录信息 -
-(void)writefileWithAry:(NSMutableArray *)ary
{
    NSString *myDirectory = [BasePath stringByAppendingPathComponent:@"CatalogINfo"];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:ary forKey:@"NO Key Value"];
    [archiver finishEncoding];
    [data writeToFile:myDirectory atomically:YES];
    data=nil;
}

-(void)getCatalogInfoArry
{
    NSString *myDirectory = [BasePath stringByAppendingPathComponent:@"CatalogINfo"];
    NSData *data = [[NSMutableData alloc] initWithContentsOfFile:myDirectory];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    _CatalogInfoArray = [unarchiver decodeObjectForKey:@"NO Key Value"];
    [unarchiver finishDecoding];
    data=nil;
}

#pragma mark - 读阅读进度 -
-(void)getReadHistory
{
    NSString *myDirectory = [BasePath stringByAppendingPathComponent:@"BookHistory"];
    NSData *data = [[NSMutableData alloc] initWithContentsOfFile:myDirectory];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSMutableDictionary *dic = [unarchiver decodeObjectForKey:@"NO Key Value"];
    [unarchiver finishDecoding];
//    _allPage=[[dic objectForKey:@"allPage"] intValue];
    _currentPage=[[dic objectForKey:@"ReadPage"] intValue];
    _currentHtml=[dic objectForKey:@"currentHtml"];
    if (!_currentHtml&&_currentPage==0&&_CatalogInfoArray&&_CatalogInfoArray.count>0)
    {
        _currentPage=0;
        _currentHtml=[[_CatalogInfoArray objectAtIndex:0] objectForKey:@"htmlName"];
    }
    
    data=nil;
    dic=nil;
}

#pragma mark - 读写html缓存 -
-(void)writeHtmlInfoWith:(NSMutableAttributedString*)str withName:(NSString *)name
{
//    NSMutableAttributedString *sddd=[[NSMutableAttributedString alloc] initWithString:str.string];
    NSString *Name=[XSLAESCrypt xslmd5:name];
    NSString *myDirectory = [BasePath stringByAppendingPathComponent:Name];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:str forKey:@"NO Key Value"];
    [archiver finishEncoding];
    [data writeToFile:myDirectory atomically:YES];
    data=nil;
}

-(NSMutableAttributedString *)GetHtmlInfoWithName:(NSString *)name
{
    NSString *Name=[XSLAESCrypt xslmd5:name];
    NSString *myDirectory = [BasePath stringByAppendingPathComponent:Name];
    NSData *data = [[NSMutableData alloc] initWithContentsOfFile:myDirectory];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSMutableAttributedString *str = [unarchiver decodeObjectForKey:@"NO Key Value"];
    return str;
}

#pragma mark - 读写PagePoint -
-(void)writePagePointInfoWith:(NSMutableDictionary*)dic withName:(NSString *)name
{
    NSString *path=[BasePath stringByAppendingPathComponent:@"PointCache"];
    NSFileManager *fileManager=[[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:path])
    {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *Name=[XSLAESCrypt xslmd5:name];
    NSString *myDirectory = [path stringByAppendingPathComponent:Name];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dic forKey:@"NO Key Value"];
    [archiver finishEncoding];
    [data writeToFile:myDirectory atomically:YES];
    data=nil;
}

-(void)writefileWithDic:(NSMutableDictionary *)dic
{
//    NSData *aStringData = [NSKeyedArchiver archivedDataWithRootObject:self.attributedMessage];
    NSString *myDirectory = [BasePath stringByAppendingPathComponent:@"ALLPageINfo"];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dic forKey:@"NO Key Value"];
    [archiver finishEncoding];
    [data writeToFile:myDirectory atomically:YES];
    data=nil;
}

-(void)writefileWithDic:(NSMutableDictionary *)dic withName:(NSString *)name
{
    if (dic&&[dic allKeys].count>0)
    {
        NSString *Name=[XSLAESCrypt xslmd5:name];
        NSString *myDirectory = [BasePath stringByAppendingPathComponent:Name];
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:dic forKey:@"NO Key Value"];
        [archiver finishEncoding];
        [data writeToFile:myDirectory atomically:YES];
        data=nil;
    }
}

-(void)dealloc
{
//    NSLog(@"==dealloc==%@",self.class);
    _AllPageInfo=nil;
    _CatalogInfoArray=nil;
    _NcxCatalogArray=nil;
    _imageInfoArray=nil;
    _CatalogArray=nil;
    _imageArray=nil;
}

@end
