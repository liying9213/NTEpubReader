//
//  NTContentViewController.h
//  NTCoreTextReader
//
//  Created by liying on 14-6-27.
//  Copyright (c) 2014年 liying. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
@interface NTContentViewController : UIViewController

@property (nonatomic,strong) NSAttributedString *htmlStr;

@property (nonatomic,assign)int textPos; //3
@property (nonatomic,assign)int beforePos;
@property (nonatomic,assign)int beforelength;
@property (nonatomic,assign)CFIndex currentlength;
@property (nonatomic,assign)int columnIndex;
@property (nonatomic,assign)int NTbookID;
@property (nonatomic,assign)int allColumnCount;
@property (nonatomic,strong)NSString * bookName;
@property (nonatomic,assign)CTFrameRef iframe;
@property (nonatomic,strong)NSMutableDictionary *pageInfo;
@property (nonatomic,weak)id delegate;
@property (nonatomic,strong)NSString *str;
@property (nonatomic,assign)int PageType;//0 current -1 before 1 after
@property (nonatomic,assign)BOOL isGuide;
@property (nonatomic,strong)NSMutableArray*catalogArray;
@property (nonatomic,assign)BOOL isSearch;
@end
