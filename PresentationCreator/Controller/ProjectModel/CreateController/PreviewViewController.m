//
//  PreviewViewController.m
//  PresentationCreator
//
//  Created by songyang on 15/10/15.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import "PreviewViewController.h"
#import "DetailsModel.h"
#import "Global.h"
#import "CreationEditViewController.h"

@interface PreviewViewController ()<UIWebViewDelegate>
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, strong) NSMutableArray *detailsListMuArray;
@property (nonatomic, strong) NSString *stringSections;
@property (nonatomic, strong) NSString *finalHtmlCode;

@end

@implementation PreviewViewController

-(void)viewWillAppear:(BOOL)animated
{
//    self.tabBarController.viewControllers
    self.parentViewController.tabBarController.tabBar.hidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    self.parentViewController.tabBarController.tabBar.hidden = NO;
    //    self.navigationItem.hidesBackButton =NO;//隐藏系统自带导航栏按钮
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addNavigation];
    [self loadDetailsDataToArray];
    [self generationFinalHtmlCode];
    [self addWebView];
    self.navigationItem.title= self.showSummaryNameStr;
//    self.tabBarController.delegate = self;
}
-(void)addNavigation
{
    UIButton *backbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //    backbtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    backbtn.frame = CGRectMake(0, 0, 40, 30);
    [backbtn setTitle:@"Back" forState:UIControlStateNormal];
    [backbtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:backbtn];
    //    [rightbtn setBackgroundImage:[UIImage imageNamed:@"set"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //    btnRight.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    //    btnLeft.backgroundColor = [UIColor redColor];
    btnRight.frame = CGRectMake(0, 0, 60, 30);
    [btnRight setTitle:@"Save" forState:UIControlStateNormal];
    [btnRight addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]initWithCustomView:btnRight];
    self.navigationItem.rightBarButtonItem = doneItem;
}
-(void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doneClick
{
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"newJianting" object:@"0"];
    self.tabBarController.selectedIndex = 0;//点击按钮回到第一个tabbar
    
}
//查询summaryhtmlcode 加载到webview 进行总的预览
-(void)loadDetailsDataToArray{
    NSString *sections = [[NSString alloc] init];
    _detailsListMuArray = [DBDaoHelper selectDetailsDataBySummaryId:self.showSummaryIdStr];//播放的details表的summaryid
    for (int i =0; i<_detailsListMuArray.count; i++) {
        DetailsModel *dm = [_detailsListMuArray objectAtIndex:i];
        
        NSString *tmp = [self processStringWithSection:dm.htmlCodeStr :i+1];
        sections = [sections stringByAppendingString:tmp];
    }
    _stringSections = sections;
    NSLog(@"my html code is:::%@", _stringSections);
    
}
//处理section 拼接字符串
-(NSString *)processStringWithSection:(NSString *)htmlCode :(NSInteger) currentRowIndex{
    
    NSRange rangeStartSection = [htmlCode rangeOfString:@"<section"];
    NSInteger startLocation = rangeStartSection.location;
    
    
    //-substringFromIndex: 以指定位置开始（包括指定位置的字符），并包括之后的全部字符
    NSString *stringStart = [htmlCode substringFromIndex:startLocation];
    
    
    NSRange rangeEndSection = [stringStart rangeOfString:@"</section>"];
    NSInteger endLocation = rangeEndSection.location;
    
    //-substringToIndex: 从字符串的开头一直截取到指定的位置，但不包括该位置的字符 +10表示包括</section>
    NSString *stringEnd = [stringStart substringToIndex:endLocation+10];
    
    NSMutableString *finalString = [[NSMutableString alloc] initWithString:stringEnd];
    
    NSString *className = @"<section class='swiper-slide swiper-slide" ;
    
    className =  [className stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)currentRowIndex]];
    className = [className stringByAppendingFormat:@"'"];
    
    [finalString replaceCharactersInRange:NSMakeRange(0,9) withString:className];
    
    return  finalString;
}
//生成最终的html代码保存到summary表中
-(void)generationFinalHtmlCode{
    NSString *htmlCodes = final_html_befor_section;
    htmlCodes = [htmlCodes stringByAppendingString:_stringSections];
    htmlCodes = [htmlCodes stringByAppendingString:final_html_after_section];
    [DBDaoHelper updateSummaryContentById : htmlCodes : self.showSummaryIdStr];
    _finalHtmlCode = htmlCodes;
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
