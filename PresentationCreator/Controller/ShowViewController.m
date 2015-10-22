//
//  ShowViewController.m
//  PresentationCreator
//
//  Created by songyang on 15/9/29.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import "ShowViewController.h"
#import "EditViewController.h"
#import "DetailsModel.h"
#import "Global.h"
#import "DBDaoHelper.h"

@interface ShowViewController ()<UIWebViewDelegate>
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, strong) NSMutableArray *detailsListMuArray;
@property (nonatomic, strong) NSString *getHtmlFromSummaryStr;
@property (nonatomic, strong) NSString *stringSections;
@property (nonatomic, strong) NSString *finalHtmlCode;

@end

@implementation ShowViewController
-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
    [self getHtmlCodeFromSummary];
    [self addWebView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addNavigation];
    self.navigationItem.title= self.showSummaryNameStr;
}
-(void)addNavigation
{
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnRight.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    //    btnLeft.backgroundColor = [UIColor redColor];
    btnRight.frame = CGRectMake(0, 0, 50, 30);
    [btnRight setTitle:@"Edit" forState:UIControlStateNormal];
    [btnRight addTarget:self action:@selector(EditClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *Edit = [[UIBarButtonItem alloc]initWithCustomView:btnRight];
    self.navigationItem.rightBarButtonItem = Edit;
    
    UIButton *backbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //    backbtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    backbtn.frame = CGRectMake(0, 0, 40, 30);
    [backbtn setTitle:@"Back" forState:UIControlStateNormal];
    [backbtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *SearchItem = [[UIBarButtonItem alloc]initWithCustomView:backbtn];
    //    [rightbtn setBackgroundImage:[UIImage imageNamed:@"set"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = SearchItem;
}
-(void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)EditClick
{
    EditViewController *vc = [[EditViewController alloc]init];
    NSLog(@"%@",self.showSummaryNameStr);
    NSLog(@"%@",self.showTemplateIdStr);
    vc.showSummaryNameStr = self.showSummaryNameStr;
    vc.showTemplateIdStr = self.showTemplateIdStr;
    vc.showSummaryIdStr = self.showSummaryIdStr;
    [self.navigationController pushViewController:vc animated:YES];
}

//从summary 表中根据summary id获取html代码，并加载到webView中
-(void)getHtmlCodeFromSummary{
    NSLog(@"sssss dd");
    _finalHtmlCode = [DBDaoHelper queryHtmlCodeFromSummary:_showSummaryIdStr];
    
}

-(void)addWebView
{
    UIView *aView = [[UIView alloc]init];
    aView.frame = CGRectMake(0, 0, 0, 0);
    [self.view addSubview:aView];
    
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, KScreenWidth, KScreenHeight-64)];
    _webView.delegate = self;
    _webView.backgroundColor = [UIColor redColor];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [_webView loadHTMLString:_finalHtmlCode baseURL:baseURL];
    [self.view addSubview: _webView];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
