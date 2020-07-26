//
//  DBConnection.h
//  WhereAmI
//
//  Created by Forza on 25/07/2020.
//  Copyright © 2020 Forza. All rights reserved.
//

#ifndef DBConnection_h
#define DBConnection_h

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#define DB_NAME @"whereami.db"

@interface DBConnection : NSObject
{
    @private sqlite3 *g_database;
}

@property (nonatomic,assign,readwrite) sqlite3 *database;

+ (DBConnection *)sharedConnection;
+ (BOOL)executeQuery:(NSString *)query;
+ (NSMutableArray *)fetchResults:(NSString *)query;
+ (int)rowCountForTable:(NSString *)table where:(NSString *)where;
+ (void)errorMessage:(NSString *)msg;
+ (void)closeConnection;
+ (void)saveData:(NSMutableDictionary *)dict;
+(NSMutableArray *)getData;

- (id)initConnection;
- (void)close;

@end

#endif /* DBConnection_h */
