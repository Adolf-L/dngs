/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNFmdbUnit.h
 *
 * Description  : DNFmdbUnit
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/2/7, Create the file
 *****************************************************************************************
 **/

#import <Foundation/Foundation.h>

#define kDNFmdbUnit [DNFmdbUnit sharedInstance]

@interface DNFmdbUnit : NSObject

/**
 单例方法
 */
+ (instancetype)sharedInstance;

/**
 向数据库中插入表数据(如果数据表不存在，就根据model创建表)

 @param model model数据(可以是一个model，或者是一个model数组)
 @param key   指定的Primary Key
 @return 插入数据是否成功
 */
- (BOOL)dnInsertModel:(id)model withKey:(NSString*)key;

/**
 查询记录

 @param modelClass model对应的类名
 @param key    查询数据的key
 @param value  key对应的value
 @return 查询结果
 */
- (id)dnSearchModel:(Class)modelClass withKey:(NSString*)key andValue:(NSString*)value;

/**
 查找指定表中模型数组（所有的

 @param modelClass model类型
 */
- (NSArray *)dnSearchModelArr:(Class)modelClass;

- (BOOL)dnUpdateModel:(Class)modelClass setKey:(NSString*)key withValue:(id)value andRequest:(NSString*)request;
- (BOOL)dnDeleteModel:(Class)modelClass  withKeyName:(NSString*)keyName andKeyValue:(NSString*)keyValue;

@end
