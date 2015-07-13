//
//  NTSImageView.m
//  MPlatform
//
//  Created by 李莹 on 14-10-16.
//
//

#import "NTSImageView.h"

@implementation NTSImageView

-(id)initWithFrame:(CGRect)frame withYValue:(float)YValue With:(UIImage*)image
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _imageYValue=YValue;
        _backView=[[UIView alloc] initWithFrame:self.frame];
        _backView.backgroundColor=[UIColor blackColor];
        [self addSubview:_backView];
        
        _imageView=[[NTImageView alloc] initWithFrame:self.frame];
        _imageView.idelegate=self;
        [self addSubview:_imageView];
        _imageView.imageYValue=YValue;
        _imageView.image=image;
        [_imageView ResetView];
        _imageLeftValue=_imageView.imageView.frame.size.width;
        _imageUpValue=_imageView.imageView.frame.origin.y;
        _imageWeight=_imageView.imageView.frame.size.width;
        _imageHeight=_imageView.imageView.frame.size.height;
        [self BeginAnimationsWith:YValue];
    }
    return self;
}

-(void)ResetViewWith:(UIImage *)image With:(float)YValue
{
    _imageYValue=YValue;
    _imageView.imageYValue=YValue;
    _imageView.imageView.image=image;
    [_imageView changeImageView:_imageView.imageView];
    _imageLeftValue=_imageView.imageView.frame.size.width;
    _imageUpValue=_imageView.imageView.frame.origin.y;
    _imageWeight=_imageView.imageView.frame.size.width;
    _imageHeight=_imageView.imageView.frame.size.height;
    [self BeginAnimationsWith:YValue];
}

-(void)BeginAnimationsWith:(float)YValue
{
    CABasicAnimation * outOpacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    outOpacityAnimation.fromValue = @0.5f;
    outOpacityAnimation.toValue = @1.0f;
    outOpacityAnimation.duration = 0.3;
    [_backView.layer addAnimation:outOpacityAnimation forKey:nil];
    
    CABasicAnimation * inSwipeAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    inSwipeAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    inSwipeAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, YValue-_imageUpValue-_imageHeight*0.075, 0.0f)];
    
    CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    pulse.fromValue = [NSNumber numberWithFloat:.85];
    pulse.toValue = [NSNumber numberWithFloat:1];
    
    CAAnimationGroup * inAnimation = [CAAnimationGroup animation];
    inAnimation.animations = @[inSwipeAnimation,pulse];
    inAnimation.duration = 0.3;
    inAnimation.removedOnCompletion = NO;
    
    [_imageView.imageView.layer addAnimation:inAnimation forKey:nil];
}

-(void)closeTheImageView
{
    [self closeAnimations];
}

-(void)closeAnimations
{
    CABasicAnimation * outOpacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    outOpacityAnimation.fromValue = @1.0f;
    outOpacityAnimation.toValue = @0.0f;
    outOpacityAnimation.duration = 0.3;
    [_backView.layer addAnimation:outOpacityAnimation forKey:nil];
    
    float leftValue;
    if (self.frame.size.width-_imageWeight>0)
    {
        leftValue=(_imageWeight*0.85-self.frame.size.width)/2+22;
    }
    else
    {
        leftValue=0;
    }

    CABasicAnimation * inSwipeAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    inSwipeAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    inSwipeAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(leftValue, _imageYValue-_imageUpValue-_imageHeight*0.075, 0.0f)];
    
    CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    pulse.fromValue = [NSNumber numberWithFloat:1];
    pulse.toValue = [NSNumber numberWithFloat:0.85];
    
    CAAnimationGroup * inAnimation = [CAAnimationGroup animation];
    inAnimation.animations = @[inSwipeAnimation,pulse];
    inAnimation.duration = 0.3;
    inAnimation.removedOnCompletion = NO;
    
    [_imageView.imageView.layer addAnimation:inAnimation forKey:nil];
    [self performSelector:@selector(closeView) withObject:nil afterDelay:0.29];
}

-(void)closeView
{
    [_sdelegate closeTheSImageView];
    self.hidden=YES;
}

@end
