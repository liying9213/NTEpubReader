//
//  NTFontRegister.m
//  MPlatform
//
//  Created by 李莹 on 14-12-24.
//
//

#import "NTFontRegister.h"
#import "define.h"
#import <CoreText/CoreText.h>
@implementation NTFontRegister

+(void)RegisterFont
{
    [self RegisterFontFrom:[DOCUMENT_PATH stringByAppendingPathComponent:@"NTFonts"]];
}

+(void)RegisterFontFrom:(NSString *)path
{
    NSFileManager * filemanager = [NSFileManager defaultManager];
    if ([filemanager fileExistsAtPath:path])
    {
        NSArray  *arr = [filemanager  contentsOfDirectoryAtPath:path error:nil];
        for (NSString *fontname in arr)
        {
            if ([fontname rangeOfString:@".ttf"].location != NSNotFound)
            {
                NSString * fontPath = [path stringByAppendingPathComponent:fontname];
                NSURL * url = [NSURL fileURLWithPath:fontPath];
                CFErrorRef error;
                CTFontManagerRegisterFontsForURL((__bridge CFURLRef)url, kCTFontManagerScopeProcess, &error);
            }
        }
    }
}
@end
