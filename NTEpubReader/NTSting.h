//
//  NTSting.h
//  MPlatform
//
//  Created by 李莹 on 15/5/5.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NTSting : NSString

+ (CGFloat)getTheSizeHeightWithFont:(UIFont*)Font WithWide:(float)Width withString:(NSString *)str;

+ (CGFloat)getTheSizeWidthWithFont:(UIFont*)Font WithHeight:(float)Height withString:(NSString *)str;

+ (CGFloat)getTheSizeHeightWithWide:(float)Width withAttributedString:(NSAttributedString *)str;
@end
