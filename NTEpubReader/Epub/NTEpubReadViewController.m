 //
//  NTEpubReadViewController.m
//  MPlatform
//
//  Created by liying on 14-7-18.
//
//

#import "NTEpubReadViewController.h"

#import "NTContentViewController.h"

#import "NTImageViewController.h"

#import "define.h"

#import "NTFontRegister.h"

#import "NTEpubSearchViewController.h"

#import "DXPopover.h"

@interface NTEpubReadViewController ()

@end

@implementation NTEpubReadViewController

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
    if (iOS7)
    {
        [self setNeedsStatusBarAppearanceUpdate];
    }
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    _isLoad=NO;
    [self showWaitView:nil];

    [NTFontRegister RegisterFontFrom:[DOCUMENT_PATH stringByAppendingPathComponent:@"NTFonts"]];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_isLoad==NO)
    {
       [self NTLoadView];
        _isLoad=YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)NTLoadView
{
    _ALLPageInfo=[[NSMutableDictionary alloc] init];
    NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    if (_isGuide)
    {
        _bookPath=[path stringByAppendingString:[NSString stringWithFormat:@"/%@",_bookName]];
    }
    else
        _bookPath=[path stringByAppendingString:[NSString stringWithFormat:@"/%@",_bookName]];
    [self getAllPageinfoWith:_bookPath];
    [self Resetview];
    [self ResetToolBarView];
    [self ResetSearchToolBar];
    [_waitingView hide:YES];
}

-(void)dealloc
{
    _pageViewController=nil;
    _getPageInfo=nil;
    _ALLPageInfo=nil;
    _catalogArray=nil;
    _catalogInfoArray=nil;
}
#pragma mark - parseHtml -

-(void)getAllPageinfoWith:(NSString *)path
{
    [self parseHtmlWithPath:path];
}

-(void)parseHtmlWithPath:(NSString *)path
{
    _getPageInfo=[[NTGetPageInfo alloc] initWithTheBookID:_bookName];
    _ALLPageInfo=[_getPageInfo getTheEpubPageInfoWithPath:path withFrame:self.view.bounds];
    _currentPage=_getPageInfo.currentPage;
    _allThePage=_getPageInfo.NTAllPage;
    _catalogInfoArray=_getPageInfo.CatalogInfoArray;
    _catalogArray=_getPageInfo.NcxCatalogArray;
}

#pragma mark - Resetview -

-(void)Resetview
{
    NSDictionary *options =[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin] forKey: UIPageViewControllerOptionSpineLocationKey];
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options: options];
    _pageViewController.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];;
    _pageViewController.dataSource = self;
    _pageViewController.delegate=self;
    [[_pageViewController view] setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-0)];
    
    NTContentViewController *viewController = [[NTContentViewController alloc] init];
    viewController.columnIndex=_currentPage;
    viewController.NTbookID=_bookID;
    viewController.delegate=self;
    viewController.isGuide=_isGuide;
    viewController.allColumnCount=_allThePage;
    viewController.bookName=_bookName;
    viewController.catalogArray=_catalogArray;
    viewController.pageInfo=[_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",_currentPage]];
    NSArray *viewControllers =[NSArray arrayWithObject:viewController];
    [_pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward  animated:NO  completion:nil];
    [self addChildViewController:_pageViewController];
    [[self view] addSubview:[_pageViewController view]];
}

-(void)ResetToolBarView
{
    _toolBarView=[[NTToolBarView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-80, 70,80)];
    [_toolBarView ResetView];
    [self.view addSubview:_toolBarView];
    [_toolBarView.menuButton addTarget:self action:@selector(showCatalog) forControlEvents:UIControlEventTouchUpInside];
//    _toolBarView.hidden=YES;
    
    _backView=[[NTBackView alloc] initWithFrame:CGRectMake(0, 0, MainWidth, 85)];
    [_backView ResetView];
    [self.view addSubview:_backView];
    [_backView.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//    _backView.hidden=YES;
    [_backView.SearchButton addTarget:self action:@selector(SearchAction) forControlEvents:UIControlEventTouchUpInside];
}

-(void)ResetSearchToolBar
{
    _searchToolBarView=[[NTSearchToolBar alloc] initWithFrame:CGRectMake((MainWidth-200)/2, self.view.frame.size.height-80, 200,60)];
    [_searchToolBarView ResetView];
    [self.view addSubview:_searchToolBarView];
    
    [_searchToolBarView.SearchButton addTarget:self action:@selector(SearchAction) forControlEvents:UIControlEventTouchUpInside];
    [_searchToolBarView.UpPageButton addTarget:self action:@selector(UpSearchAction) forControlEvents:UIControlEventTouchUpInside];
    [_searchToolBarView.NextPageButton addTarget:self action:@selector(NextSearchAction) forControlEvents:UIControlEventTouchUpInside];
    _searchToolBarView.hidden=YES;
}

#pragma mark - pageViewControllerDelegate -

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(NTContentViewController *)viewController
{
    if (viewController.columnIndex==0)
    {
        return nil;
    }
    else
    {
        [self loadBeforeView:viewController.columnIndex];
        NTContentViewController *BViewController = [[NTContentViewController alloc] init];
        BViewController.columnIndex=viewController.columnIndex-1;
        BViewController.PageType=-1;
        BViewController.delegate=self;
        BViewController.NTbookID=_bookID;
        BViewController.isGuide=_isGuide;
        BViewController.allColumnCount=_allThePage;
        BViewController.bookName=_bookName;
        BViewController.catalogArray=_catalogArray;
        BViewController.pageInfo=[_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",viewController.columnIndex-1]];
        return BViewController;
    }
    return nil;
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(NTContentViewController *)viewController
{
    if (viewController.columnIndex+1<_allThePage)
    {
        [self loadAfterView:viewController.columnIndex];
        NTContentViewController *BViewController = [[NTContentViewController alloc] init];
        BViewController.columnIndex=viewController.columnIndex+1;
        BViewController.PageType=1;
        BViewController.allColumnCount=_allThePage;
        BViewController.delegate=self;
        BViewController.NTbookID=_bookID;
        BViewController.isGuide=_isGuide;
        BViewController.bookName=_bookName;
        BViewController.catalogArray=_catalogArray;
        BViewController.pageInfo=[_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",viewController.columnIndex+1]];
        return BViewController;
    }
    else
    {
        return nil;
    }
    return nil;
}

#pragma mark - ImageAction -

-(void)TouchUpForImage:(NSString*)imagePath withYValue:(float)YValue WithImage:(UIImage*)image
{
//    if (!_SImageView)
//    {
//        _SImageView=[[NTSImageView alloc] initWithFrame:self.view.frame withYValue:YValue With:image];
//        _SImageView.sdelegate=self;
//        [self.view addSubview:_SImageView];
//    }
//    else
//    {
//        if (_SImageView.hidden)
//        {
//            _SImageView.hidden=NO;
//            [_SImageView ResetViewWith:image With:YValue];
//        }
//    }
//    [self showImage];

    _Imageview=nil;
    _Imageview=[[NTImageViewController alloc] init];
    _Imageview.imageYValue=YValue;
    _Imageview.image=image;
    _Imageview.imagePath=imagePath;
    _Imageview.delegate=self;
    [self presentViewController:_Imageview animated:NO completion:nil];
}

-(void)closeTheSImageView
{
    _SImageView.hidden=YES;

    UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation];
    //设置statusBar
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    //计算旋转角度
    float arch;
    if (orientation == UIInterfaceOrientationLandscapeLeft)
        arch = M_PI_2;
    else if (orientation == UIInterfaceOrientationLandscapeRight)
        arch = -M_PI_2;
    else
        arch = 0;
    
    //对navigationController.view 进行强制旋转
    self.view.transform = CGAffineTransformMakeRotation(arch);
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    self.view.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
}

-(void)closeTheImageView
{
    [UIView animateWithDuration:0.3 animations:^{
        _Imageview.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
        _Imageview.view.alpha = 0.3;
    } completion:^(BOOL finished)
    {
        _Imageview.view.hidden=YES;
        [_Imageview.view removeFromSuperview];
        _Imageview.delegate=nil;
        _Imageview=nil;
    }];
}

#pragma mark - touchAction -
-(void)TouchUpForSelectURL:(NSString *)URL
{
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL]];
}

-(void)TouchUpForSelectFootNote:(NSString *)footNote withHtml:(NSString*)name withPoint:(CGPoint)point
{
    if (!_FootNoteDB)
    {
        _FootNoteDB=[[YTKKeyValueStore alloc] initWithDBWithPath:[NSString stringWithFormat:@"%@/BookFoot.db",_bookPath]];
    }
   NSString *str= [_FootNoteDB getObjectByFileName:name ByNoteName:[footNote substringFromIndex:1] fromTable:@"FootNote"];
    if ([[str substringToIndex:2]isEqualToString:@"\r\n"])
    {
        str=[str substringFromIndex:2];
    }
    if ([[str substringFromIndex:str.length-2]isEqualToString:@"\r\n"])
    {
        str=[str substringToIndex:str.length-2];
    }
    if ([[str substringToIndex:1]isEqualToString:@"\n"])
    {
        str=[str substringFromIndex:1];
    }
    if (str.length>0) {
        DXPopover *popover = [DXPopover popover];
        [popover showAtPoint:point withContentString:str inView:self.view];
        [self hiddenToolBar];
    }
}

-(void)TouchUpForSelect:(CGPoint)point
{
    if (!_searchToolBarView.hidden)
    {
        _searchToolBarView.hidden=YES;
        return;
    }
    CGPoint ipoint = point;
    if (ipoint.x<100)
    {
        [self JumpToBeforeView];
        [self hiddenToolBar];
    }
    else if(ipoint.x>220)
    {
        [self JumpToAfterView];
        [self hiddenToolBar];
    }
    else
    {
        [self ShowToolBar];
    }
}

-(void)ShowToolBar
{
    if (_toolBarView.hidden)
    {
        _ishidden=NO;
        _toolBarView.hidden=!_toolBarView.hidden;
        _backView.hidden=!_backView.hidden;
    }
    else
    {
        _ishidden=YES;
        _toolBarView.hidden=!_toolBarView.hidden;
        _backView.hidden=!_backView.hidden;
    }
    if (iOS7)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:_ishidden withAnimation:UIStatusBarAnimationSlide];
        [UIView animateWithDuration:0.2 animations:^
         {
             [self setNeedsStatusBarAppearanceUpdate];
         }];
    }
}
-(void)hiddenToolBar
{
    if (!_toolBarView.hidden)
    {
        _toolBarView.hidden=YES;
        _backView.hidden=YES;
        if (iOS7)
        {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            [UIView animateWithDuration:0.2 animations:^
             {
                 [self setNeedsStatusBarAppearanceUpdate];
             }];
        }
    }
}

-(void)JumpToBeforeView
{
    NTContentViewController *viewController=[_pageViewController.viewControllers objectAtIndex:0];
    if (viewController.columnIndex!=0)
    {
        [self loadBeforeView:viewController.columnIndex];
        
        if (![_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",viewController.columnIndex-1]])
        {
            return;
        }
        NTContentViewController *BViewController = [[NTContentViewController alloc] init];
        BViewController.columnIndex=viewController.columnIndex-1;
        BViewController.allColumnCount=_allThePage;
        BViewController.PageType=-1;
        BViewController.bookName=_bookName;
        BViewController.catalogArray=_catalogArray;
        BViewController.NTbookID=_bookID;
        BViewController.isGuide=_isGuide;
        BViewController.delegate=self;
        BViewController.pageInfo=[_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",viewController.columnIndex-1]];
        NSArray *viewControllers =[NSArray arrayWithObject:BViewController];
        [_pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward  animated:NO  completion:nil];
    }
}

-(void)JumpToAfterView
{
    NTContentViewController *viewController=[_pageViewController.viewControllers objectAtIndex:0];
    
    if (viewController.columnIndex+1<_allThePage)
    {
        [self loadAfterView:viewController.columnIndex];
        
        if (![_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",viewController.columnIndex+1]])
        {
            return;
        }
        NTContentViewController *BViewController = [[NTContentViewController alloc] init];
        BViewController.columnIndex=viewController.columnIndex+1;
        BViewController.allColumnCount=_allThePage;
        BViewController.PageType=1;
        BViewController.delegate=self;
        BViewController.bookName=_bookName;
        BViewController.catalogArray=_catalogArray;
        BViewController.NTbookID=_bookID;
        BViewController.isGuide=_isGuide;
        BViewController.pageInfo=[_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",viewController.columnIndex+1]];
        NSArray *viewControllers =[NSArray arrayWithObject:BViewController];
        [_pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward  animated:NO  completion:nil];
    }
}

#pragma mark - SearchAction -

-(void)closeTheSearchView
{
    _searchToolBarView.hidden=YES;
    [self hiddenToolBar];
}

-(void)openSearchTheViewPage:(NSMutableDictionary *)pageInfo
{
    _searchToolBarView.hidden=NO;
    [self hiddenToolBar];
    [self showWaitView:nil];
    _SearchPageAry=_SearchViewController.AllPageNumAry;
    _SearchPageDic=_SearchViewController.PageNumDic;
    _AllSearchAry=_SearchViewController.AllSearchAry;
    [NSThread detachNewThreadSelector:@selector(NTOpenTheSearchViewPage:) toTarget:self withObject:pageInfo];
}

-(void)NTOpenTheSearchViewPage:(NSMutableDictionary *)pageInfo
{
    NSString *html=[pageInfo objectForKey:@"htmlName"];
    _currentPage=[[pageInfo objectForKey:@"localPoint"] intValue];
    if (_currentPage<_allThePage)
    {
        int TheAllpage=_allThePage;
        for (NSMutableDictionary *dic in _catalogInfoArray)
        {
            if ([[dic objectForKey:@"htmlName"]isEqualToString:html])
            {
              _ALLPageInfo=[_getPageInfo getTheSearchStringFromName:html withThepage:[[dic objectForKey:@"UpPageNum"] intValue] WithPoint:[pageInfo objectForKey:@"searchPointAry"] WithLength:[[pageInfo objectForKey:@"searchlength"] intValue]];
                break;
            }
        }
        _allThePage=TheAllpage;
    }
    [self showContentViewWith:YES];
}

-(void)UpSearchAction
{
    NSInteger index=[_SearchPageAry indexOfObject:[NSNumber numberWithInt:_currentPage]];
    if (index!=0)
    {
        NSNumber *pageNum=[_SearchPageAry objectAtIndex:index-1];
        NSString *page=[_SearchPageDic objectForKey:pageNum];
        NSString *currentpage=[[_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",_currentPage]] objectForKey:@"html"];
        if ([page isEqualToString:currentpage])
        {
            _currentPage=[pageNum intValue];
            [self showContentViewWith:YES];
        }
        else
        {
            NSMutableDictionary *dic;
            for (NSMutableDictionary *idic in _AllSearchAry)
            {
                if ([idic objectForKey:@"localPoint"]==pageNum)
                {
                    dic=idic;
                    break;
                }
            }
            if (dic) {
                [self NTOpenTheSearchViewPage:dic];
            }
            
        }
    }
}

-(void)NextSearchAction
{
    NSInteger index=[_SearchPageAry indexOfObject:[NSNumber numberWithInt:_currentPage]];
    if (index!=[_SearchPageAry count]-1)
    {
        NSNumber *pageNum=[_SearchPageAry objectAtIndex:index+1];
        NSString *page=[_SearchPageDic objectForKey:pageNum];
        NSString *currentpage=[[_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",_currentPage]] objectForKey:@"html"];
        if ([page isEqualToString:currentpage])
        {
            _currentPage=[pageNum intValue];
            [self showContentViewWith:YES];
        }
        else
        {
            NSMutableDictionary *dic;
            for (NSMutableDictionary *idic in _AllSearchAry)
            {
                if ([idic objectForKey:@"localPoint"]==pageNum)
                {
                    dic=idic;
                    break;
                }
            }
            if (dic) {
                [self NTOpenTheSearchViewPage:dic];
            }
        }
    }
}

-(void)showContentViewWith:(BOOL)isSearch
{
    NTContentViewController *BViewController = [[NTContentViewController alloc] init];
    BViewController.columnIndex=_currentPage;
    BViewController.allColumnCount=_allThePage;
//    BViewController.NTbookID=_bookID;
    BViewController.delegate=self;
    BViewController.bookName=_bookName;
    BViewController.catalogArray=_catalogArray;
    BViewController.isGuide=_isGuide;
    BViewController.isSearch=isSearch;
    BViewController.pageInfo=[_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",_currentPage]];
    NSArray *viewControllers =[NSArray arrayWithObject:BViewController];
    [_pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward  animated:NO  completion:nil];
    [_waitingView hide:YES];
    [self ChangeSearchState];
}

-(void)ChangeSearchState
{
    NSInteger index=[_SearchPageAry indexOfObject:[NSNumber numberWithInt:_currentPage]];
    if (index==0&&index!=[_SearchPageAry count]-1)
    {
        _searchToolBarView.UpPageButton.enabled=NO;
        _searchToolBarView.NextPageButton.enabled=YES;
    }
    else if(index!=0&&index==[_SearchPageAry count]-1)
    {
        _searchToolBarView.UpPageButton.enabled=YES;
        _searchToolBarView.NextPageButton.enabled=NO;
    }
    else if(index==0&&index==[_SearchPageAry count]-1)
    {
        _searchToolBarView.UpPageButton.enabled=NO;
        _searchToolBarView.NextPageButton.enabled=NO;
    }
    else
    {
        _searchToolBarView.UpPageButton.enabled=YES;
        _searchToolBarView.NextPageButton.enabled=YES;
    }
}

-(void)openTheViewPage:(NSMutableDictionary *)pageInfo
{
    [self showWaitView:nil];
    [NSThread detachNewThreadSelector:@selector(NTOpenTheViewPage:) toTarget:self withObject:pageInfo];
}

-(void)NTOpenTheViewPage:(NSMutableDictionary *)pageInfo
{
    NSString *html=[pageInfo objectForKey:@"htmlName"];
    _currentPage=[[pageInfo objectForKey:@"localPoint"] intValue];
    if (_currentPage<_allThePage&&![_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",_currentPage]])
    {
        int TheAllpage=_allThePage;
        for (NSMutableDictionary *dic in _catalogInfoArray)
        {
            if ([[dic objectForKey:@"htmlName"]isEqualToString:html])
            {
                [_getPageInfo getTheStringFromName:html withThepage:[[dic objectForKey:@"UpPageNum"] intValue]];
                if ([[dic objectForKey:@"FinPageNum"] intValue]-[[dic objectForKey:@"UpPageNum"] intValue]<3)
                {
                    if ([dic objectForKey:@"afterHtmlPath"])
                    {
                        [_getPageInfo getTheStringFromName:[dic objectForKey:@"afterHtmlPath"] withThepage:[[dic objectForKey:@"FinPageNum"] intValue]];
                    }
                    for (NSMutableDictionary *dic1 in _catalogInfoArray)
                    {
                        if ([[dic1 objectForKey:@"htmlName"]isEqualToString:[dic objectForKey:@"UPHtmlPath"]])
                        {
                            [_getPageInfo getTheStringFromName:[dic objectForKey:@"UPHtmlPath"] withThepage:[[dic1 objectForKey:@"UpPageNum"] intValue]];
                        }
                    }
                }
                break;
            }
        }
        _allThePage=TheAllpage;
    }
    [self showContentViewWith:NO];
}

-(void)loadBeforeView:(int)NTCurrentPage
{
    if (NTCurrentPage-1!=-1&&![_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",NTCurrentPage-1]])
    {
        [self showWaitView:nil];
        [self loadTheBeforeOtherviewWithPage:[NSNumber numberWithInt:NTCurrentPage]];
        [_waitingView hide:YES];
    }
    else if (NTCurrentPage-2!=-1&&![_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",NTCurrentPage-2]])
    {
        if (![_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",NTCurrentPage-1]])
        {
            [NSThread detachNewThreadSelector:@selector(loadTheBeforeOtherviewWithPage:) toTarget:self withObject:[NSNumber numberWithInt:NTCurrentPage-1]];
        }
        else
            [NSThread detachNewThreadSelector:@selector(loadTheBeforeOtherviewWithPage:) toTarget:self withObject:[NSNumber numberWithInt:NTCurrentPage-2]];
    }
    else if (NTCurrentPage-3!=-1&&![_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",NTCurrentPage-3]])
    {
        if (![_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",NTCurrentPage-1]])
        {
            [NSThread detachNewThreadSelector:@selector(loadTheBeforeOtherviewWithPage:) toTarget:self withObject:[NSNumber numberWithInt:NTCurrentPage-1]];
        }
        else if (![_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",NTCurrentPage-2]])
        {
            [NSThread detachNewThreadSelector:@selector(loadTheBeforeOtherviewWithPage:) toTarget:self withObject:[NSNumber numberWithInt:NTCurrentPage-2]];
        }
        else
            [NSThread detachNewThreadSelector:@selector(loadTheBeforeOtherviewWithPage:) toTarget:self withObject:[NSNumber numberWithInt:NTCurrentPage-3]];
    }
}

-(void)loadAfterView:(int)NTCurrentView
{
    if (NTCurrentView+1!=_allThePage&&![_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",NTCurrentView+1]])
    {
        [self showWaitView:nil];
        [self loadTheAfterOtherviewWithPage:[NSNumber numberWithInt:NTCurrentView]];
        [_waitingView hide:YES];
    }
    else if (NTCurrentView+2<_allThePage&&![_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",NTCurrentView+2]])
    {
        if(![_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",NTCurrentView+1]])
        {
            [NSThread detachNewThreadSelector:@selector(loadTheAfterOtherviewWithPage:) toTarget:self withObject:[NSNumber numberWithInt:NTCurrentView+1]];
        }
        else
            [NSThread detachNewThreadSelector:@selector(loadTheAfterOtherviewWithPage:) toTarget:self withObject:[NSNumber numberWithInt:NTCurrentView+2]];
    }
    else if (NTCurrentView+3<_allThePage&&![_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",NTCurrentView+3]])
    {
        if(![_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",NTCurrentView+1]])
        {
            [NSThread detachNewThreadSelector:@selector(loadTheAfterOtherviewWithPage:) toTarget:self withObject:[NSNumber numberWithInt:NTCurrentView+1]];
        }
        else if (![_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",NTCurrentView+2]])
        {
            [NSThread detachNewThreadSelector:@selector(loadTheAfterOtherviewWithPage:) toTarget:self withObject:[NSNumber numberWithInt:NTCurrentView+2]];
        }
        else
            [NSThread detachNewThreadSelector:@selector(loadTheAfterOtherviewWithPage:) toTarget:self withObject:[NSNumber numberWithInt:NTCurrentView+3]];
    }
}

-(void)loadTheAfterOtherviewWithPage:(NSNumber*)page
{
//    int TheAllpage=_allThePage;
    NSString *html=[[_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",page.intValue]] objectForKey:@"html"];
    for (NSMutableDictionary *dic in _catalogInfoArray)
    {
        if ([[dic objectForKey:@"htmlName"]isEqualToString:html])
        {
            if (![dic objectForKey:@"afterHtmlPath"])
            {
                return;
            }
            [_getPageInfo getTheStringFromName:[dic objectForKey:@"afterHtmlPath"] withThepage:[[dic objectForKey:@"FinPageNum"] intValue]];
            for (NSMutableDictionary *idic in _catalogInfoArray)
            {
                if ([[idic objectForKey:@"htmlName"]isEqualToString:[dic objectForKey:@"afterHtmlPath"]])
                {
                    int finPage=[[idic objectForKey:@"FinPageNum"] intValue];
                    int upPage=[[idic objectForKey:@"UpPageNum"] intValue];
                    if (finPage-upPage<5&&[[idic objectForKey:@"afterHtmlPath"] length]>5)
                    {
                        [_getPageInfo getTheStringFromName:[idic objectForKey:@"afterHtmlPath"] withThepage:[[idic objectForKey:@"FinPageNum"] intValue]];
                    }
                }
            }
            break;
        }
    }
//    _allThePage=TheAllpage;
}

-(void)loadTheBeforeOtherviewWithPage:(NSNumber*)page
{
//    int TheAllpage=_allThePage;
    NSString *html=[[_ALLPageInfo objectForKey:[NSString stringWithFormat:@"%d",page.intValue]] objectForKey:@"html"];
    for (NSMutableDictionary *dic in _catalogInfoArray)
    {
        if ([[dic objectForKey:@"htmlName"]isEqualToString:html])
        {
            if (![dic objectForKey:@"UPHtmlPath"])
            {
                return;
            }
            for (NSMutableDictionary *idic in _catalogInfoArray)
            {
                if ([[dic objectForKey:@"UPHtmlPath"]isEqualToString:[idic objectForKey:@"htmlName"]])
                {
                    [_getPageInfo getTheStringFromName:[dic objectForKey:@"UPHtmlPath"] withThepage:[[idic objectForKey:@"UpPageNum"] intValue]];
                    int finPage=[[idic objectForKey:@"FinPageNum"] intValue];
                    int upPage=[[idic objectForKey:@"UpPageNum"] intValue];
                    if (finPage-upPage<5)
                    {
                        for (NSMutableDictionary *iidic in _catalogInfoArray)
                        {
                            if ([[idic objectForKey:@"UPHtmlPath"]isEqualToString:[iidic objectForKey:@"htmlName"]])
                            {
                                [_getPageInfo getTheStringFromName:[idic objectForKey:@"UPHtmlPath"] withThepage:[[iidic objectForKey:@"UpPageNum"] intValue]];
                                break;
                            }
                        }
                    }
                    break;
                }
            }
        }
    }
//    _allThePage=TheAllpage;
}

#pragma mark - showWaitView -

-(void)showWaitView:(NSString *)string
{
    if (!_waitingView)
    {
        _waitingView =[[MBProgressHUD  alloc] initWithView:self.view];
        [self.view addSubview:_waitingView];
        
    }
    [self.view bringSubviewToFront:_waitingView];
    if (!string||string.length<3)
    {
        string=@"加载中...";
    }
    _waitingView.labelText=string;
    _waitingView.mode = MBProgressHUDModeIndeterminate;
    [_waitingView show:YES];
}
-(void)showEndText:(NSString *)string
{
    if (!string.length>0)
    {
        string=@"网络连接不畅哦！";
    }
    if (!_waitingView)
    {
        _waitingView =[[MBProgressHUD  alloc] initWithView:self.view];
        [self.view addSubview:_waitingView];
    }
    _waitingView.labelText=string;
    _waitingView.mode = MBProgressHUDModeText;
    [_waitingView show:YES];
    [_waitingView performSelector:@selector(hide:) withObject:nil afterDelay:0.5];
}

#pragma mark - imageShow -

-(void)showImage
{
//    [self shouldAutorotate];
//    [self supportedInterfaceOrientations];
    //旋转屏幕，但是只旋转当前的View
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
//    _SImageView.transform = CGAffineTransformMakeRotation(M_PI/2);
//    CGRect frame = [UIScreen mainScreen].applicationFrame;
//    _SImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
//    _SImageView.imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
//    _SImageView.backView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationPortrait;
//}

-(BOOL)shouldAutorotate
{
//    if (_SImageView&&_SImageView.hidden==NO)
//    {
        return NO;
//    }
//    else
//        return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
//    CGRect frame = [UIScreen mainScreen].applicationFrame;
//    NSLog(@"===%f---%f",frame.size.height,frame.size.width);
//    NSLog(@"---%d",[[UIApplication sharedApplication] statusBarOrientation]);
//    
//    if (_SImageView&&_SImageView.hidden==NO)
//    {
//        return UIInterfaceOrientationMaskAllButUpsideDown;
//    }
//    else
//    {
        return UIInterfaceOrientationMaskPortrait;
//    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation==UIInterfaceOrientationPortrait)
    {
//        CGRect frame = [UIScreen mainScreen].applicationFrame;
//        NSLog(@"===%f---%f",frame.size.height,frame.size.width);
//        self.view.frame=CGRectMake(0, 0, frame.size.height, frame.size.width);
    }
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation==UIInterfaceOrientationPortrait)
    {
        CGRect frame = [UIScreen mainScreen].applicationFrame;
//        NSLog(@"===%f---%f",frame.size.height,frame.size.width);
        self.view.frame=frame;
    }
}

#pragma mark - catalog -

-(void)back
{
    _backView.backButton.enabled=NO;
    if (_isGuide)
    {
        NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *bookPath=[path stringByAppendingString:[NSString stringWithFormat:@"/%@/%@/OPS/images/cover.jpg",_bookName,_bookName]];
        NSFileManager *fileManager=[[NSFileManager alloc] init];
        if (![fileManager fileExistsAtPath:bookPath])
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        UIImageView *imageView1=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,ScreenHeight)];
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0-ScreenWidth, 0, ScreenWidth,ScreenHeight)];
        imageView.backgroundColor=[UIColor clearColor];
        imageView.image=[UIImage imageWithContentsOfFile:bookPath];
        [UIView animateWithDuration:0.8 animations:^
         {
             imageView.transform = CGAffineTransformMakeTranslation(ScreenWidth, 0);
         } completion:^(BOOL finished)
         {
             imageView1.backgroundColor=[UIColor clearColor];
             imageView1.image=[UIImage imageWithContentsOfFile:bookPath];
             [imageView removeFromSuperview];
             [self dismissViewControllerAnimated:NO completion:nil];
             [UIView animateWithDuration:0.4 animations:^{
                 imageView1.transform = CGAffineTransformMakeScale(0.3, 0.3);
                 imageView1.alpha = 0;
             } completion:^(BOOL finished){
                 [imageView1 removeFromSuperview];
             }];
         }];
        [[[UIApplication sharedApplication] keyWindow] addSubview:imageView1];
        [[[UIApplication sharedApplication] keyWindow] addSubview:imageView];
    }
    else
    {
        NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *bookPath=[path stringByAppendingString:[NSString stringWithFormat:@"/%@/%@/OPS/images/cover.jpg",_bookName,_bookName]];
        
        UIImageView *imageView1=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,ScreenHeight)];
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0-ScreenWidth, 0, ScreenWidth,ScreenHeight)];
        imageView.backgroundColor=[UIColor clearColor];
        imageView.image=[UIImage imageWithContentsOfFile:bookPath];
        [UIView animateWithDuration:0.8 animations:^
         {
             imageView.transform = CGAffineTransformMakeTranslation(ScreenWidth, 0);
         } completion:^(BOOL finished)
         {
             imageView1.backgroundColor=[UIColor clearColor];
             imageView1.image=[UIImage imageWithContentsOfFile:bookPath];
             [imageView removeFromSuperview];
             [self dismissViewControllerAnimated:NO completion:nil];
             [UIView animateWithDuration:0.4 animations:^{
                 imageView1.transform = CGAffineTransformMakeScale(0.3, 0.3);
                 imageView1.alpha = 0;
             } completion:^(BOOL finished){
                 [imageView1 removeFromSuperview];
             }];
         }];
        [[[UIApplication sharedApplication] keyWindow] addSubview:imageView1];
        [[[UIApplication sharedApplication] keyWindow] addSubview:imageView];
    }
}

-(void)showCatalog
{
    if (!_CatalogView)
    {
        _CatalogView=[[NTCatalogViewController alloc] init];
        _CatalogView.view.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _CatalogView.catalogArray=_catalogArray;
        _CatalogView.delegate=self;
    }
    [self.view addSubview:_CatalogView.view];
    [self.view bringSubviewToFront:_CatalogView.view];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.type =kCATransitionPush;
    transition.subtype =kCATransitionFromLeft;
    [_CatalogView.view.layer addAnimation:transition forKey:@"animation"];
    _CatalogView.view.hidden=NO;
//    [self presentViewController:_CatalogView animated:NO completion:nil];
    [self ShowToolBar];
}

-(void)SearchAction
{
    if (!_SearchViewController)
    {
        _SearchViewController=[[NTEpubSearchViewController alloc] init];
        //    iviewController.dic=_ALLPageInfo;
        _SearchViewController.infoAry=_catalogInfoArray;
        _SearchViewController.BasePath=_bookPath;
        _SearchViewController.view.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _SearchViewController.delegate=self;
        [self.view addSubview:_SearchViewController.view];
    }
    [self.view bringSubviewToFront:_SearchViewController.view];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.type =kCATransitionPush;
    transition.subtype =kCATransitionFromTop;
    _SearchViewController.view.hidden=NO;
    [_SearchViewController ResetStatusBar];
    if (!_SearchViewController.searchText.text.length>0) {
        [_SearchViewController.searchText becomeFirstResponder];
    }
    [_SearchViewController.view.layer addAnimation:transition forKey:@"animation"];
    
}

-(void)NeedParseHtml
{
    [_getPageInfo parseHtmlAgain:YES];
    if (_getPageInfo.NTAllPage!=_allThePage)
    {
        _ALLPageInfo=_getPageInfo.AllPageInfo;
        _allThePage=_getPageInfo.NTAllPage;
        _catalogInfoArray=_getPageInfo.CatalogInfoArray;
        _catalogArray=_getPageInfo.NcxCatalogArray;
    }
    
}

@end
