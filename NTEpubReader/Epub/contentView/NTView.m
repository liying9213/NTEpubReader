//
//  NTView.m
//  NTCoreTextReader
//
//  Created by liying on 14-6-27.
//  Copyright (c) 2014年 liying. All rights reserved.
//

#import "NTView.h"
#import "define.h"
@implementation NTView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        _NTImageAry=[[NSMutableArray array] init];
    }
    return self;
}

-(void)setNCTFrame:(id)frame
{
    NCTFrame=frame;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    if (_imageAry&&_imageAry.count>0)
    {
        for (NSDictionary *dic in _imageAry)
        {
            UIImage *image = [UIImage imageWithContentsOfFile:[dic objectForKey:@"imageName"]];
            CGRect imageDrawRect;
            imageDrawRect.size.width =[[dic objectForKey:@"imageWidth"] floatValue];
            imageDrawRect.size.height =[[dic objectForKey:@"imageHeight"] floatValue];
            if ([[dic objectForKey:@"imageWidth"] floatValue]<MainWidth-44&&[[dic objectForKey:@"imageX"] floatValue]==0&&![[dic objectForKey:@"PageImage"] boolValue]&&![[dic objectForKey:@"inLineImage"] boolValue])
            {
                imageDrawRect.origin.x = (MainWidth-44-[[dic objectForKey:@"imageWidth"] floatValue])/2;
            }
            else
                imageDrawRect.origin.x =[[dic objectForKey:@"imageX"] floatValue];
            float yvalue=0;
            if ([[dic objectForKey:@"inLineImage"] boolValue])
            {
                yvalue=5;
            }
            imageDrawRect.origin.y = [[dic objectForKey:@"imageY"] floatValue]-yvalue;
            CGContextDrawImage(context, imageDrawRect, image.CGImage);
            if (image) {
                [_NTImageAry addObject:image];
            }
        }
    }
    NSArray *lines = (NSArray *)CTFrameGetLines((CTFrameRef)NCTFrame);
    if (lines.count)
    {
        CGPoint *lineOrigins = malloc(lines.count * sizeof(CGPoint));
        CTFrameGetLineOrigins((CTFrameRef)NCTFrame, CFRangeMake(0, lines.count), lineOrigins);
        int i = 0;
        for (id aLine in lines)
        {
            NSArray *glyphRuns = (NSArray *)CTLineGetGlyphRuns((CTLineRef)aLine);
            CGFloat width =lineOrigins[i].x-lineOrigins[0].x;
            CGFloat height =lineOrigins[i].y;
            for (id run in glyphRuns)
            {
                CFDictionaryRef dicRef=CTRunGetAttributes((CTRunRef)run);
                NSDictionary *dic=(__bridge NSDictionary *)dicRef;
                if ([dic objectForKey:@"NSBackgroundColor"]!=nil&&_isSearch==YES)
                {
                    UIColor *BGColor=[dic objectForKey:@"NSBackgroundColor"];
                    CGPoint *ary=(CGPoint *)CTRunGetPositionsPtr((CTRunRef)run);
                    CGFloat runAscent,runDescent;
                    float RunWidth=CTRunGetTypographicBounds((CTRunRef)run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
                    CGFloat runHeight = runAscent + (runDescent);
                    CGRect rectangle = CGRectMake(ary[0].x, height-runDescent, RunWidth, runHeight);
                    CGContextSetFillColorWithColor(context,BGColor.CGColor);
                    CGContextFillRect(context , rectangle);
                }
                if ([[dic objectForKey:@"NSSuperScript"] stringValue]!=nil)
                {
                    NSString *value=[[dic objectForKey:@"NSSuperScript"] stringValue];
                    CGFloat baselineAdjust;
                    if ([value isEqualToString:@"1"])
                    {
                        baselineAdjust = 6;
                        CGContextSetTextPosition(context, width, height+5);
                        CTRunDraw((CTRunRef)run, context, CFRangeMake(0, 0));
                    }
                    else
                    {
                        CGContextSetTextPosition(context, 0, height);
                        CTRunDraw((CTRunRef)run, context, CFRangeMake(0, 0));
                    }
                }
                else
                {
                    CGContextSetTextPosition(context, 0,height);
                    CTRunDraw((CTRunRef)run, context, CFRangeMake(0, 0));
                }
            }
            i++;
        }
        
        free(lineOrigins);
    }
}

- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    //获取触摸点击当前view的坐标位置
    CGPoint location = [touch locationInView:self];
    float reverseY=self.frame.size.height-location.y;
    BOOL ishaveImage=NO;
    isurl=NO;
    touchPoint=location;
    NSString *footnote=[self dataForPoint:location];
    if (footnote)
    {
        if (isurl) {
            [_delegate TouchUpForSelectURL:footnote];
            return;
        }
        [_delegate TouchUpForSelectFootNote:footnote withHtml:_currentName withPoint:touchPoint];
        return;
    }
    
    if (_imageAry&&_imageAry.count>0)
    {
        int i=0;
        for (NSDictionary *dic in _imageAry)
        {
            float imageY=[[dic objectForKey:@"imageY"] floatValue];
            float imageHeight=[[dic objectForKey:@"imageHeight"] floatValue];
            float imageWidth=[[dic objectForKey:@"imageWidth"] floatValue];
            BOOL PageImage=[[dic objectForKey:@"PageImage"] floatValue];
            BOOL inLineImage=[[dic objectForKey:@"inLineImage"] boolValue];
            if (reverseY>imageY&&reverseY<imageHeight+imageY&&!PageImage&&imageWidth+22>=location.x&&!inLineImage)
            {
                ishaveImage=YES;
                double value=self.frame.size.height-imageY-imageHeight;
                double integer;
                modf(value,&integer);
                
               double ivalue= round(value*100)/100;

                [_delegate TouchUpForImage:[dic objectForKey:@"imageName"] withYValue:(ivalue+50) WithImage:[_NTImageAry objectAtIndex:i]];
                break;
            }
            i++;
        }
        if (!ishaveImage)
        {
            [_delegate TouchUpForSelect:location];
        }
    }
    else
    {
        [_delegate TouchUpForSelect:location];
    }
}

- (NSString *)dataForPoint:(CGPoint)point
{
    NSArray *lines = (NSArray *)CTFrameGetLines((CTFrameRef)NCTFrame);
    NSInteger lineCount = [lines count];
    CGPoint origins[lineCount];
    if (lineCount != 0) {
        CTFrameGetLineOrigins((CTFrameRef)NCTFrame, CFRangeMake(0, 0), origins);
        for (int i = 0; i < lineCount; i++)
        {
            CGPoint baselineOrigin = origins[i];
            //the view is inverted, the y origin of the baseline is upside down
            baselineOrigin.y = CGRectGetHeight(self.frame) - baselineOrigin.y;
            
            CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:i];
            CGFloat ascent, descent;
            CGFloat lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
            
            CGRect lineFrame = CGRectMake(baselineOrigin.x, baselineOrigin.y - ascent, lineWidth, ascent + descent);
            if (CGRectContainsPoint(lineFrame, point))
            {
                CFIndex index = CTLineGetStringIndexForPosition(line, point);
                CFArrayRef runs = CTLineGetGlyphRuns(line);
                CGFloat width = 0.0;
                for(CFIndex j = 0; j < CFArrayGetCount(runs); j++)
                {
                    CTRunRef run = CFArrayGetValueAtIndex(runs, j);
                    NSDictionary* attributes = (NSDictionary*)CTRunGetAttributes(run);
                    
                    NSString *name = [attributes objectForKey:@"footnote"];
                    NSString *url = [attributes objectForKey:@"URL"];
                    CFRange range= CTRunGetStringRange(run);
                    CGFloat ascent = 0.0f;
                    CGFloat descent = 0.0f;
                    CGFloat lineWidth =  CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
                    width+=lineWidth;
                    if (index >= range.location + range.length-2&& index <= range.location + range.length+2&&name.length>1)
                    {
                        touchPoint.x=width+3.5;
                        touchPoint.y=lineFrame.origin.y;
                        isurl=NO;
                        return name;
                    }
                    if (index >= range.location && index <= range.location + range.length&&url.length>1)
                    {
                        isurl=YES;
                        return url;
                    }
                }
            }
        }
    }
    
    return nil;
}

-(void)dealloc
{
//    NSLog(@"==dealloc==%@",self.class);
    _imageAry=nil;
    _delegate=nil;
}



@end
