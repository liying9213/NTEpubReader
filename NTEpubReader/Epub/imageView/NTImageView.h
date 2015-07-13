//
//  NTImageView.h
//  NTCoreTextReader
//
//  Created by liying on 14-7-3.
//  Copyright (c) 2014年 liying. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NTImageView;

@protocol NTImageViewDelegate <NSObject>

@required

-(void)closeTheImageView;

@end

@interface NTImageView : UIScrollView<UIScrollViewDelegate>
{
    CGFloat imageValue;
}

@property (nonatomic, strong)NSString *imagePath;

@property (nonatomic, strong)UIImageView *imageView;

@property (nonatomic, assign)id idelegate;

@property (nonatomic, strong)UIImage *image;

@property (nonatomic, assign)float imageYValue;

@property (nonatomic, assign)CGRect imageRect;

-(void)ResetView;
-(void)changeImageView:(UIImageView *)imageview;
@end
