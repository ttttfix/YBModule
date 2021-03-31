//
//  BXIMCommonDatabase.m
//  BXMessageKit
//
//  Created by yangbin on 2021/3/30.
//

#import "BXIMCommonDB.h"
#import <sqlite3.h>


@implementation BXIMCommonDB {
    sqlite3 *_db;
}


+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static BXIMCommonDB *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}
 
/**
 * 打开数据库
 * @param db
 * @return
 */
- (BOOL)openDB:(NSString *)db {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *DBPath = [documentPath stringByAppendingPathComponent:db];
    NSLog(@"数据库路径%@", DBPath);
    if (sqlite3_open(DBPath.UTF8String, &_db) != SQLITE_OK) {
        return NO;
    } else {
        return YES;  //打开成功创建表
    }
}
 
/**
 * 执行SQL
 * @param sql
 * SQL语句
 * @return
 *  bool
 */
- (BOOL)exec:(NSString *)sql {
    return sqlite3_exec(_db, sql.UTF8String, nil, nil, nil) == SQLITE_OK;;
}
 
 
/**
 * 查询语句
 * @param sql
 *  SQL语句
 * @return
 *  结果集
 */
- (NSArray *)query:(NSString *)sql {
    sqlite3_stmt *pstmt;    //结果集游标句柄
    if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &pstmt, NULL) != SQLITE_OK) {
        NSLog(@"执行SQL失败%@", sql);
        return NULL;
    }//查询成功
    NSMutableArray *dicArr = [[NSMutableArray alloc] init];
    while (sqlite3_step(pstmt) == SQLITE_ROW) {  //遍历游标
        [dicArr addObject:[self stmt2Dict:pstmt]];
    }
    return dicArr;
}
 
 
/**
 * 查询第一个结果
 * @param sql
 * @return
 */
- (NSDictionary *)queryFirst:(NSString *)sql {
    sqlite3_stmt *pstmt;    //结果集游标句柄
    if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &pstmt, NULL) != SQLITE_OK) {
        NSLog(@"执行SQL失败%@", sql);
        return NULL;
    }//查询成功
    while (sqlite3_step(pstmt) == SQLITE_ROW) {  //遍历游标
        return [self stmt2Dict:pstmt];
    }
    return nil;
}
 
/**
 * 将 sqlite3_stmt 转成 Dictionary
 * @param pstmt
 *  sqlite3_stmt 指针
 * @return
 *  Dictionary
 */
- (NSDictionary *)stmt2Dict:(sqlite3_stmt *)pstmt {
    int columnCount = sqlite3_column_count(pstmt);  //获取列数
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init]; //初始化一个Dict存放单行记录
    for (int i = 0; i < columnCount; i++) {
        const char *key = sqlite3_column_name(pstmt, i);            //取列名
        int type = sqlite3_column_type(pstmt, i);
        switch (type) {
            case SQLITE_INTEGER: {
                int value = sqlite3_column_int(pstmt, i);                       //整型
                dict[[NSString stringWithUTF8String:key]] = @(value);
                break;
            }
            case SQLITE_FLOAT: {
                double value = sqlite3_column_double(pstmt, i);                    //浮点型
                dict[[NSString stringWithUTF8String:key]] = @(value);
                break;
            }
            case SQLITE_TEXT:
            default: {
                const char *value = (const char *)sqlite3_column_text(pstmt, i);  //字符型
                dict[[NSString stringWithUTF8String:key]] = [NSString stringWithUTF8String:value];
                break;
            }
        }
    }
    return dict;
}
 
/**
 * 执行统计类型语句，例如 COUNT(1) ，SUM(col)，返回第一个记录
 * @param sql
 *  SQL语句
 * @return
 *  count
 */
- (double)count:(NSString *)sql {
    sqlite3_stmt *pstmt;    //结果集游标句柄
    if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &pstmt, NULL) != SQLITE_OK) {
        NSLog(@"执行SQL失败%@", sql);
        return 0.f;
    }
    while (sqlite3_step(pstmt) == SQLITE_ROW) {
        return sqlite3_column_double(pstmt, 0);
    }
    return 0.f;
}
 
/**
 * 关闭链接
 * @return
 */
- (int)close {
    return sqlite3_close(_db);
}
 


@end
