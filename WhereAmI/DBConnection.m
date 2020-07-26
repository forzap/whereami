//
//  DBConnection.m
//  WhereAmI
//
//  Created by Forza on 25/07/2020.
//  Copyright © 2020 Forza. All rights reserved.
//

#import "DBConnection.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <sys/xattr.h>

@interface DBConnection (Private)
- (void)createEditableCopyOfDatabaseIfNeeded;
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;
- (void)initializeDatabase;
@end

@implementation DBConnection
static DBConnection *conn = NULL;

@synthesize database = g_database;

+(DBConnection *)sharedConnection {
    if (!conn) {
        conn = [[DBConnection alloc] initConnection];
    }
    return conn;
}

#pragma mark - Static methods

+(BOOL)executeQuery:(NSString *)query {
    BOOL isExecuted = NO;

    sqlite3 *database = [DBConnection sharedConnection].database;
    sqlite3_stmt *statement = nil;
    const char *sql = [query UTF8String];
    if (sqlite3_prepare_v2(database, sql, -1, &statement , NULL) != SQLITE_OK) {
        return isExecuted;
    }

    if(SQLITE_DONE == sqlite3_step(statement)) {
        isExecuted = YES;
    }

    sqlite3_finalize(statement);
    statement = nil;

    return isExecuted;
}

+(NSMutableArray *)fetchResults:(NSString *)query {
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:0];
    sqlite3 *database = [DBConnection sharedConnection].database;
    sqlite3_stmt *statement = nil;

    const char *sql = [query UTF8String];
    if (sqlite3_prepare_v2(database, sql, -1, &statement , NULL) != SQLITE_OK) {
        NSString *errorMsg = [NSString stringWithFormat:@"Failed to prepare query statement - '%s'.", sqlite3_errmsg(database)];
        [DBConnection errorMessage:errorMsg];
        
        return results;
    }

    while (sqlite3_step(statement) == SQLITE_ROW) {
        id value = nil;
        NSMutableDictionary *rowDict = [NSMutableDictionary dictionaryWithCapacity:0];
        for (int i = 0 ; i < sqlite3_column_count(statement) ; i++) {
            if (sqlite3_column_type(statement,i) == SQLITE_INTEGER) {
                value = [NSNumber numberWithInt:(int)sqlite3_column_int(statement,i)];
            } else if (sqlite3_column_type(statement,i) == SQLITE_FLOAT) {
                value = [NSNumber numberWithFloat:(float)sqlite3_column_double(statement,i)];
            } else {
                if (sqlite3_column_text(statement,i) != nil) {
                    value = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,i)];
                } else {
                    value = @"";
                }
            }

            if (value) {
                [rowDict setObject:value forKey:[NSString stringWithUTF8String:sqlite3_column_name(statement,i)]];
            }
        }

        [results addObject:rowDict];
    }

    sqlite3_finalize(statement);
    statement = nil;

    return results;
}

+(int)rowCountForTable:(NSString *)table where:(NSString *)where {
    int tableCount = 0;
    NSString *query = @"";

    if (where != nil && ![where isEqualToString:@""]) {
        query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@",
                 table,where];
    } else {
        query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@",
         table];
    }

    sqlite3_stmt *statement = nil;
    sqlite3 *database = [DBConnection sharedConnection].database;
    const char *sql = [query UTF8String];
    if (sqlite3_prepare_v2(database, sql, -1, &statement , NULL) != SQLITE_OK) {
        return 0;
    }

    if (sqlite3_step(statement) == SQLITE_ROW) {
        tableCount = sqlite3_column_int(statement,0);
    }

    sqlite3_finalize(statement);
    return tableCount;
}

+(void)errorMessage:(NSString *)msg {

}

+(void)closeConnection {
    sqlite3 *database = [DBConnection sharedConnection].database;
    if (sqlite3_close(database) != SQLITE_OK) {
        NSString *errorMsg = [NSString stringWithFormat:@"Failed to open database with message - '%s'.", sqlite3_errmsg(database)];
        [DBConnection errorMessage:errorMsg];
    }
}

+(void)saveData:(NSMutableDictionary *)dict {
    const char *sqlInsert = "INSERT INTO main (latitude, longitude, selectedText, selectedIndex, comments, capturedImage) values (?,?,?,?,?,?)";
    sqlite3_stmt *statement;
    sqlite3 *database = [DBConnection sharedConnection].database;
    int sqlResult = sqlite3_prepare_v2(database, sqlInsert, -1, &statement, NULL);
    if (sqlResult == SQLITE_OK) {
        double latitude = [[dict objectForKey:@"latitude"] doubleValue];
        double longitude = [[dict objectForKey:@"longitude"] doubleValue];
        NSString *selectedText = dict[@"selectedText"];
        int selectedIndex = [[dict objectForKey:@"selectedIndex"] intValue];
        NSString *comments = dict[@"comments"];
        NSData *imgData = (NSData *)dict[@"imgData"];
        
        sqlite3_bind_double(statement, 1, latitude);
        sqlite3_bind_double(statement, 2, longitude);
        sqlite3_bind_text(statement, 3, [selectedText UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 4, selectedIndex);
        sqlite3_bind_text(statement, 5, [comments UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_blob(statement, 6, [imgData bytes], (int)[imgData length], SQLITE_TRANSIENT);
        while (YES) {
            NSInteger SQLResult = sqlite3_step(statement);
            if(SQLResult == SQLITE_DONE){
                break;
            }else if(SQLResult !=SQLITE_BUSY){
                break;
            }
        }
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
    }
    else{
        NSLog(@"Problem accessing database");
    }

}

+(NSMutableArray *) getData {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    const char *sqlSelect = "SELECT latitude, longitude, selectedText, selectedIndex, comments, capturedImage FROM main";
    sqlite3_stmt *statement;
    sqlite3 *database = [DBConnection sharedConnection].database;
    int sqlResult = sqlite3_prepare_v2(database, sqlSelect, -1, &statement, NULL);
    if (sqlResult == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            double latitude = sqlite3_column_double(statement, 0);
            double longitude = sqlite3_column_double(statement, 1);
            char *selectedText = (char *)sqlite3_column_text(statement, 2);
            int selectedIndex = sqlite3_column_int(statement, 3);
            char *comments = (char *)sqlite3_column_text(statement, 4);
            void *blobData = (void *)sqlite3_column_blob(statement, 5);
            int blobSize = sqlite3_column_bytes(statement, 5);
            
            [dict setObject:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
            [dict setObject:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
            if (selectedText) {
                [dict setValue:[NSString stringWithUTF8String:selectedText] forKey:@"selectedText"];
            } else {
                [dict setValue:@"" forKey:@"selectedText"];
            }
            [dict setObject:[NSNumber numberWithInt:selectedIndex] forKey:@"selectedIndex"];
            if (comments) {
                [dict setValue:[NSString stringWithUTF8String:comments] forKey:@"comments"];
            } else {
                [dict setValue:@"" forKey:@"comments"];
            }
            NSData *imgData=[[NSData alloc] initWithBytes:blobData length:blobSize];
            [dict setObject:imgData forKey:@"imgData"];
            
            [arr addObject:dict];
        }
        sqlite3_finalize(statement);
    }
    else{
        NSLog(@"Problem accessing database");
    }
    
    return arr;
}

-(id)initConnection {
    self = [super init];

    if (self) {
        if (g_database == nil) {
            [self createEditableCopyOfDatabaseIfNeeded];
            [self initializeDatabase];
        }
    }
    
    return self;
}

#pragma mark - Save database

-(void)createEditableCopyOfDatabaseIfNeeded {
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]]];
    
    if (![fileManager fileExistsAtPath:dbDirectory]) {
        [fileManager createDirectoryAtPath:dbDirectory withIntermediateDirectories:NO attributes:nil error:nil];
        [self addSkipBackupAttributeToItemAtURL:[[NSURL alloc] initFileURLWithPath:dbDirectory isDirectory:YES]];
    }

    NSString *writableDBPath = [dbDirectory stringByAppendingPathComponent:DB_NAME];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) {
        return;
    }
    
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_NAME];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSString *errorMsg = [NSString stringWithFormat:@"Failed to create writable database file with message - %@.", [error localizedDescription]];
        [DBConnection errorMessage:errorMsg];
    }
}

-(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    const char* filePath = [[URL path] fileSystemRepresentation];

    const char* attrName = "com.forzapi.WhereAmI";
    u_int8_t attrValue = 1;

    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

#pragma mark - Open and close database

-(void)initializeDatabase {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);

    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]]];

    NSString *path = [dbDirectory stringByAppendingPathComponent:DB_NAME];
    if (sqlite3_open([path UTF8String], &g_database) != SQLITE_OK) {
        sqlite3_close(g_database);
        g_database = nil;
        NSString *errorMsg = [NSString stringWithFormat:@"Failed to open database with message - '%s'.", sqlite3_errmsg(g_database)];
        [DBConnection errorMessage:errorMsg];
    }
}

-(void)close {
    if (g_database) {
        if (sqlite3_close(g_database) != SQLITE_OK) {
            NSString *errorMsg = [NSString stringWithFormat:@"Failed to open database with message - '%s'.", sqlite3_errmsg(g_database)];
            [DBConnection errorMessage:errorMsg];
        }
        g_database = nil;
    }
}


@end
