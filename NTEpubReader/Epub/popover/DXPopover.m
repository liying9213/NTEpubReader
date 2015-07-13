//
//  DXPopover.m
//
//  Created by xiekw on 11/14/14.
//  Copyright (c) 2014 xiekw. All rights reserved.
//

#import "DXPopover.h"
#import "UIColor+MyColor.h"
#import "define.h"
#define DEGREES_TO_RADIANS(degrees)  ((3.14159265359 * degrees)/ 180)
#define kTextFont [UIFont fontWithName:@"FZLanTingHei-R-GB18030" size:17.0f]
#define iBackGroundColor [UIColor colorWithHexString:@"#F9F9F3"]
@interface DXPopover ()

@property (nonatomic, strong) UIControl *blackOverlay;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, assign, readwrite) DXPopoverPosition popoverPosition;
@property (nonatomic, assign) CGPoint arrowShowPoint;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, assign) CGRect contentViewFrame; //the contentview frame in the containerView coordinator

@end

@implementation DXPopover

+ (instancetype)popover
{
    return [[DXPopover alloc] init];
}

- (instancetype)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.arrowSize = CGSizeMake(11.0, 9.0);
        self.cornerRadius = 7.0;
        self.backgroundColor = [UIColor clearColor];
        self.animationIn = 0.4;
        self.animationOut = 0.3;
        self.animationSpring = NO;
        if (iOS7) {
           self.animationSpring = YES;
        }
        self.sideEdge = 10.0;
        self.maskType = DXPopoverMaskTypeBlack;
        self.betweenAtViewAndArrowHeight = 4.0;
        self.applyShadow = YES;
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self init];
}

- (void)setApplyShadow:(BOOL)applyShadow
{
    _applyShadow = applyShadow;
    if (_applyShadow) {
        self.layer.shadowColor = [UIColor colorWithHexString:@"#604E26"].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowOpacity = 0.4;
        self.layer.shadowRadius = 5.0;
    }else {
        self.layer.shadowColor = nil;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowOpacity = 0.0;
        self.layer.shadowRadius = 0.0;
    }
}

- (void)_setup
{
    CGRect frame = self.contentViewFrame;
    
    CGFloat frameMidx = self.arrowShowPoint.x-CGRectGetWidth(frame)*0.5;
    frame.origin.x = frameMidx;
    
    //we don't need the edge now
    CGFloat sideEdge = 0.0;
    if (CGRectGetWidth(frame)<CGRectGetWidth(self.containerView.frame)) {
        sideEdge = self.sideEdge;
    }
    
    //righter the edge
    CGFloat outerSideEdge = CGRectGetMaxX(frame)-CGRectGetWidth(self.containerView.bounds);
    if (outerSideEdge > 0) {
        frame.origin.x -= (outerSideEdge+sideEdge);
    }else {
        if (CGRectGetMinX(frame)<0) {
            frame.origin.x += abs(CGRectGetMinX(frame))+sideEdge;
        }
    }
    
    
    self.frame = frame;

    CGPoint arrowPoint = [self.containerView convertPoint:self.arrowShowPoint toView:self];

    CGPoint anchorPoint;
    switch (self.popoverPosition) {
        case DXPopoverPositionDown: {
            frame.origin.y = self.arrowShowPoint.y;
            anchorPoint = CGPointMake(arrowPoint.x/CGRectGetWidth(frame), 0);
        }
            break;
        case DXPopoverPositionUp: {
            frame.origin.y = self.arrowShowPoint.y - CGRectGetHeight(frame) - self.arrowSize.height;
            anchorPoint = CGPointMake(arrowPoint.x/CGRectGetWidth(frame), 1);
        }
            break;
    }
    CGPoint DX_lastAnchor = self.layer.anchorPoint;
    self.layer.anchorPoint = anchorPoint;
    self.layer.position = CGPointMake(self.layer.position.x+(anchorPoint.x-DX_lastAnchor.x)*self.layer.bounds.size.width, self.layer.position.y+(anchorPoint.y-DX_lastAnchor.y)*self.layer.bounds.size.height);\

    frame.size.height += self.arrowSize.height;
    self.frame = frame;
}


- (void)showAtPoint:(CGPoint)point popoverPostion:(DXPopoverPosition)position withContentView:(UIView *)contentView inView:(UIView *)containerView
{
    NSAssert((CGRectGetWidth(contentView.bounds)>0&&CGRectGetHeight(contentView.bounds)>0), @"DXPopover contentView bounds.size should not be zero");
    NSAssert((CGRectGetWidth(containerView.bounds)>0&&CGRectGetHeight(containerView.bounds)>0), @"DXPopover containerView bounds.size should not be zero");
    NSAssert(CGRectGetWidth(containerView.bounds)>=CGRectGetWidth(contentView.bounds), @"DXPopover containerView width should be wider than contentView width");
    
    if (!self.blackOverlay) {
        self.blackOverlay = [[UIControl alloc] init];
        self.blackOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    self.blackOverlay.frame = containerView.bounds;
    UIColor *maskColor;
    switch (self.maskType) {
        case DXPopoverMaskTypeBlack:
            maskColor = [UIColor colorWithWhite:0.0 alpha:0.2];
            break;
        case DXPopoverMaskTypeNone:
            maskColor = [UIColor clearColor];
            break;
        default:
            break;
    }
    
    self.blackOverlay.backgroundColor = maskColor;

    
    [containerView addSubview:self.blackOverlay];
    [self.blackOverlay addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    self.containerView = containerView;
    self.contentView = contentView;
    self.contentView.layer.cornerRadius = self.cornerRadius;
    self.contentView.layer.masksToBounds = YES;
    self.popoverPosition = position;
    self.arrowShowPoint = point;
    self.contentViewFrame = [containerView convertRect:contentView.frame toView:containerView];
    
    [self show];
}

- (void)showAtPoint:(CGPoint)point withContentString:(NSString *)contentString inView:(UIView *)containerView
{
    DXPopoverPosition position;
    
    UIFont *font = kTextFont;
    
    NSMutableParagraphStyle *paragStyle = [[NSMutableParagraphStyle alloc] init];
    [paragStyle setLineSpacing:9.5];
    [paragStyle setParagraphSpacing:5.0f];
    [paragStyle setParagraphSpacingBefore:5.0f];
    //    [paragStyle setAlignment:NSTextAlignmentLeft];
    [paragStyle setAlignment:NSTextAlignmentNatural];
    NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           font, NSFontAttributeName,
                           (id)paragStyle, NSParagraphStyleAttributeName,
                           nil];
    CGSize screenSize = containerView.frame.size;
    NSMutableAttributedString *theStr=[[NSMutableAttributedString alloc] initWithString:contentString attributes:attrs];
    long number = 1;
    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
    [theStr addAttribute:NSKernAttributeName value:(__bridge id)(num) range:NSMakeRange(0,[theStr length])];
    CFRelease(num);
    CGRect paragraphRect =
    [theStr boundingRectWithSize:CGSizeMake(screenSize.width-44, CGFLOAT_MAX)
                         options:(NSStringDrawingUsesLineFragmentOrigin)
                         context:nil];
    float height ;
    BOOL isScroll;
    if (point.y>(screenSize.height-80)/2)
    {
        if (paragraphRect.size.height>point.y-30)
        {
            height = point.y-40;
            isScroll=YES;
        }
        else
        {
            height = paragraphRect.size.height;
            isScroll=YES;
        }
        position=DXPopoverPositionUp;
        point.y+=40;
        point.x+=10;
    }
    else
    {
        if (paragraphRect.size.height>screenSize.height-point.y-110)
        {
            height = screenSize.height-point.y-130;
            isScroll=YES;
        }
        else
        {
            height = paragraphRect.size.height;
            isScroll=YES;
        }
        point.y+=70;
        point.x+=10;
        position=DXPopoverPositionDown;
    }
    
    UIView *contentView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width - 20, height+30)];
    contentView.backgroundColor=iBackGroundColor;
    UITextView *TextView=[[UITextView alloc] initWithFrame:CGRectMake(15, 15, screenSize.width - 42, height)];
    TextView.attributedText=theStr;
    TextView.editable=YES;
    TextView.delegate=self;
    TextView.backgroundColor=[UIColor clearColor];
    TextView.scrollEnabled=isScroll;
    [contentView addSubview:TextView];
//    contentView.layer.masksToBounds=YES;
//    contentView.layer.cornerRadius=6;
//    contentView.layer.borderWidth=0.5;
//    contentView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    
    
    NSAssert((CGRectGetWidth(contentView.bounds)>0&&CGRectGetHeight(contentView.bounds)>0), @"DXPopover contentView bounds.size should not be zero");
    NSAssert((CGRectGetWidth(containerView.bounds)>0&&CGRectGetHeight(containerView.bounds)>0), @"DXPopover containerView bounds.size should not be zero");
    NSAssert(CGRectGetWidth(containerView.bounds)>=CGRectGetWidth(contentView.bounds), @"DXPopover containerView width should be wider than contentView width");
    
    if (!self.blackOverlay) {
        self.blackOverlay = [[UIControl alloc] init];
        self.blackOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    self.blackOverlay.frame = containerView.bounds;
    UIColor *maskColor;
    switch (self.maskType) {
        case DXPopoverMaskTypeBlack:
            maskColor = [UIColor colorWithWhite:0.0 alpha:0.0];
            break;
        case DXPopoverMaskTypeNone:
            maskColor = [UIColor clearColor];
            break;
        default:
            break;
    }
    
    self.blackOverlay.backgroundColor = maskColor;
    
    
    [containerView addSubview:self.blackOverlay];
    [self.blackOverlay addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    self.containerView = containerView;
    self.contentView = contentView;
    self.contentView.layer.cornerRadius = self.cornerRadius;
    self.contentView.layer.masksToBounds = YES;
    self.popoverPosition = position;
    self.arrowShowPoint = point;
    self.contentViewFrame = [containerView convertRect:contentView.frame toView:containerView];
    
    [self show];
}

- (void)showAtPoint:(CGPoint)point withContentAry:(NSArray*)Ary inView:(UIView *)containerView WithDelegate:(id)delegate
{
    DXPopoverPosition position=DXPopoverPositionDown;
    UIView *contentView=[[UIView alloc] initWithFrame:CGRectMake(0, 0,  MainWidth/4, Ary.count*40)];
    contentView.backgroundColor=[UIColor colorWithHexString:NTlightGrayColor];
    _delegate=delegate;
    _isSpecial=YES;
    int i=0;
    for (NSDictionary *dic in Ary) {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:[dic objectForKey:@"name"] forState:UIControlStateNormal];
        btn.tag=[[dic objectForKey:@"id"] intValue];
        [btn setTitleColor:NavBarCol forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor colorWithHexString:NTTextGrayColor] forState:UIControlStateNormal];
        btn.frame=CGRectMake(0, i*40, MainWidth/4, 40);
        [btn addTarget:delegate action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font=[UIFont systemFontOfSize:14];//done_null.png
//        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btn setImage:[UIImage imageNamed:@"Done_null.png"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"done_green.png"] forState:UIControlStateSelected];
        if (btn.tag==2) {
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -58, 0, 0)];
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -93)];
        }
        else
        {
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -70, 0, 0)];
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -80)];
        }
        
        btn.selected=[self isSelectWithID:[[dic objectForKey:@"id"] intValue]];
        [contentView addSubview:btn];
        i++;
    }
    NSAssert((CGRectGetWidth(contentView.bounds)>0&&CGRectGetHeight(contentView.bounds)>0), @"DXPopover contentView bounds.size should not be zero");
    NSAssert((CGRectGetWidth(containerView.bounds)>0&&CGRectGetHeight(containerView.bounds)>0), @"DXPopover containerView bounds.size should not be zero");
    NSAssert(CGRectGetWidth(containerView.bounds)>=CGRectGetWidth(contentView.bounds), @"DXPopover containerView width should be wider than contentView width");
    
    if (!self.blackOverlay) {
        self.blackOverlay = [[UIControl alloc] init];
        self.blackOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    self.blackOverlay.frame = containerView.bounds;
    UIColor *maskColor;
    switch (self.maskType) {
        case DXPopoverMaskTypeBlack:
            maskColor = [UIColor colorWithWhite:0.0 alpha:0.0];
            break;
        case DXPopoverMaskTypeNone:
            maskColor = [UIColor clearColor];
            break;
        default:
            break;
    }
    
    self.blackOverlay.backgroundColor = maskColor;
    
    
    [containerView addSubview:self.blackOverlay];
    [self.blackOverlay addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    self.containerView = containerView;
    self.contentView = contentView;
    self.contentView.layer.cornerRadius = self.cornerRadius;
    self.contentView.layer.masksToBounds = YES;
    self.popoverPosition = position;
    self.arrowShowPoint = point;
    self.contentViewFrame = [containerView convertRect:contentView.frame toView:containerView];
    
    [self show];
}

- (void)showMoreViewAtPoint:(CGPoint)point inView:(UIView *)containerView WithDelegate:(id)delegate
{
    DXPopoverPosition position=DXPopoverPositionDown;
    UIView *contentView=[[UIView alloc] initWithFrame:CGRectMake(0, 0,  140, 132)];
    contentView.backgroundColor=[UIColor colorWithHexString:NTlightGrayColor];
    
    UIButton *shareButton=[UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.backgroundColor=[UIColor clearColor];
    [shareButton setTitle:@"分享" forState:UIControlStateNormal];
    [shareButton setTitleColor:DESC_FONT_COLOR forState:UIControlStateNormal];
    shareButton.frame=CGRectMake(0, 0, 140, 44);
    shareButton.titleEdgeInsets = UIEdgeInsetsMake(0,-10, 0, 10);
    shareButton.imageEdgeInsets = UIEdgeInsetsMake(0,-30, 0, 30);
    [shareButton addTarget:delegate action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    [shareButton setImage:[UIImage imageNamed:@"icon_float_share_n.png"] forState:UIControlStateNormal];
    [shareButton setBackgroundImage:[[UIImage imageNamed:@"Bg_grey_p.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:2] forState:UIControlStateHighlighted];
    [contentView addSubview:shareButton];
    
    UIButton *feedbackButton=[UIButton buttonWithType:UIButtonTypeCustom];
    feedbackButton.backgroundColor=[UIColor clearColor];
    [feedbackButton setTitle:@"产品反馈" forState:UIControlStateNormal];
    [feedbackButton setTitleColor:DESC_FONT_COLOR forState:UIControlStateNormal];
    feedbackButton.frame=CGRectMake(0,44, 140, 44);
//    feedbackButton.titleEdgeInsets = UIEdgeInsetsMake(0,-10, 0, 10);
    feedbackButton.imageEdgeInsets = UIEdgeInsetsMake(0,-12, 0, 12);
    [feedbackButton addTarget:delegate action:@selector(feedbackAction:) forControlEvents:UIControlEventTouchUpInside];
    [feedbackButton setImage:[UIImage imageNamed:@"icon_bar_message_n.png"] forState:UIControlStateNormal];
    [feedbackButton setBackgroundImage:[[UIImage imageNamed:@"Bg_grey_p.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:2] forState:UIControlStateHighlighted];
    [contentView addSubview:feedbackButton];
    
    UIButton *correctButton=[UIButton buttonWithType:UIButtonTypeCustom];
    correctButton.backgroundColor=[UIColor clearColor];
    [correctButton setTitle:@"纠错" forState:UIControlStateNormal];
    [correctButton setTitleColor:DESC_FONT_COLOR forState:UIControlStateNormal];
    correctButton.frame=CGRectMake(0,88, 140, 44);
    correctButton.titleEdgeInsets = UIEdgeInsetsMake(0,-10, 0, 10);
    correctButton.imageEdgeInsets = UIEdgeInsetsMake(0,-30, 0, 30);
    [correctButton addTarget:delegate action:@selector(correctAction:) forControlEvents:UIControlEventTouchUpInside];
    [correctButton setImage:[UIImage imageNamed:@"icon_footer_error_n.png"] forState:UIControlStateNormal];
    [correctButton setBackgroundImage:[[UIImage imageNamed:@"Bg_grey_p.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:2] forState:UIControlStateHighlighted];
    [contentView addSubview:correctButton];
    
    NSAssert((CGRectGetWidth(contentView.bounds)>0&&CGRectGetHeight(contentView.bounds)>0), @"DXPopover contentView bounds.size should not be zero");
    NSAssert((CGRectGetWidth(containerView.bounds)>0&&CGRectGetHeight(containerView.bounds)>0), @"DXPopover containerView bounds.size should not be zero");
    NSAssert(CGRectGetWidth(containerView.bounds)>=CGRectGetWidth(contentView.bounds), @"DXPopover containerView width should be wider than contentView width");
    
    if (!self.blackOverlay) {
        self.blackOverlay = [[UIControl alloc] init];
        self.blackOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    self.blackOverlay.frame = containerView.bounds;
    UIColor *maskColor;
    switch (self.maskType) {
        case DXPopoverMaskTypeBlack:
            maskColor = [UIColor colorWithWhite:0.0 alpha:0.0];
            break;
        case DXPopoverMaskTypeNone:
            maskColor = [UIColor clearColor];
            break;
        default:
            break;
    }
    
    self.blackOverlay.backgroundColor = maskColor;
    
    [containerView addSubview:self.blackOverlay];
    [self.blackOverlay addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    self.containerView = containerView;
    self.contentView = contentView;
    self.contentView.layer.cornerRadius = self.cornerRadius;
    self.contentView.layer.masksToBounds = YES;
    self.popoverPosition = position;
    self.arrowShowPoint = point;
    self.contentViewFrame = [containerView convertRect:contentView.frame toView:containerView];
    
    [self show];
}

- (void)showSettingViewAtPoint:(CGPoint)point inView:(UIView *)containerView WithDelegate:(id)delegate
{
    DXPopoverPosition position=DXPopoverPositionDown;
    UIView *contentView=[[UIView alloc] initWithFrame:CGRectMake(0, 0,  160, 88)];
    contentView.backgroundColor=[UIColor colorWithHexString:NTlightGrayColor];

    UIButton *minusFontButton=[UIButton buttonWithType:UIButtonTypeCustom];
    minusFontButton.frame=CGRectMake(0.5, 0, 79, 44);
    minusFontButton.backgroundColor=[UIColor clearColor];
    [minusFontButton setImage:[UIImage imageNamed:@"icon_float_size_n_1.png"] forState:UIControlStateNormal];
    minusFontButton.tag=1024;
    [minusFontButton addTarget:delegate action:@selector(fontAction:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:minusFontButton];
    
    UIButton *addFontButton=[UIButton buttonWithType:UIButtonTypeCustom];
    addFontButton.frame=CGRectMake(80.5, 0, 79, 44);
    addFontButton.backgroundColor=[UIColor clearColor];
    [addFontButton setImage:[UIImage imageNamed:@"icon_float_size_n_2.png"] forState:UIControlStateNormal];
    addFontButton.tag=2046;
    [addFontButton addTarget:delegate action:@selector(fontAction:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:addFontButton];
    
    UIImageView *leftImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 44, 22, 44)];
    leftImage.image=[UIImage imageNamed:@"icon_float_light_n_1.png"];
    [contentView addSubview:leftImage];
    
    UIImageView *RightImage=[[UIImageView alloc] initWithFrame:CGRectMake(138, 44, 22, 44)];
    RightImage.image=[UIImage imageNamed:@"icon_float_light_n_2.png"];
    [contentView addSubview:RightImage];
    
    UISlider *slider=[[UISlider alloc] initWithFrame:CGRectMake(22, 44, 116,44)];
    slider.minimumValue=0;
    slider.maximumValue=1;
    slider.value=[UIScreen mainScreen].brightness;
    [slider addTarget:delegate action:@selector(ChangeValue:) forControlEvents:UIControlEventValueChanged];
    [contentView addSubview:slider];
    
    NSAssert((CGRectGetWidth(contentView.bounds)>0&&CGRectGetHeight(contentView.bounds)>0), @"DXPopover contentView bounds.size should not be zero");
    NSAssert((CGRectGetWidth(containerView.bounds)>0&&CGRectGetHeight(containerView.bounds)>0), @"DXPopover containerView bounds.size should not be zero");
    NSAssert(CGRectGetWidth(containerView.bounds)>=CGRectGetWidth(contentView.bounds), @"DXPopover containerView width should be wider than contentView width");
    
    if (!self.blackOverlay) {
        self.blackOverlay = [[UIControl alloc] init];
        self.blackOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    self.blackOverlay.frame = containerView.bounds;
    UIColor *maskColor;
    switch (self.maskType) {
        case DXPopoverMaskTypeBlack:
            maskColor = [UIColor colorWithWhite:0.0 alpha:0.0];
            break;
        case DXPopoverMaskTypeNone:
            maskColor = [UIColor clearColor];
            break;
        default:
            break;
    }
    
    self.blackOverlay.backgroundColor = maskColor;
    
    [containerView addSubview:self.blackOverlay];
    [self.blackOverlay addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    self.containerView = containerView;
    self.contentView = contentView;
    self.contentView.layer.cornerRadius = self.cornerRadius;
    self.contentView.layer.masksToBounds = YES;
    self.popoverPosition = position;
    self.arrowShowPoint = point;
    self.contentViewFrame = [containerView convertRect:contentView.frame toView:containerView];
    
    [self show];
}

-(BOOL)isSelectWithID:(int)ID
{
     NSArray *ary=[self getTheSearchType:YES];
    for (NSNumber *num in ary) {
        if ([num intValue]==ID) {
            return YES;
        }
    }
    return NO;
}

-(NSArray *)getTheSearchType:(BOOL)isNeedAdd
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSArray *ary= [ud valueForKey:@"searchType"];
    if ((!ary||ary.count==0)&&isNeedAdd) {
        ary=[NSArray arrayWithObjects:[NSNumber numberWithInt:1],[NSNumber numberWithInt:2], nil];
        [ud setObject:ary forKey:@"searchType"];
    }
    return ary;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}


- (void)showAtView:(UIView *)atView popoverPostion:(DXPopoverPosition)position withContentView:(UIView *)contentView inView:(UIView *)containerView
{
    CGFloat betweenArrowAndAtView = self.betweenAtViewAndArrowHeight;
    CGFloat contentViewHeight = CGRectGetHeight(contentView.bounds);
    CGRect atViewFrame = [containerView convertRect:atView.frame toView:containerView];
    
    BOOL upCanContain = CGRectGetMinY(atViewFrame) >= contentViewHeight+betweenArrowAndAtView;
    BOOL downCanContain = (CGRectGetHeight(containerView.bounds) - (CGRectGetMaxY(atViewFrame)+betweenArrowAndAtView)) >= contentViewHeight;
    NSAssert((upCanContain||downCanContain), @"DXPopover no place for the popover show, check atView frame %@ check contentView bounds %@ and containerView's bounds %@", NSStringFromCGRect(atViewFrame), NSStringFromCGRect(contentView.bounds), NSStringFromCGRect(containerView.bounds));
    
    
    CGPoint atPoint = CGPointMake(CGRectGetMidX(atViewFrame), 0);
    DXPopoverPosition dxP;
    if (upCanContain) {
        dxP = DXPopoverPositionUp;
        atPoint.y = CGRectGetMinY(atViewFrame) - betweenArrowAndAtView;
    }else {
        dxP = DXPopoverPositionDown;
        atPoint.y = CGRectGetMaxY(atViewFrame) + betweenArrowAndAtView;
    }
    
    // if they are all yes then it shows in the bigger container
    if (upCanContain && downCanContain) {
        CGFloat upHeight = CGRectGetMinY(atViewFrame);
        CGFloat downHeight = CGRectGetHeight(containerView.bounds)-CGRectGetMaxY(atViewFrame);
        BOOL useUp = upHeight > downHeight;
        
        //except you set outsider
        if (position!=0) {
            useUp = position == DXPopoverPositionUp ? YES : NO;
        }
        if (useUp) {
            dxP = DXPopoverPositionUp;
            atPoint.y = CGRectGetMinY(atViewFrame) - betweenArrowAndAtView;
        }else {
            dxP = DXPopoverPositionDown;
            atPoint.y = CGRectGetMaxY(atViewFrame) + betweenArrowAndAtView;
        }
    }

    [self showAtPoint:atPoint popoverPostion:dxP withContentView:contentView inView:containerView];
}


- (void)showAtView:(UIView *)atView withContentView:(UIView *)contentView inView:(UIView *)containerView
{
    [self showAtView:atView popoverPostion:0 withContentView:contentView inView:containerView];
}

- (void)showAtView:(UIView *)atView withContentView:(UIView *)contentView
{
    [self showAtView:atView withContentView:contentView inView:[UIApplication sharedApplication].keyWindow];
}

- (void)show
{
    [self setNeedsDisplay];
    
    CGRect contentViewFrame = self.contentViewFrame;
    switch (self.popoverPosition) {
        case DXPopoverPositionUp:
            contentViewFrame.origin.y = 0.0;
            break;
        case DXPopoverPositionDown:
            contentViewFrame.origin.y = self.arrowSize.height;
            break;
    }
    
    self.contentView.frame = contentViewFrame;
    [self addSubview:self.contentView];
    [self.containerView addSubview:self];
    
    self.transform = CGAffineTransformMakeScale(0.0, 0.0);
    if (self.animationSpring) {
        [UIView animateWithDuration:self.animationIn delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (finished) {
                if (self.didShowHandler) {
                    self.didShowHandler();
                }
            }
        }];
    }else {
        [UIView animateWithDuration:self.animationIn delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (finished) {
                if (self.didShowHandler) {
                    self.didShowHandler();
                }
            }
        }];
    }
}

- (void)dismiss
{
    if (self.superview) {
        [UIView animateWithDuration:self.animationOut delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
        } completion:^(BOOL finished) {
            if (finished) {
                [self.contentView removeFromSuperview];
                [self.blackOverlay removeFromSuperview];
                [self removeFromSuperview];
                if (self.didDismissHandler) {
                    self.didDismissHandler();
                }
            }
        }];
    }
    if (_delegate&&_delegate!=nil&&_isSpecial) {
        [self needReloadSearch];
    }
}

-(void)needReloadSearch{
    [_delegate needReloadSearch];
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *arrow = [[UIBezierPath alloc] init];
    UIColor *contentColor = self.contentView.backgroundColor ? : [UIColor whiteColor];
    //the point in the ourself view coordinator
    CGPoint arrowPoint = [self.containerView convertPoint:self.arrowShowPoint toView:self];
    
    switch (self.popoverPosition) {
        case DXPopoverPositionDown: {
            [arrow moveToPoint:CGPointMake(arrowPoint.x, 0)];
            [arrow addLineToPoint:CGPointMake(arrowPoint.x+self.arrowSize.width*0.5, self.arrowSize.height)];
            [arrow addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds)-self.cornerRadius, self.arrowSize.height)];
            [arrow addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds)-self.cornerRadius, self.arrowSize.height+self.cornerRadius) radius:self.cornerRadius startAngle:DEGREES_TO_RADIANS(270.0) endAngle:DEGREES_TO_RADIANS(0) clockwise:YES];
            [arrow addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)-self.cornerRadius)];
            [arrow addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds)-self.cornerRadius, CGRectGetHeight(self.bounds)-self.cornerRadius) radius:self.cornerRadius startAngle:DEGREES_TO_RADIANS(0) endAngle:DEGREES_TO_RADIANS(90.0) clockwise:YES];
            [arrow addLineToPoint:CGPointMake(0, CGRectGetHeight(self.bounds))];
            [arrow addArcWithCenter:CGPointMake(self.cornerRadius, CGRectGetHeight(self.bounds)-self.cornerRadius) radius:self.cornerRadius startAngle:DEGREES_TO_RADIANS(90) endAngle:DEGREES_TO_RADIANS(180.0) clockwise:YES];
            [arrow addLineToPoint:CGPointMake(0, self.arrowSize.height+self.cornerRadius)];
            [arrow addArcWithCenter:CGPointMake(self.cornerRadius, self.arrowSize.height+self.cornerRadius) radius:self.cornerRadius startAngle:DEGREES_TO_RADIANS(180.0) endAngle:DEGREES_TO_RADIANS(270) clockwise:YES];
            [arrow addLineToPoint:CGPointMake(arrowPoint.x-self.arrowSize.width*0.5, self.arrowSize.height)];
        }
            break;
        case DXPopoverPositionUp: {
            [arrow moveToPoint:CGPointMake(arrowPoint.x, CGRectGetHeight(self.bounds))];
            [arrow addLineToPoint:CGPointMake(arrowPoint.x-self.arrowSize.width*0.5, CGRectGetHeight(self.bounds)-self.arrowSize.height)];
            [arrow addLineToPoint:CGPointMake(self.cornerRadius, CGRectGetHeight(self.bounds)-self.arrowSize.height)];
            [arrow addArcWithCenter:CGPointMake(self.cornerRadius, CGRectGetHeight(self.bounds)-self.arrowSize.height-self.cornerRadius) radius:self.cornerRadius startAngle:DEGREES_TO_RADIANS(90.0) endAngle:DEGREES_TO_RADIANS(180.0) clockwise:YES];
            [arrow addLineToPoint:CGPointMake(0, self.cornerRadius)];
            [arrow addArcWithCenter:CGPointMake(self.cornerRadius, self.cornerRadius) radius:self.cornerRadius startAngle:DEGREES_TO_RADIANS(180.0) endAngle:DEGREES_TO_RADIANS(270.0) clockwise:YES];
            [arrow addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds)-self.cornerRadius, 0)];
            [arrow addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds)-self.cornerRadius, self.cornerRadius) radius:self.cornerRadius startAngle:DEGREES_TO_RADIANS(270.0) endAngle:DEGREES_TO_RADIANS(0) clockwise:YES];
            [arrow addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)-self.arrowSize.height-self.cornerRadius)];
            [arrow addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds)-self.cornerRadius, CGRectGetHeight(self.bounds)-self.arrowSize.height-self.cornerRadius) radius:self.cornerRadius startAngle:DEGREES_TO_RADIANS(0) endAngle:DEGREES_TO_RADIANS(90.0) clockwise:YES];
            [arrow addLineToPoint:CGPointMake(arrowPoint.x+self.arrowSize.width*0.5, CGRectGetHeight(self.bounds)-self.arrowSize.height)];
        }
            
            break;
    }
    [contentColor setFill];
    [arrow fill];
}

- (void)layoutSubviews
{
    [self _setup];
}

@end
