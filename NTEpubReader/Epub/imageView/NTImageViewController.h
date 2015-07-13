//
//  NTImageViewController.h
//  NTCoreTextReader
//
//  Created by liying on 14-7-3.
//  Copyright (c) 2014年 liying. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTImageView.h"
@interface NTImageViewController : UIViewController

@property (nonatomic, strong)NSString *imagePath;
@property (nonatomic, weak)id delegate;
@property (nonatomic, assign)float imageYValue;
@property (nonatomic, strong)NTImageView *imageView;
@property (nonatomic, strong)UIImage *image;
@property (nonatomic)float imageLeftValue;
@property (nonatomic)float imageUpValue;
@property (nonatomic)float imageHeight;
@property (nonatomic)float imageWeight;
@property (nonatomic) UIInterfaceOrientation NTinterfaceOrientation;
@property (nonatomic) UIDeviceOrientation NTOrientation;
@property (nonatomic) UIDeviceOrientation NTFromOrientation;
@property (nonatomic, assign)BOOL isCanTransform;
@end
