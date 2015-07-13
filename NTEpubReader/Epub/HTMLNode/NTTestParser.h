//
//  NTTestParser.h
//  NTCoreTextReader
//
//  Created by liying on 14-7-7.
//  Copyright (c) 2014年 liying. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
@interface NTTestParser : NSObject

@property (strong, nonatomic) NSMutableArray* images;
@property (nonatomic, strong) NSMutableArray* CatalogArray;
@property (nonatomic, assign) CGRect NTFrame;
@property (nonatomic) float NTWidth;
@property (nonatomic) float NTHeight;
@property (nonatomic, strong)NSString *localPath;
@property (nonatomic, strong)NSMutableArray *testAry;
@property (nonatomic, strong)NSMutableDictionary *pointDic;
@property (nonatomic, assign)BOOL iscopyright;
-(id)initWithThe:(CGRect)frame WithTheLocalPath:(NSString *)path;

-(NSMutableAttributedString *)ParserHtml:(NSString *)html withName:(NSString*)Name;

@end
