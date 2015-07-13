//
//  NTSearchToolBar.h
//  MPlatform
//
//  Created by 李莹 on 15/1/8.
//
//

#import <UIKit/UIKit.h>

@interface NTSearchToolBar : UIView

@property (nonatomic,strong)UIButton * SearchButton;

@property (nonatomic,strong)UIButton * UpPageButton;

@property (nonatomic,strong)UIButton * NextPageButton;

-(void)ResetView;

@end
