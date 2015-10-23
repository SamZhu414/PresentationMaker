//
//  CreationEditViewController.m
//  PresentationCreator
//
//  Created by songyang on 15/10/12.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import "CreationEditViewController.h"
#import "CollectionViewCell.h"
#import "FooterView.h"
#import "AddEditViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "PreviewViewController.h"
#import "EditNowViewController.h"


@interface CreationEditViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UIWebViewDelegate, UITextViewDelegate>
@property (nonatomic, retain) UIView *backgorundView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) NSMutableArray *htmeArray;
@property (nonatomic ,strong) UIWebView *webView;
@property (nonatomic ,strong) NSString *fullPath;
@property (nonatomic, strong) NSString *imgIndex;

@property (nonatomic, strong) NSMutableArray *htmlCodeArray;//html代码数组
@property (nonatomic, strong) NSString *templateHtmlCode;
@property (nonatomic, strong) NSMutableArray *detailsArray;//获取details表对象

@property (nonatomic, strong) NSString *maxSummaryIdStr;//取summary表中最大的主键值
@property (nonatomic, strong) NSString *summaryNameStr;
@property (nonatomic, strong) NSString *returnTempleIdStr;

@property (nonatomic, strong) UIControl *titleViewControl;
@property (nonatomic, strong) UITextView *titleTextView;

@end

@implementation CreationEditViewController

-(void)collectionCellAdd:(NSNotification*)sender
{
    if ([sender.name isEqual:@"EditNotification"])
    {
        NSLog(@"%@",sender.object);
        [self.htmeArray addObject:sender.object];
        self.returnTempleIdStr = [NSString stringWithFormat:@"%@",sender.object];
        
//        NSInteger strInteger = indexPath.row +1;
//        NSString *str = [NSString stringWithFormat:@"%ld",(long)strInteger];
        NSString *htmlStr = [[NSString alloc]init];
        htmlStr = [DBDaoHelper selectCreationPageString:self.returnTempleIdStr];
        
            NSLog(@"%@",htmlStr);
            NSLog(@"%ld",(long)self.maxSummaryIdStr);
        [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:self.returnTempleIdStr HtmlCode:htmlStr];
    }
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewWillAppear:(BOOL)animated
{
    self.parentViewController.tabBarController.tabBar.hidden = YES;
//    self.navigationItem.hidesBackButton =YES;//隐藏系统自带导航栏按钮
    self.navigationItem.title=self.summaryNameStr;
    NSLog(@"133%@",self.navigationController.viewControllers);
    //监听返回的
    
    self.detailsArray = [DBDaoHelper selectDetailsDataBySummaryId:self.maxSummaryIdStr];
    
    [self.collectionView reloadData];
}
- (void)viewWillDisappear:(BOOL)animated {
    self.parentViewController.tabBarController.tabBar.hidden = NO;
//    self.navigationItem.hidesBackButton =NO;//隐藏系统自带导航栏按钮
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionCellAdd:) name:@"EditNotification" object:nil];
    self.view.backgroundColor = [UIColor blackColor];
    [self addNavigation];
    [self addCollectionView];
    [self addClick];
    //    [self addFooter];
    
    _fullPath = [[NSString alloc]init];
}
-(void)addClick
{
    _titleViewControl = [[UIControl alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
    _titleViewControl.backgroundColor = [UIColor grayColor];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.frame = CGRectMake(20, 20, KScreenWidth, 30);
    titleLabel.text = @"Presentation name:";
    [_titleViewControl addSubview:titleLabel];
    
    _titleTextView = [[UITextView alloc]init];
    _titleTextView.frame = CGRectMake(20, 50, KScreenWidth-40, KScreenHeight*0.25);
    _titleTextView.delegate = self;
    _titleTextView.backgroundColor = [UIColor whiteColor];
   // [_titleTextView setText: @"aa"];
    [_titleTextView becomeFirstResponder];
    [_titleViewControl addSubview:_titleTextView];
    
    // 点击OK按钮，保存到summary表中，并返回最大的主键。
    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeSystem];
    okButton.frame = CGRectMake(20 , 30 + KScreenHeight*0.25 + 40, KScreenWidth-40, 40);
    [okButton setTitle:@"OK" forState:UIControlStateNormal];
    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    okButton.backgroundColor = [UIColor darkGrayColor];
    okButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [okButton.layer setMasksToBounds:YES];
    
    [okButton.layer setBorderWidth:1.0];
    [okButton.layer setCornerRadius:7.0];
    okButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [_titleViewControl addSubview:okButton];

    [okButton addTarget:self action:@selector(saveSummaryTile) forControlEvents:UIControlEventTouchUpInside];
   
    [self.view addSubview:_titleViewControl];
    [self.view bringSubviewToFront:_titleViewControl];

}
-(void)saveSummaryTile{
    self.summaryNameStr = _titleTextView.text;
    self.maxSummaryIdStr = [DBDaoHelper insertSummaryWithName:_titleTextView.text];
    [_titleViewControl removeFromSuperview ];
    _titleViewControl = nil;
}
-(void)addNavigation
{
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    btnRight.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    //    btnLeft.backgroundColor = [UIColor redColor];
    btnRight.frame = CGRectMake(0, 0, 60, 30);
    [btnRight setTitle:@"Preview" forState:UIControlStateNormal];
    [btnRight addTarget:self action:@selector(previewClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *preview = [[UIBarButtonItem alloc]initWithCustomView:btnRight];
    self.navigationItem.rightBarButtonItem = preview;
    
    self.htmlCodeArray = [[NSMutableArray alloc]init];
}
-(void)previewClick:(UIButton*)sender
{
    PreviewViewController *vc = [[PreviewViewController alloc]init];
    vc.showSummaryIdStr = self.maxSummaryIdStr;
    vc.showSummaryNameStr = self.summaryNameStr;
    vc.showTemplateIdStr = self.returnTempleIdStr;
    [self.navigationController pushViewController:vc animated:YES];
    
//    self.tabBarController.selectedIndex = 0;//点击按钮回到第一个tabbar

}

-(void)backgroundClick
{
    UIActionSheet *sheet;
    
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册选择", nil];
    }
    else {
        
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
    }
    
    sheet.tag = 255;
    
    [sheet showInView:self.view];
}
-(void)recordClick
{
    
}
#pragma mark - 保存图片至沙盒
- (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    // 获取沙盒目录
    
    _fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    NSLog(@"%@",_fullPath);
    [self loadHtmlToWebView];
    // 将图片写入文件
    
    
    [imageData writeToFile:_fullPath atomically:NO];
    
}
#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self saveImage:image withName:@"currentImage.png"];
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"currentImage.png"];
    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
    
    
    isFullScreen = NO;
    [self.imageView setImage:savedImage];
    
    self.imageView.tag = 100;
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}
#pragma mark - actionsheet delegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        
        NSUInteger sourceType = 0;
        
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            switch (buttonIndex) {
                case 0:
                    // 取消
                    return;
                case 1:
                    // 相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                    
                case 2:
                    // 相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
            }
        }
        else {
            if (buttonIndex == 0) {
                
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        
        imagePickerController.delegate = self;
        
        imagePickerController.allowsEditing = YES;
        
        imagePickerController.sourceType = sourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:^{}];
        
        
    }
}
-(void)addCollectionView
{
    UIView *aView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:aView];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    flowLayout.footerReferenceSize = CGSizeMake(KScreenWidth-20, KScreenHeight-64-40);//头部.尾部设置
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 84, KScreenWidth-20, KScreenHeight-64-40) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    //设置代理
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    
    //注册cell和ReusableView（相当于头部）
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ReusableView"];
    
    _footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth-20, KScreenHeight-64-40)];
    _footerView.backgroundColor = [UIColor blackColor];
    
    //添加界面
    UIButton *addPageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addPageBtn.frame = CGRectMake((KScreenWidth-120)/2, 185, 120, 60);
    addPageBtn.tintColor = [UIColor whiteColor];
    addPageBtn.layer.borderWidth = 1;
    addPageBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    [addPageBtn setTitle:@"添加界面" forState:UIControlStateNormal];
    [addPageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [addPageBtn addTarget:self action:@selector(addPageClick) forControlEvents:UIControlEventTouchUpInside];
    [_footerView addSubview:addPageBtn];
    
}
-(void)addPageClick
{
    //    //    [self presentViewController:loginVC animated:YES completion:^{
    //    //        NSLog(@"call back!");
    //    //    }];
    
    //模态跳转
    AddEditViewController *loginVC = [[AddEditViewController alloc]init];
    

    UINavigationController * navigation = [[UINavigationController alloc]initWithRootViewController:loginVC];
    
    [self presentViewController:navigation animated:YES completion:nil];
    
    
//    AddEditViewController *vc = [[AddEditViewController alloc]init];
//    
//    [self.navigationController pushViewController:vc animated:YES];
}
-(void)addTableClick
{
    
}
//头部显示的内容
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ReusableView" forIndexPath:indexPath];
    UIView *aview = [[UIView alloc]init];
    aview.frame = CGRectMake(0, 0, 0, 0);
    [self.view addSubview:aview];
    [footerView addSubview:_footerView];//头部广告栏
    
    return footerView;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.detailsArray.count;
}
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    
    //取出对象在 arrTemp中取出
    DetailsModel *model = [self.detailsArray objectAtIndex:indexPath.row];
    UIView *aview = [[UIView alloc]init];
    aview.frame = CGRectMake(0, 0, 0, 0);
    [cell addSubview:aview];
    self.webView = [[UIWebView alloc]init];
    self.webView.frame = CGRectMake(0, 0, KScreenWidth-20, KScreenHeight-64-40);
    self.webView.tag = indexPath.row;
    self.webView.backgroundColor = [UIColor blackColor];
    NSString *path = [[NSBundle mainBundle]bundlePath];
    NSURL *baseUrl = [NSURL fileURLWithPath:path];
    [self.webView loadHTMLString:model.htmlCodeStr baseURL:baseUrl];
    [cell addSubview:self.webView];
    [self loadHtmlToWebView];
//    cell.backgroundColor = [UIColor redColor];
    
    UIView *backgroundView = [[UIView alloc]init];
    backgroundView.frame = CGRectMake(0, 0, KScreenWidth-20, KScreenHeight-64-40);
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewClick:)];
    backgroundView.tag=indexPath.row;
    backgroundView.userInteractionEnabled=YES;
    [backgroundView addGestureRecognizer:tapGesture1];
    [cell addSubview:backgroundView];
    return cell;
}
-(void)viewClick:(UITapGestureRecognizer *)recognizer
{
    UIView *viewT = [recognizer view];
    NSLog(@"%ld",(long)viewT.tag);
    //从detailsArray中获取detailsid
    DetailsModel *model = [self.detailsArray objectAtIndex:viewT.tag];
    NSLog(@"%@",model.detailsIdStr);
    
    EditNowViewController *vc = [[EditNowViewController alloc]init];
    vc.editNowDetailsIdStr = model.detailsIdStr;
    vc.editNowSummaryNameStr = self.summaryNameStr;
    vc.editNowHtmlCodeStr = model.htmlCodeStr;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(KScreenWidth-20, KScreenHeight-64-20);
}
//定义每个UICollectionView 的间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(1,1, 1, 1);
}
//定义每个UICollectionView 纵向的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell * cell = (CollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
}

#pragma mark - webview JSContext
-(void)loadHtmlToWebView{
    
    JSContext *context = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    context[@"clickedText"] = ^() {
        NSLog(@"Begin text");
        NSArray *args = [JSContext currentArguments];
        
        //        NSString *mySt = [args componentsJoinedByString:@","];
        NSLog(@"input mySt:%@", args[0]);
        NSLog(@"input mySt:%@", args[1]);
        NSString *htmlVal = [[NSString alloc]initWithFormat:@"%@",args[0]];
        NSString *htmlIndex =[[NSString alloc]initWithFormat:@"%@",args[1]];
        [self editTextComponent:htmlVal :htmlIndex];
        
        NSLog(@"-------End Text-------");
        
    };
    //点击图片js方法调用native
    context[@"clickedImage"] = ^() {
        NSLog(@"Begin image");
        
        NSArray *args = [JSContext currentArguments];
        
        NSLog(@"input mySt:%@", args[0]);
        _imgIndex = [[NSString alloc]initWithFormat:@"%@",args[0]];
        [self editImageComponent:_fullPath :_imgIndex];
        //        [self editImageComponent: @"/Users/linlecui/Desktop/10c58PIC2CK_1024.jpg" : imgIndex];//加载本地图片到webview,把图片的索引传给方法
        [self backgroundClick];
        
        NSLog(@"-------End Image-------");
    };
    
}

-(void)editTextComponent:(NSString *)param1 : (NSString *)param2{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Message Alert" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        
        textField.placeholder = @"please type your message";
        
        textField.text = param1;
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // NSString *getTextMessage = textField.text;
        UITextField *login = alertController.textFields.firstObject;
        NSString *newMessage = login.text;
        NSString *str = @"var field = document.getElementsByClassName('text_element')[";
        str = [str stringByAppendingString:param2];
        str = [str stringByAppendingString:@"];"];
        str = [str stringByAppendingString:@" field.innerHTML='"];
        str = [str stringByAppendingString:newMessage];
        str = [str stringByAppendingString:@"';"];
        
        NSLog(@"final javascript:%@",str);
        [_webView stringByEvaluatingJavaScriptFromString:str];
        
        NSLog(@"get message:%@",login.text);
        
    }];
    
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)editImageComponent:(NSString *)imgName : (NSString *)index{
    
    //拼接js字符串，用于替换图片
    NSString *str = @"var field = document.getElementsByClassName('img_element')[";
    str = [str stringByAppendingString:index];
    str = [str stringByAppendingString:@"];"];
    str = [str stringByAppendingString:@" field.src='"];
    str = [str stringByAppendingString:imgName];
    str = [str stringByAppendingString:@"';"];
    
    NSLog(@"final javascript:%@",str);
    [_webView stringByEvaluatingJavaScriptFromString:str];//js字符串通过这个方法传递到webview中的html并执行此js
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
