//
//  NTEpubSearchViewController.h
//  MPlatform
//
//  Created by 李莹 on 14-12-29.
//
//

#import <UIKit/UIKit.h>

@class NTEpubSearchViewController;

@protocol NTEpubSearchViewControllerDelegate

@required

-(void)openSearchTheViewPage:(NSMutableDictionary *)pageInfo;

-(void)closeTheSearchView;

-(void)NeedParseHtml;

@end


@interface NTEpubSearchViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property(nonatomic, strong)UITableView *tableView;

@property(nonatomic, strong)UITextField *searchText;

@property(nonatomic, strong)UIButton *clearnBtn;

@property(nonatomic, strong)NSMutableDictionary *dic;

@property(nonatomic, strong)NSMutableArray *infoAry;

@property(nonatomic, strong)NSMutableArray *pageAry;

@property(nonatomic, strong)NSString *BasePath;

@property(nonatomic, strong)NSMutableArray *OneSearchAry;

@property(nonatomic, strong)NSMutableArray *AllSearchAry;

@property(nonatomic, strong)NSMutableArray *AllPageNumAry;

@property(nonatomic, weak) id delegate;

@property(nonatomic, strong)NSMutableDictionary *PageNumDic;

@property (nonatomic) float NTWidth;

@property (nonatomic) float NTHeight;

-(void)ResetStatusBar;

@end
