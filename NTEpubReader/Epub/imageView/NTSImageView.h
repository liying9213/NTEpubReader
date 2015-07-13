//
//  NTSImageView.h
//  MPlatform
//
//  Created by 李莹 on 14-10-16.
//
//

#import <UIKit/UIKit.h>
#import "NTImageView.h"

@class NTSImageView;

@protocol NTSImageViewDelegate <NSObject>

@required

-(void)closeTheSImageView;

@end

@interface NTSImageView : UIView<NTImageViewDelegate>

@property (nonatomic, strong)NTImageView *imageView;
@property (nonatomic, strong)UIView *backView;
@property (nonatomic)float imageYValue;
@property (nonatomic)float imageLeftValue;
@property (nonatomic)float imageUpValue;
@property (nonatomic)float imageHeight;
@property (nonatomic)float imageWeight;
@property (nonatomic, strong)UIImage *image;
@property (nonatomic,assign)id sdelegate;

-(id)initWithFrame:(CGRect)frame withYValue:(float)YValue With:(UIImage*)image;

-(void)ResetViewWith:(UIImage *)image With:(float)YValue;
@end
