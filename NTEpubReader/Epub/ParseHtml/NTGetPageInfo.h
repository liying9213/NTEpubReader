//
//  NTGetPageInfo.h
//  NTCoreTextReader
//
//  Created by liying on 14-6-27.
//  Copyright (c) 2014年 liying. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
@interface NTGetPageInfo : NSObject
{
    NSString *LoadPath;
    NSString *BasePath;
    BOOL isFirstParse;
}
@property (nonatomic,strong)NSMutableDictionary *AllPageInfo;

@property (nonatomic,assign)int  allPage;

@property (nonatomic,assign)int  NTAllPage;

@property (nonatomic,strong)NSMutableArray *imageArray;

@property (nonatomic,strong)NSMutableArray *imageInfoArray;

@property (nonatomic,strong)NSMutableArray *CatalogArray;

@property (nonatomic,strong)NSMutableArray *CatalogPageArray;

@property (nonatomic,assign)int catalogTier;

@property (nonatomic,strong)NSMutableArray *NcxCatalogArray;

@property (nonatomic,assign)CGRect NTframe;

@property (nonatomic,strong)NSMutableArray *CatalogInfoArray;

@property (nonatomic,assign)int currentPage;

@property (nonatomic,strong)NSString *currentHtml;

@property (nonatomic,strong)NSString *bookID;

@property (nonatomic,strong)NSMutableArray *PathAry;

@property (nonatomic,strong)NSMutableArray *testAry;

@property (nonatomic) float NTWidth;

@property (nonatomic) float NTHeight;

-(id)initWithTheBookID:(NSString *)bookName;

-(NSMutableDictionary *)getTheEpubPageInfoWithPath:(NSString *)path withFrame:(CGRect)frame;

-(void)getTheStringFromName:(NSString *)name withThepage:(int)page;

-(NSMutableDictionary *)getTheSearchStringFromName:(NSString *)name withThepage:(int)page WithPoint:(NSArray *)pointAry WithLength:(float)length;

-(void)parseHtmlAgain:(BOOL)isAgain;
@end
