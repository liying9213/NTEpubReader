//
//  NTImageViewController.m
//  NTCoreTextReader
//
//  Created by liying on 14-7-3.
//  Copyright (c) 2014年 liying. All rights reserved.
//

#import "NTImageViewController.h"
#import "NTImageView.h"
#import "UIColor+MyColor.h"
@interface NTImageViewController ()

@end

@implementation NTImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor blackColor];
//    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    _NTOrientation=UIDeviceOrientationPortrait;
    
    [self ResetView];
    
    _imageView.imageYValue=_imageYValue;
    _imageView.image=_image;
    _imageLeftValue=_imageView.imageView.frame.size.width;
    _imageUpValue=_imageView.imageView.frame.origin.y;
    _imageWeight=_imageView.imageView.frame.size.width;
    _imageHeight=_imageView.imageView.frame.size.height;
    [self BeginAnimationsWith:_imageYValue];
    
    CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    pulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    pulse.fromValue =(id)[UIColor colorWithHexString:@"#F4F4EC"].CGColor;
    pulse.toValue =(id)[UIColor blackColor].CGColor;
    pulse.duration=0.3;
    pulse.removedOnCompletion = NO;
    [self.view.layer addAnimation:pulse forKey:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    _isCanTransform=YES;
    [self ChangeTheOrientation];
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)ResetView
{
    _imageView=[[NTImageView alloc] initWithFrame:self.view.frame];
    _imageView.imagePath=_imagePath;
    _imageView.image=_image;
    _imageView.idelegate=self;
    [_imageView ResetView];
    [self.view addSubview:_imageView];
}
-(void)closeTheImageView
{
    if (_NTOrientation!=UIDeviceOrientationPortrait)
    {
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
        self.view.transform = CGAffineTransformMakeRotation(2*M_PI);
        [self OrientationAnimationsTo:[NSValue valueWithCGAffineTransform: CGAffineTransformMakeRotation(2*M_PI)]withTime:0.3];
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        self.view.frame=frame;
        _imageView.frame=frame;
        [_imageView changeImageView:_imageView.imageView];
        _imageView.zoomScale = 1;
        [self performSelector:@selector(closeAnimations) withObject:nil afterDelay:0.3];
        //    [self closeAnimations];
        [self performSelector:@selector(change) withObject:nil afterDelay:0.5];
        [self performSelector:@selector(back) withObject:nil afterDelay:0.55];
    }
    else
    {
        [self closeAnimations];
        [self performSelector:@selector(change) withObject:nil afterDelay:0.2];
        [self performSelector:@selector(back) withObject:nil afterDelay:0.25];
    }
}

-(void)back
{
//    self.view.hidden=YES;
    [self dismissViewControllerAnimated:NO completion:nil];
}
-(void)change
{
    self.view.backgroundColor=[UIColor colorWithHexString:@"#F4F4EC"];
}

-(BOOL)shouldAutorotate
{
    [self ChangeTheOrientation];
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    if (!_isCanTransform)
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    else
        return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (_isCanTransform)
    {
        _NTinterfaceOrientation=toInterfaceOrientation;
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        self.view.frame=frame;
        _imageView.frame=frame;
        [_imageView changeImageView:_imageView.imageView];
        _imageView.zoomScale = 1;
    }
}

-(void)ChangeTheOrientation
{
    if (_NTOrientation==[[UIDevice currentDevice] orientation]||[[UIDevice currentDevice] orientation]==UIDeviceOrientationFaceUp||[[UIDevice currentDevice] orientation]==UIDeviceOrientationUnknown||[[UIDevice currentDevice] orientation]==UIDeviceOrientationPortraitUpsideDown||[[UIDevice currentDevice] orientation]==UIDeviceOrientationFaceDown)
    {
        _isCanTransform=YES;
        return;
    }
    else
    {
        if(_isCanTransform)
        {
            _NTOrientation=[[UIDevice currentDevice] orientation];
        }
    }
    if (_NTOrientation==UIDeviceOrientationPortrait&&_isCanTransform)
    {
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
        self.view.transform = CGAffineTransformMakeRotation(2*M_PI);
        [self OrientationAnimationsTo:[NSValue valueWithCGAffineTransform: CGAffineTransformMakeRotation(2*M_PI)]withTime:0.3];
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        self.view.frame=frame;
        _imageView.frame=frame;
        [_imageView changeImageView:_imageView.imageView];
        _imageView.zoomScale = 1;
        _isCanTransform=YES;
        _NTFromOrientation=_NTOrientation;
    }
    else if (_NTOrientation==UIDeviceOrientationLandscapeLeft&&_isCanTransform)
    {
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
        self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
        if (_NTFromOrientation==UIDeviceOrientationLandscapeRight)
        {
            [self OrientationAnimationsTo:[NSValue valueWithCGAffineTransform: CGAffineTransformMakeRotation(M_PI/2)]withTime:0.5];
        }
        else
            [self OrientationAnimationsTo:[NSValue valueWithCGAffineTransform: CGAffineTransformMakeRotation(M_PI/2)] withTime:0.3];
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        if (frame.size.width>frame.size.height)
        {
            self.view.frame=CGRectMake(0, 0, frame.size.height, frame.size.width);
            _imageView.frame=frame;
        }
        else
        {
            self.view.frame=frame;
            _imageView.frame=CGRectMake(0, 0, frame.size.height, frame.size.width);
        }
        [_imageView changeImageView:_imageView.imageView];
        _imageView.zoomScale = 1;
        _NTFromOrientation=_NTOrientation;
    }
    else if (_NTOrientation==UIDeviceOrientationLandscapeRight&&_isCanTransform)
    {
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
        self.view.transform = CGAffineTransformMakeRotation(-M_PI/2);
         if (_NTFromOrientation==UIDeviceOrientationLandscapeLeft)
         {
             [self OrientationAnimationsTo:[NSValue valueWithCGAffineTransform: CGAffineTransformMakeRotation(-M_PI/2)]withTime:0.5];
         }
        else
            [self OrientationAnimationsTo:[NSValue valueWithCGAffineTransform: CGAffineTransformMakeRotation(-M_PI/2)]withTime:0.3];
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        if (frame.size.width>frame.size.height)
        {
            self.view.frame=CGRectMake(0, 0, frame.size.height, frame.size.width);
            _imageView.frame=frame;
        }
        else
        {
            self.view.frame=frame;
            _imageView.frame=CGRectMake(0, 0, frame.size.height, frame.size.width);
        }
        [_imageView changeImageView:_imageView.imageView];
        _imageView.zoomScale = 1;
        _NTFromOrientation=_NTOrientation;
    }
}

-(void)OrientationAnimationsTo:(NSValue*)toValue withTime:(float)time
{
    CABasicAnimation * inSwipeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    inSwipeAnimation.toValue =toValue;
    inSwipeAnimation.duration = time;
    inSwipeAnimation.removedOnCompletion = NO;
    [self.view.layer addAnimation:inSwipeAnimation forKey:nil];
}

-(void)BeginAnimationsWith:(float)YValue
{
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

-(void)closeAnimations
{
    CABasicAnimation *putransitionlse = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    putransitionlse .timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    putransitionlse .fromValue =(id)[UIColor blackColor].CGColor;
    putransitionlse .toValue =(id)[UIColor colorWithHexString:@"#F4F4EC"].CGColor;
    putransitionlse .duration=0.3;
    putransitionlse .removedOnCompletion = NO;
    [self.view.layer addAnimation:putransitionlse  forKey:nil];
    
    float leftValue;
    if (self.view.frame.size.width-_imageWeight>0)
    {
        leftValue=(_imageWeight*0.85-self.view.frame.size.width)/2+22;
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
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
