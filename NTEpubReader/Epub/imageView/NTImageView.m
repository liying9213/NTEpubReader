//
//  NTImageView.m
//  NTCoreTextReader
//
//  Created by liying on 14-7-3.
//  Copyright (c) 2014年 liying. All rights reserved.
//

#import "NTImageView.h"

@implementation NTImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.zoomScale=1;
		self.minimumZoomScale = 1;
		self.maximumZoomScale = 3.0;
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
        self.backgroundColor=[UIColor clearColor];
    }
    return self;
}

-(void)ResetView
{
    _imageView=[[UIImageView alloc] initWithFrame:self.frame];
    if ((!_imagePath||_imagePath.length==0)&&_image) {
        _imageView.image=_image;
    }
    else
        _imageView.image=[UIImage imageWithContentsOfFile:_imagePath];
    _imageView.backgroundColor=[UIColor clearColor];
    [self addSubview:_imageView];
    [self changeImageView:_imageView];
}


-(void)changeImageView:(UIImageView *)imageview
{
    self.zoomScale=1;
    
    if (self.frame.size.width<self.frame.size.height)
    {
        if (imageview.image.size.width>imageview.image.size.height)
        {
            if (imageview.image.size.width<self.frame.size.width)
            {
                imageview.frame = CGRectMake((self.frame.size.width-imageview.image.size.width)/2, (self.frame.size.height-imageview.image.size.height)/2, imageview.image.size.width, imageview.image.size.height);
            }
            else
            {
                imageview.frame = CGRectMake(0, (self.frame.size.height-imageview.image.size.height*self.frame.size.width/imageview.image.size.width)/2, self.frame.size.width, imageview.image.size.height*self.frame.size.width/imageview.image.size.width);
            }
        }
        else
        {
            if (imageview.image.size.height<self.frame.size.height)
            {
                if (imageview.image.size.width<self.frame.size.width)
                {
                    imageview.frame = CGRectMake((self.frame.size.width-imageview.image.size.width)/2, (self.frame.size.height-imageview.image.size.height)/2, imageview.image.size.width, imageview.image.size.height);
                }
                else
                {
                    imageview.frame = CGRectMake(0, (self.frame.size.height-imageview.image.size.height*self.frame.size.width/imageview.image.size.width)/2, self.frame.size.width, imageview.image.size.height*self.frame.size.width/imageview.image.size.width);
                }
            }
            else
            {
                float wid= imageview.image.size.width*self.frame.size.height/imageview.image.size.height;
                if (wid>self.frame.size.width)
                {
                    imageview.frame = CGRectMake(0, (self.frame.size.height-imageview.image.size.height*self.frame.size.width/imageview.image.size.width)/2, self.frame.size.width, imageview.image.size.height*self.frame.size.width/imageview.image.size.width);
                }
                else
                {
                    imageview.frame = CGRectMake((self.frame.size.width-wid)/2, 0, wid, self.frame.size.height);
                }
            }
        }
    }
    else
    {
        if (imageview.image.size.width<imageview.image.size.height)
        {
            if (imageview.image.size.height<self.frame.size.height)
            {
                imageview.frame = CGRectMake((self.frame.size.width-imageview.image.size.width)/2, (self.frame.size.height-imageview.image.size.height)/2, imageview.image.size.width, imageview.image.size.height);
            }
            else
            {
                imageview.frame = CGRectMake((self.frame.size.width-imageview.image.size.width*self.frame.size.height/imageview.image.size.height)/2, 0, imageview.image.size.width*self.frame.size.height/imageview.image.size.height, self.frame.size.height);
            }
        }
        else
        {
            if (imageview.image.size.height<self.frame.size.height)
            {
                if (imageview.image.size.width<self.frame.size.width)
                {
                    imageview.frame = CGRectMake((self.frame.size.width-imageview.image.size.width)/2, (self.frame.size.height-imageview.image.size.height)/2, imageview.image.size.width, imageview.image.size.height);
                }
                else
                {
                    imageview.frame = CGRectMake(0, (self.frame.size.height-imageview.image.size.height*self.frame.size.width/imageview.image.size.width)/2, self.frame.size.width, imageview.image.size.height*self.frame.size.width/imageview.image.size.width);
                }
            }
            else
            {
                float wid= imageview.image.size.width*self.frame.size.height/imageview.image.size.height;
                if (wid>self.frame.size.width)
                {
                    imageview.frame = CGRectMake(0, (self.frame.size.height-imageview.image.size.height*self.frame.size.width/imageview.image.size.width)/2, self.frame.size.width, imageview.image.size.height*self.frame.size.width/imageview.image.size.width);
                }
                else
                {
                    imageview.frame = CGRectMake((self.frame.size.width-wid)/2, 0, wid, self.frame.size.height);
                }
            }
        }
    }
    _imageRect=imageview.frame;
}

#pragma mark - UIScrollView Delegate -
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIImageView *)view atScale:(CGFloat)scale
{
	CGFloat zs = scrollView.zoomScale;
	zs = MAX(zs, 1);
	zs = MIN(zs, 3.0);
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	scrollView.zoomScale = zs;
    imageValue=zs;
	[UIView commitAnimations];
    
    if (self.contentSize.width>=self.frame.size.width&&self.contentSize.height>=self.frame.size.height)
    {
        view.center=CGPointMake(self.contentSize.width/2, self.contentSize.height/2);
    }
    else if (self.contentSize.width>=self.frame.size.width&&self.contentSize.height<=self.frame.size.height)
    {
        view.center=CGPointMake(self.contentSize.width/2, self.frame.size.height/2);
    }
    else if (self.contentSize.width<=self.frame.size.width&&self.contentSize.height>=self.frame.size.height)
    {
        view.center=CGPointMake(self.frame.size.width/2, self.contentSize.height/2);
    }
    else if (self.contentSize.width<=self.frame.size.width&&self.contentSize.height<=self.frame.size.height)
    {
        view.center=CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
}

#pragma mark - UITouch Delegate -

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    switch (touch.tapCount) {
        case 1:
            [self performSelector:@selector(singleTap) withObject:nil afterDelay:0.3];
            break;
        case 2:{
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTap) object:nil];
            [self performSelector:@selector(doubleTap) withObject:nil afterDelay:0];
        }
            break;
        default:
            break;
    }
}

-(void)singleTap
{
//    self.zoomScale=1;
//    _imageView.frame=_imageRect;
    [_idelegate closeTheImageView];
}

-(void)doubleTap
{
    imageValue=self.zoomScale;
    if (imageValue>=3.0)
    {
        imageValue=1;
    }
    else
    {
        imageValue+=0.5;
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.zoomScale = imageValue;
    [UIView commitAnimations];
    
    if (self.contentSize.width>=self.frame.size.width&&self.contentSize.height>=self.frame.size.height)
    {
        _imageView.center=CGPointMake(self.contentSize.width/2, self.contentSize.height/2);
    }
    else if (self.contentSize.width>=self.frame.size.width&&self.contentSize.height<=self.frame.size.height)
    {
        _imageView.center=CGPointMake(self.contentSize.width/2, self.frame.size.height/2);
    }
    else if (self.contentSize.width<=self.frame.size.width&&self.contentSize.height>=self.frame.size.height)
    {
        _imageView.center=CGPointMake(self.frame.size.width/2, self.contentSize.height/2);
    }
    else if (self.contentSize.width<=self.frame.size.width&&self.contentSize.height<=self.frame.size.height)
    {
        _imageView.center=CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
}

-(void)dealloc
{
    _imageView.image=nil;
    _imageView=nil;
}

@end
