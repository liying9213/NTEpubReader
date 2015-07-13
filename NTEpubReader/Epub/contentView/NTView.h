//
//  NTView.h
//  NTCoreTextReader
//
//  Created by liying on 14-6-27.
//  Copyright (c) 2014年 liying. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreText/CoreText.h>

@class NTView;
@protocol NTViewDelegate

@required
-(void)TouchUpForImage:(NSString*)imagePath withYValue:(float)YValue WithImage:(UIImage*)image;

@required
-(void)TouchUpForSelect:(CGPoint)point;

@required
-(void)TouchUpForSelectFootNote:(NSString *)footNote withHtml:(NSString*)name withPoint:(CGPoint)point;

@required
-(void)TouchUpForSelectURL:(NSString *)URL;

@end


@interface NTView : UIView
{
    id NCTFrame;
    BOOL isurl;
    CGPoint touchPoint;
}

@property (nonatomic,strong)NSMutableArray *imageAry;

@property (nonatomic,strong)NSMutableArray *NTImageAry;

@property (nonatomic,strong)NSString *currentName;

@property (nonatomic,weak)id delegate;

@property (nonatomic,assign)BOOL isSearch;

-(void)setNCTFrame:(id)frame;

@end
