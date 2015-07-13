//
//  define.h
//  NTEpubReader
//
//  Created by 李莹 on 15/7/13.
//  Copyright (c) 2015年 NT. All rights reserved.
//

#ifndef NTEpubReader_define_h
#define NTEpubReader_define_h
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define MainHeight (ScreenHeight -StateBarHeight)
#define MainWidth ScreenWidth
#define CELL_LINE_COLOR [UIColor colorWithHexString:@"#DDDDDD"]
#define iOS7 (([[[UIDevice currentDevice] systemVersion] floatValue]>=7)?YES:NO)
#define NTWhiteColor @"#FDFEFC"
#define NTLightGreenColor @"F2F7EE"    //最浅的绿
#define NTlightGrayColor @"FAFAFA" //浅灰色
#define NTGrayColor @"EEEEEE" //灰色
#define NTTextGrayColor @"A0A0A0" //灰色
#define NavigationBarColor @"#57AD57"
#define NavBarCol [UIColor colorWithHexString:NavigationBarColor]
#define DESC_FONT_COLOR [UIColor colorWithHexString:@"#333333"]
#define getSMS @"fdb17e"
#define AES_KEY @"xingshulin.com.!#%@)@*^!^*" //密钥
#define DOCUMENT_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#endif
