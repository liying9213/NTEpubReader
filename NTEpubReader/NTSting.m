//
//  NTSting.m
//  MPlatform
//
//  Created by 李莹 on 15/5/5.
//
//

#import "NTSting.h"

@implementation NTSting

+ (CGFloat)getTheSizeHeightWithFont:(UIFont*)Font WithWide:(float)Width withString:(NSString *)str
{
    if (!str||[str isEqualToString:@""])
    {
        return 0;
    }
    
    NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           Font, NSFontAttributeName,
                           nil];
    NSMutableAttributedString *theStr=[[NSMutableAttributedString alloc] initWithString:str attributes:attrs];
    long number = 1;
    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
    [theStr addAttribute:NSKernAttributeName value:(__bridge id)(num) range:NSMakeRange(0,[theStr length])];
    CFRelease(num);
    CGRect paragraphRect =
    [theStr boundingRectWithSize:CGSizeMake(Width, CGFLOAT_MAX)
                         options:(NSStringDrawingUsesLineFragmentOrigin)
                         context:nil];
    attrs=nil;
    theStr=nil;
    return paragraphRect.size.height;
    
//    CGSize  Size =[str sizeWithFont:Font constrainedToSize:CGSizeMake(Width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
//    return Size.height;
}

+ (CGFloat)getTheSizeWidthWithFont:(UIFont*)Font WithHeight:(float)Height withString:(NSString *)str
{
    if (!str||[str isEqualToString:@""])
    {
        return 0;
    }
    
    NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           Font, NSFontAttributeName,
                           nil];
    NSMutableAttributedString *theStr=[[NSMutableAttributedString alloc] initWithString:str attributes:attrs];
    long number = 1;
    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
    [theStr addAttribute:NSKernAttributeName value:(__bridge id)(num) range:NSMakeRange(0,[theStr length])];
    CFRelease(num);
    CGRect paragraphRect =
    [theStr boundingRectWithSize:CGSizeMake(MAXFLOAT, Height)
                         options:(NSStringDrawingUsesLineFragmentOrigin)
                         context:nil];
    attrs=nil;
    theStr=nil;
    return paragraphRect.size.width;

//    CGSize  Size =[str sizeWithFont:Font constrainedToSize:CGSizeMake(MAXFLOAT, Height) lineBreakMode:NSLineBreakByWordWrapping];
//    str=nil;
//    return Size.height;
}

+ (CGFloat)getTheSizeHeightWithWide:(float)Width withAttributedString:(NSAttributedString *)str
{
    if (!str)
    {
        return 0;
    }
    
    NSMutableAttributedString *theStr=[[NSMutableAttributedString alloc] initWithAttributedString:str];
    long number = 1;
    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
    [theStr addAttribute:NSKernAttributeName value:(__bridge id)(num) range:NSMakeRange(0,[theStr length])];
    CFRelease(num);
    CGRect paragraphRect =
    [theStr boundingRectWithSize:CGSizeMake(Width, CGFLOAT_MAX)
                         options:(NSStringDrawingUsesLineFragmentOrigin)
                         context:nil];
    theStr=nil;
    return paragraphRect.size.height;
}

@end
