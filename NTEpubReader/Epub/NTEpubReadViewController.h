//
//  NTEpubReadViewController.h
//  MPlatform
//
//  Created by liying on 14-7-18.
//
//

#import <UIKit/UIKit.h>
#import "NTCatalogViewController.h"
#import "NTGetPageInfo.h"
#import "NTToolBarView.h"
#import "NTBackView.h"
#import "MBProgressHUD.h"
#import "NTImageViewController.h"
#import "NTSImageView.h"
#import "NTEpubSearchViewController.h"
#import "NTSearchToolBar.h"
#import "YTKKeyValueStore.h"
#import "PopoverView.h"
@interface NTEpubReadViewController : UIViewController<UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIGestureRecognizerDelegate,NTSImageViewDelegate,NTEpubSearchViewControllerDelegate,PopoverViewDelegate>

@property (nonatomic,assign) int bookID;

@property (nonatomic,strong) NSString *bookName;

@property (nonatomic,strong) UIPageViewController *pageViewController;

@property (nonatomic,strong) NTGetPageInfo * getPageInfo;

@property (nonatomic,strong) NTToolBarView *toolBarView;

@property (nonatomic,strong) NTSearchToolBar *searchToolBarView;

@property (nonatomic,strong) NTBackView *backView;

@property (nonatomic,strong) NTCatalogViewController *CatalogView;

@property (nonatomic,strong) NSMutableDictionary *ALLPageInfo;

@property (nonatomic,assign) BOOL ishidden;

@property (nonatomic,assign) int allThePage;

@property (nonatomic,strong) NSMutableArray *catalogArray;

@property (nonatomic,strong) NSMutableArray *catalogInfoArray;

@property (nonatomic,assign) int currentPage;

@property (nonatomic, strong)MBProgressHUD* waitingView;

@property (nonatomic, assign)BOOL isLoad;

@property (nonatomic, assign)BOOL isNeedChangeBar;

@property (nonatomic, strong)NTImageViewController *Imageview;

@property (nonatomic, assign)BOOL isGuide;

@property (nonatomic, strong)NTSImageView *SImageView;

@property (nonatomic, strong)NSString *bookPath;

@property (nonatomic, strong)NTEpubSearchViewController * SearchViewController;

@property (nonatomic, strong)NSMutableArray * SearchPageAry;

@property (nonatomic, strong)NSMutableDictionary * SearchPageDic;

@property (nonatomic, strong)NSMutableArray * AllSearchAry;

@property (nonatomic, strong)YTKKeyValueStore *FootNoteDB;

@property (nonatomic, strong)PopoverView *popoverView;

-(void)showWaitView:(NSString *)string;

-(void)showEndText:(NSString *)string;

@end
