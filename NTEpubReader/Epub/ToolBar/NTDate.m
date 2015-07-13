//
//  NTDate.m
//  NTCoreTextReader
//
//  Created by liying on 14-7-3.
//  Copyright (c) 2014年 liying. All rights reserved.
//

#import "NTDate.h"

@implementation NTDate

+(void)printfSysDateWithKey:(NSString*)keyWord
{
    NSString* date;
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
    date = [formatter stringFromDate:[NSDate date]];
    NSString * timeNow = [[NSString alloc] initWithFormat:@"%@", date];
    NSLog(@"%@---Time---%@",keyWord,timeNow);
}


@end
