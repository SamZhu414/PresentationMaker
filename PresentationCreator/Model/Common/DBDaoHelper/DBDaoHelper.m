//
//  DBDaoHelper.m
//  PresentationCreator
//
//  Created by songyang on 15/10/11.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import "DBDaoHelper.h"
#import "Global.h"

@implementation DBDaoHelper
//创建所有的数据库表
+(BOOL)createAllTable{
    FMDatabase *db =[DBHelper openDatabase];
    BOOL result1 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS 'PPT_PRODUCT_TEMPLATE'('template_id'INTEGER PRIMARY KEY AUTOINCREMENT,'template_html'varchar)"];
    //summary_name tableview创建ppt的名称 content_html最终生成的总的用于演示的html代码
    BOOL result2 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS 'PPT_PRODUCT_SUMMARY'('summary_id'INTEGER PRIMARY KEY AUTOINCREMENT,'summary_name'varchar,'content_html'varchar)"];
    //details_id主键 summary_id 外键关联到PPT_PRODUCT_SUMMARY表的主键 template_id关联到PPT_PRODUCT_template表的主键
    BOOL result3 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS 'PPT_PRODUCT_DETAILS'('details_id'INTEGER PRIMARY KEY AUTOINCREMENT,'summary_id'integer,'template_id'integer,'html_code'varchar)"];
    [db close];
    if (result1&&result2&&result3) {
        return YES;
    }else{
        return NO;
    }
}

//查询是否存在数据 加载html代码
+(NSString *)selectTable
{
    FMDatabase *db = [DBHelper openDatabase];
    FMResultSet *result = [db executeQuery:@"select * from 'PPT_PRODUCT_TEMPLATE'"];
    
    while (result.next)
    {
        NSString *str = [result stringForColumn:@"template_id"];
        return str;
    }
    [db close];
    return nil;
}
//插入html代码
+(BOOL )insetIntoTemplateHtml:(NSString *)templateHtml
{
    FMDatabase *db = [DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"insert into 'PPT_PRODUCT_TEMPLATE'('template_html') values(?)",templateHtml];
    [db close];
    return result;
}
//向summary表中插入我的名字，返回最大的主键值
+(NSString *)insertSummaryWithName:(NSString *)name{
    FMDatabase *db =[DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"insert into 'PPT_PRODUCT_SUMMARY'('summary_name') values(?)",name];
    if (result) {
        FMResultSet *result1 = [db executeQuery:@"SELECT  MAX(SUMMARY_ID) FROM PPT_PRODUCT_SUMMARY"];
        
        while (result1.next)
        {
            
            NSString *str = [result1 stringForColumnIndex:0];
            [db close];
            return str;
        }
    }
    [db close];
    return nil;
}

//查询table数组内容
+(NSMutableArray *)selectTableArray
{
    FMDatabase *db =[DBHelper openDatabase];
    //执行查询语句
    FMResultSet *result = [db executeQuery:@"select * from PPT_PRODUCT_SUMMARY "];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    //当下边还有分类的时候执行
    while (result.next)
    {
        //根据列名取出分类信息存到对象中以对象返回
        ProjectModel *model = [[ProjectModel alloc]init];
        model.tableNameStr = [result stringForColumn:@"summary_name"];
        model.tableId = [result intForColumn:@"summary_id"];
        [array addObject:model];
    }
    [db close];
    return array;
}
//查询创作页面数组内容
+(NSString *)selectCreationPageString:(NSString *)templateId
{
    FMDatabase *db =[DBHelper openDatabase];
    //执行查询语句
    NSString *sql = [NSString stringWithFormat:@"select * from 'PPT_PRODUCT_TEMPLATE' where template_id =%@",templateId];
    FMResultSet *result = [db executeQuery:sql];
    //当下边还有分类的时候执行
    while (result.next)
    {
        
        NSString *str = [result stringForColumn:@"template_html"];
        [db close];
        return str;
    }
    [db close];
    return nil;
}

//插入TABLE_TEMPLATE的html代码
+(BOOL)insertHtmlToDetailsSummaryIdWith:(NSString *)summaryid TemplateId:(NSString *)templateid HtmlCode:(NSString *)htmlcode{
    
    FMDatabase *db =[DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"insert into 'PPT_PRODUCT_DETAILS'('summary_id','template_id','html_code') values (?,?,?)",summaryid,templateid,htmlcode];
    [db close];
    return result;
}
// 根据summary id 查询 PPT_PRODUCT_DETAILS 表中对应的结果集
+(NSMutableArray *)selectDetailsDataBySummaryId:(NSString *)summaryId{
    FMDatabase *db = [DBHelper openDatabase];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM PPT_PRODUCT_DETAILS WHERE SUMMARY_ID = %@", summaryId];
    NSMutableArray *detailsArray = [[NSMutableArray alloc]init];
    FMResultSet *result = [db executeQuery:sql];
    while (result.next) {
        DetailsModel *detailsModel = [[DetailsModel alloc]init];
        detailsModel.detailsIdStr = [result stringForColumn:@"details_id"];
        detailsModel.summaryIdStr = [result stringForColumn:@"summary_id"];
        detailsModel.templateIdStr = [result stringForColumn:@"template_id"];
        detailsModel.htmlCodeStr = [result stringForColumn:@"html_code"];
        [detailsArray addObject:detailsModel];
    }
    [db close];
    return  detailsArray;
}
// 点预览时生成html代码，更新到对应的PPT_PRODUCT_SUMMARY表中的记录
+(BOOL)updateSummaryContentById:(NSString *)htmlCode :(NSString *)summaryId{
    FMDatabase *db =[DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"UPDATE PPT_PRODUCT_SUMMARY SET content_html=? WHERE summary_id =?",htmlCode, summaryId];
    [db close];
    return result;
    
}
//根据传过来的details表的detailsid修改html_code
+(BOOL)updateDetailsIdWith:(NSString *)detailsid htmlCode:(NSString *)htmlcode
{
    FMDatabase *db =[DBHelper openDatabase];
    BOOL result = [db executeUpdate:@"UPDATE 'PPT_PRODUCT_DETAIlS' set html_code=? WHERE details_id =?",htmlcode,detailsid];
    [db close];
    return result;
}

// 根据summary id 查询 summary表中html code
+(NSString *)queryHtmlCodeFromSummary:(NSString *)summaryId{
    FMDatabase *db =[DBHelper openDatabase];
    FMResultSet *result1 = [db executeQuery:@"SELECT  content_html FROM PPT_PRODUCT_SUMMARY WHERE SUMMARY_ID =?",summaryId];
    
    while (result1.next)
    {
        NSString *str = [result1 stringForColumnIndex:0];
        [db close];
        return str;
    }
    [db close];
    return nil;
    
}
@end
