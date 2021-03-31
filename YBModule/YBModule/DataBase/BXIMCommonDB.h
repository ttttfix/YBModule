//
//  BXIMCommonDatabase.h
//  BXMessageKit
//
//  Created by yangbin on 2021/3/30.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>


NS_ASSUME_NONNULL_BEGIN

@interface BXIMCommonDB : NSObject

/**
 * 获取单例
 * @return
 */
+ (instancetype)sharedInstance;
 
/**
 * 打开指定的数据库
 * @param db
 * @return
 *  BOOL
 */
- (BOOL)openDB:(NSString *)db;
 
/**
 * 执行SQL
 * @param sql
 *  SQL语句
 * @return
 * BOOL
 */
- (BOOL)exec:(NSString *)sql;
 
/**
 * 查询SQL
 * @param sql
 * @return
 */
- (NSArray *)query:(NSString *)sql;
 
/**
 * 查询第一条
 * @param sql
 * @return
 */
- (NSDictionary *)queryFirst:(NSString *)sql;
 
/**
 * 统计
 * @param sql
 * @return
 */
- (double)count:(NSString *)sql;
 
/**
 * 关闭链接
 * @return
 */
- (int)close;


@end

NS_ASSUME_NONNULL_END
