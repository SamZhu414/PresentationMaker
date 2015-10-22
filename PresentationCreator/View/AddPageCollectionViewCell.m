//
//  AddPageCollectionViewCell.m
//  PresentationCreator
//
//  Created by songyang on 15/10/8.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import "AddPageCollectionViewCell.h"

@implementation AddPageCollectionViewCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, (KScreenWidth-10-5)/2, (KScreenHeight-64-20)/2)];
        self.imgView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:self.imgView];
//        self.webView = [[UIWebView alloc]init];
//        self.webView.frame = CGRectMake(0, 0, (KScreenWidth-10-5)/2, (KScreenHeight-64-10)/2);
//        self.webView.backgroundColor = [UIColor redColor];
//        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
//        NSString *filePath = [resourcePath stringByAppendingPathComponent:@"template_1.html"];
//        NSString *htmlString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
//        [self.webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
//        [self addSubview:self.webView];
    }
    return self;
}
@end
