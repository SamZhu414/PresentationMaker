//
//  AdvertisingColumn.m
//  CustomTabBar
//
//  Created by shikee_app05 on 14-12-30.
//  Copyright (c) 2014年 chan kaching. All rights reserved.
//

#import "FooterView.h"
#import "AddPageViewController.h"

@implementation FooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    
//        //添加界面
//        UIButton *addPageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        addPageBtn.frame = CGRectMake((KScreenWidth-80)/2-40, 85, 80, 30);
//        addPageBtn.tintColor = [UIColor whiteColor];
//        [addPageBtn setTitle:@"添加界面" forState:UIControlStateNormal];
//        [addPageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//        [addPageBtn addTarget:self action:@selector(addPageClick) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:addPageBtn];
//        
//        //白线
//        UIView *lineView = [[UIView alloc]init];
//        lineView.frame = CGRectMake(0, 199, KScreenWidth-80, 1);
//        lineView.backgroundColor = [UIColor whiteColor];
//        [self addSubview:lineView];
//        //添加界面
//        UIButton *addTableBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        addTableBtn.frame = CGRectMake((KScreenWidth-80)/2-40, 285, 80, 30);
//        addTableBtn.tintColor = [UIColor whiteColor];
//        [addTableBtn setTitle:@"添加表单" forState:UIControlStateNormal];
//        [addTableBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//        [addTableBtn addTarget:self action:@selector(addTableClick) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:addTableBtn];
    }
    return self;
}
-(void)addPageClick
{

}
-(void)addTableClick
{
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
