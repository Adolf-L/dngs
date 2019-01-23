/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNFmdbUnit.m
 *
 * Description  : DNFmdbUnit
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/2/7, Create the file
 *****************************************************************************************
 **/

#import "DNFmdbUnit.h"
#import "FMDB.h"
#import <objc/runtime.h>
#import <sqlite3.h>

@interface DNFmdbUnit()

@property (nonatomic, strong) FMDatabaseQueue* fmdbQueue;

@end


@implementation DNFmdbUnit

+ (instancetype)sharedInstance {
    static DNFmdbUnit* scFmdb = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scFmdb = [[DNFmdbUnit alloc] init];
        
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        NSString *sqlFilePath = [path stringByAppendingPathComponent:@"DNRoute.sqlite"];
        scFmdb.fmdbQueue = [FMDatabaseQueue databaseQueueWithPath:sqlFilePath flags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FILEPROTECTION_NONE];
    });
    
    return scFmdb;
}

#pragma mark - Publish方法
- (BOOL)dnInsertModel:(id)model withKey:(NSString*)key {
    if ([model isKindOfClass:[NSArray class]] || [model isKindOfClass:[NSMutableArray class]]) {
        BOOL insertRet = NO;
        NSArray *modelArr = (NSArray *)model;
        for (id model in modelArr) {
            insertRet = [self inertModel:model withKey:key];
        }
        return insertRet;
    } else{
        return [self inertModel:model withKey:key];
    }
}
- (id)dnSearchModel:(Class)modelClass withKey:(NSString*)key andValue:(NSString*)value
{
    if (![self isTableExist:modelClass]) {
        return nil;
    }
    __block NSMutableArray* modelArr = nil;
    [self.fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString* searchSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@';", modelClass, key, value];
        FMResultSet* rs = [db executeQuery:searchSQL];
        while ([rs next]) {
            if (!modelArr) {
                modelArr = [NSMutableArray array];
            }
            unsigned int outCount;
            id modelObj = [[modelClass class] new];
            Ivar * ivars = class_copyIvarList(modelClass, &outCount);
            for (int i = 0; i < outCount; i ++) {
                Ivar ivar = ivars[i];
                const char *name = ivar_getName(ivar);
                const char *type = ivar_getTypeEncoding(ivar);
                NSString *key = [[NSString stringWithUTF8String:name] stringByReplacingOccurrencesOfString:@"_" withString:@""];
                id value = [rs objectForColumn:key];
                if ([[NSString stringWithUTF8String:type] isEqualToString:@"@\"NSArray\""]) {
                    value = [value componentsSeparatedByString:@"^"];
                }
                if ([[NSString stringWithUTF8String:type] isEqualToString:@"@\"NSDictionary\""]) {
                    value = [NSDictionary dictionaryWithJsonString:value];
                }
                [modelObj setValue:value forKey:key];
            }
            [modelArr addObject:modelObj];
        }
        [rs close];
    }];
    return modelArr;
}
- (NSArray *)dnSearchModelArr:(Class)modelClass {
    if (![self isTableExist:modelClass]) {
        return nil;
    }
    __block NSMutableArray* modelArr = nil;
    [self.fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString* searchSQL = [NSString stringWithFormat:@"SELECT * FROM %@", modelClass];
        FMResultSet* rs = [db executeQuery:searchSQL];
        while ([rs next]) {
            if (!modelArr) {
                modelArr = [NSMutableArray array];
            }
            id modelObj = [[modelClass class] new];
            unsigned int outCount;
            Ivar * ivars = class_copyIvarList(modelClass, &outCount);
            for (int i = 0; i < outCount; i ++) {
                Ivar ivar = ivars[i];
                const char *name = ivar_getName(ivar);
                const char *type = ivar_getTypeEncoding(ivar);
                NSString * key = [[NSString stringWithUTF8String:name] stringByReplacingOccurrencesOfString:@"_" withString:@""];
                id value = [rs objectForColumn:key];
                if ([[NSString stringWithUTF8String:type] isEqualToString:@"@\"NSArray\""]) {
                    value = [value componentsSeparatedByString:@"^"];
                }
                if ([[NSString stringWithUTF8String:type] isEqualToString:@"@\"NSDictionary\""]) {
                    value = [NSDictionary dictionaryWithJsonString:value];
                }
                [modelObj setValue:value forKey:key];
            }
            [modelArr addObject:modelObj];
        }
        [rs close];
    }];
    return modelArr;
}

- (BOOL)dnUpdateModel:(Class)modelClass setKey:(NSString*)key withValue:(id)value andRequest:(NSString*)request {
    __block BOOL result = NO;
    NSString* updateSQL = [NSString stringWithFormat:@"UPDATE %@ SET %@=%@ WHERE %@", modelClass, key, value, request];
    [self.fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:updateSQL];
    }];
    return result;
}
- (BOOL)dnDeleteModel:(Class)modelClass  withKeyName:(NSString*)keyName andKeyValue:(NSString*)keyValue {
    NSString* deleteSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@='%@'", modelClass, keyName, keyValue];
    if (!keyName && !keyValue) {
        deleteSQL = [NSString stringWithFormat:@"DELETE FROM %@", modelClass];
    }
    __block BOOL result = NO;
    [self.fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db executeUpdate:deleteSQL];
    }];
    return result;
}

#pragma mark - SQL语句
/**
 根据Model生成创建表的SQL语句

 @param modelClass Model类
 @param key        Primary Key
 @return 创建表的SQL语句
 */
- (NSString*)obtainCreateTableSQL:(Class)modelClass withKey:(NSString*)key {
    NSMutableString* retSQL = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (", modelClass];
    
    //获取变量名作为创建表的各个字段
    unsigned int count = 0;
    Ivar* ivars = class_copyIvarList(modelClass, &count);
    for (int i=0 ; i<count ; i++) {
        Ivar ivar = ivars[i];
        NSString* columnKey = [[NSString stringWithUTF8String:ivar_getName(ivar)] stringByReplacingOccurrencesOfString:@"_" withString:@""];
        if ([columnKey caseInsensitiveCompare:@"Id"] == NSOrderedSame) {
            if (0 == i) {
                [retSQL appendFormat:@"Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE"];
            } else {
                [retSQL appendFormat:@", Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE"];
            }
        } else if ([columnKey compare:key options:NSCaseInsensitiveSearch] == 0) {
            if (0 == i) {
                [retSQL appendFormat:@"%@ PRIMARY KEY NOT NULL UNIQUE", columnKey];
            } else {
                [retSQL appendFormat:@", %@ PRIMARY KEY NOT NULL UNIQUE", columnKey];
            }
        } else {
            if (0 == i) {
                [retSQL appendFormat:@"%@", columnKey];
            } else {
                [retSQL appendFormat:@", %@", columnKey];
            }
        }
    }
    [retSQL appendString:@")"];
    
    return retSQL;
}
/**
 获取插入记录的SQL语句
 
 @param model Model数据体
 @return      插入记录的SQL语句
 */
- (NSString*)obtainInsertTableSQL:(id)model {
    NSMutableString *sqlValueM = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO %@ (",[model class]];
    unsigned int outCount;
    Ivar * ivars = class_copyIvarList([model class], &outCount);
    for (int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        NSString * key = [[NSString stringWithUTF8String:ivar_getName(ivar)] stringByReplacingOccurrencesOfString:@"_" withString:@""];
        
        if (i == 0) {
            [sqlValueM appendString:key];
        } else{
            [sqlValueM appendFormat:@", %@",key];
        }
    }
    [sqlValueM appendString:@") VALUES ("];
    
    for (int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        NSString * key = [[NSString stringWithUTF8String:ivar_getName(ivar)] stringByReplacingOccurrencesOfString:@"_" withString:@""];
        
        id value = [model valueForKey:key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            value = [value convertToJSONString];
        }
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *array = (NSArray *)value;
            if (array.count > 0 && [array[0] isKindOfClass:[NSDictionary class]]) {
                NSMutableArray *tmpArray = [NSMutableArray array];
                for (NSDictionary *dic in array) {
                    NSString *string = [dic convertToJSONString];
                    [tmpArray addObject:string];
                }
                value = [tmpArray componentsJoinedByString:@"^"];
            } else {
                value = [array componentsJoinedByString:@"^"];
            }
        }
        if ([value isKindOfClass:[NSString class]]) {
            value = [NSString stringWithFormat:@"'%@'", value];
        }

        //sql语句中字符串需要单引号或者双引号括起来
        if (i == 0) {
            [sqlValueM appendFormat:@"%@", value];
        } else {
            [sqlValueM appendFormat:@", %@", value];
        }
    }
    [sqlValueM appendString:@");"];
    return sqlValueM;
}
/**
 获取更新数据表的SQL语句
 
 @param model    model数据
 @return         更新数据表的SQL语句
 */
- (NSString*)obtainUpdateTableSQL:(id)model withKeyName:(NSString*)keyName andKeyValue:(NSString*)keyValue {
    NSMutableString* sql = [NSMutableString stringWithFormat:@"UPDATE %@ SET ",[model class]];
    unsigned int outCount;
    Ivar * ivars = class_copyIvarList([model class], &outCount);
    for (int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        //        NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        NSString * key = [[NSString stringWithUTF8String:ivar_getName(ivar)] stringByReplacingOccurrencesOfString:@"_" withString:@""];
        id value = [model valueForKey:key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            value = [value convertToJSONString];
        }
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *array = (NSArray *)value;
            if (array.count > 0 && [array[0] isKindOfClass:[NSDictionary class]]) {
                NSMutableArray *tmpArray = [NSMutableArray array];
                for (NSDictionary *dic in array) {
                    NSString *string = [dic convertToJSONString];
                    [tmpArray addObject:string];
                }
                value = [tmpArray componentsJoinedByString:@"^"];
            } else {
                value = [array componentsJoinedByString:@"^"];
            }
        }
        if ([value isKindOfClass:[NSString class]]) {
            value = [NSString stringWithFormat:@"'%@'", value];
        }
        if (i == 0) {
            [sql appendFormat:@"%@ = %@",key, value];
        } else{
            [sql appendFormat:@",%@ = %@",key, value];
        }
    }
    [sql appendFormat:@" WHERE %@ = '%@';", keyName, keyValue];
    return sql;
}


#pragma mark - Privates
- (BOOL)createTable:(Class)modelClass withKey:(NSString*)key {
    if (self.fmdbQueue) {
        if ([self isTableExist:modelClass]) {
            return YES;
        } else {
            __block BOOL result = NO;
            NSString* createTableSQL = [self obtainCreateTableSQL:modelClass withKey:key];
            [self.fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                result = [db executeUpdate:createTableSQL];
            }];
            return result;
        }
    } else {
        return NO;
    }
}
/**
 将model存入数据库
 
 @param model model数据
 @return      model存入数据库操作是否成功
 */
- (BOOL)inertModel:(id)model withKey:(NSString*)key
{
    if ([model isKindOfClass:[UIResponder class]]) {
        NSLog(@"~# Fmdb, params error!");
        return NO;
    }
    //如果表不存在，则先创建表
    if (![self isTableExist:[model class]]) {
        BOOL ret = [self createTable:[model class] withKey:key];
        if (!ret) {
            return NO;
        }
    }
    //插入或者是修改指定的model数据
    __block BOOL executeRet = NO;
    if ([self isModelExist:[model class] withKeyName:key andKeyValue:[model valueForKey:key]]) {
        NSString* updateSQL = [self obtainUpdateTableSQL:model withKeyName:key andKeyValue:[model valueForKey:key]];
        [self.fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            executeRet = [db executeUpdate:updateSQL];
        }];
    } else {
        NSString* insertSQL = [self obtainInsertTableSQL:model];
        [self.fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            executeRet = [db executeUpdate:insertSQL];
        }];
    }
    return executeRet;
}
/**
 查看指定的记录是否存在
 
 @param modelClass model的类名
 @return           YES：记录已经存在，NO：记录不存在
 */
- (BOOL)isModelExist:(Class)modelClass withKeyName:(NSString*)keyName andKeyValue:(NSString*)keyValue {
    // 创建对象
    __block BOOL result = NO;
    [self.fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString* selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@';", modelClass, keyName, keyValue];
        FMResultSet* rs = [db executeQuery:selectSQL];
        if ([rs next]) {
            result = YES;
        }
        [rs close];
    }];
    return result;
}
/**
 指定类名对应的数据表是否存在

 @param modelClass 类名是否存在
 */
- (BOOL)isTableExist:(Class)modelClass {
    __block BOOL result = NO;
    [self.fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        result = [db tableExists:NSStringFromClass(modelClass)];
    }];

    return result;
}

@end
