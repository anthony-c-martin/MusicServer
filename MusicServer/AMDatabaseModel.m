//
//  AMDatabaseModel.m
//  MusicServer
//
//  Created by Anthony Martin on 30/10/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import "AMDatabaseModel.h"
#import "./FMDB/FMDatabase.h"

@implementation AMDatabaseModel

-(id) init
{
    self = [super init];
    if (self)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSString *applicationSupportDirectory = [paths objectAtIndex:0];
        [self setDatabaseLocation:[NSString stringWithFormat:@"%@/AMMusicServer/music.sqlite", applicationSupportDirectory]];
        [self setDatabaseFolder:[NSString stringWithFormat:@"%@/AMMusicServer", applicationSupportDirectory]];
        [self setTracksModel:[[AMTableModelTracks alloc] initWithConnection:nil]];
        [self setArtistsModel:[[AMTableModelArtists alloc] initWithConnection:nil]];
        [self setAlbumsModel:[[AMTableModelAlbums alloc] initWithConnection:nil]];
    }
    return self;
}

-(id) initCreate
{
    self = [self init];
    if (self)
    {
        [self setDatabase:[self create]];
    }
    return self;
}

-(id) initOpen
{
    self = [self init];
    if (self)
    {
        [self setDatabase:[self open]];
    }
    return self;
}

-(FMDatabase *) open
{
    FMDatabase *database = [FMDatabase databaseWithPath:[self DatabaseLocation]];
    
    if (![database open])
    {
        return nil;
    }
    
    [[self TracksModel] setDatabase:database];
    [[self ArtistsModel] setDatabase:database];
    [[self AlbumsModel] setDatabase:database];
    return database;
}

-(FMDatabase *) create
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:[self DatabaseFolder]])
    {
        [fileManager createDirectoryAtPath:[self DatabaseFolder]
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    if ([fileManager fileExistsAtPath:[self DatabaseLocation]])
    {
        [fileManager removeItemAtPath:[self DatabaseLocation] error:nil];
    }
    
    FMDatabase *database = [self open];
    
    if (!database)
    {
        return nil;
    }
    
    if (![[self TracksModel] create])
    {
        return nil;
    }
    
    if (![[self ArtistsModel] create])
    {
        return nil;
    }

    if (![[self AlbumsModel] create])
    {
        return nil;
    }
    
    return database;
}

@end

@implementation AMTableModel

-(id) initWithConnection:(FMDatabase *)database
{
    self = [super init];
    if (self)
    {
        [self setDatabase:nil];
        if ([database open])
        {
            [self setDatabase:database];
        }
        [self setTableName:nil];
        [self setFields:nil];
        [self setCreateFields:nil];
    }
    return self;
}

-(BOOL) create
{
    [[self Database] executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [self TableName]]];
    if ([[self Database] hadError])
    {
        return NO;
    }
    
    [[self Database] executeUpdate:[NSString stringWithFormat:@"CREATE TABLE %@ (%@)", [self TableName], [self CreateFields]]];
    if([[self Database] hadError])
    {
        return NO;
    }
    
    return YES;
}

-(BOOL) fetchQuery:(NSString *)Query
     withArguments:(NSArray *)Arguments
           toArray:(NSArray **)Array
          rowCount:(NSNumber **)Count
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    FMResultSet *resultSet = [[self Database] executeQuery:Query withArgumentsInArray:Arguments];
    if ([[self Database] hadError])
    {
        return NO;
    }
    
    int count = 0;
    while ([resultSet next])
    {
        [resultArray addObject:[resultSet resultDictionary]];
        count++;
    }
    [resultSet close];
    
    *Count = [NSNumber numberWithInt:count];
    *Array = [[NSArray alloc] initWithArray:resultArray];
    return YES;
}

-(BOOL) fetchQuery:(NSString *)Query
     withArguments:(NSArray *)Arguments
             start:(NSNumber *)Start
             limit:(NSNumber *)Limit
           toArray:(NSArray **)Array
          rowCount:(NSNumber **)Count
{
    NSString *limitQuery = [NSString stringWithFormat:@"%@ LIMIT %@, %@", Query, Start, Limit];
    
    return [self fetchQuery:limitQuery
              withArguments:Arguments
                    toArray:Array
                   rowCount:Count];
}

-(BOOL) fetchQuerySingleRow:(NSString *)Query
              withArguments:(NSArray *)Arguments
                    toDictionary:(NSDictionary **)Dictionary
{
    NSArray *resultArray = nil;
    NSNumber *rowCount = nil;
    
    BOOL result = [self fetchQuery:Query
                     withArguments:Arguments
                             start:[NSNumber numberWithInt:0]
                             limit:[NSNumber numberWithInt:1]
                           toArray:&resultArray
                          rowCount:&rowCount];
    if (result && [rowCount isEqualToNumber:[NSNumber numberWithInt:1]])
    {
        *Dictionary = [resultArray objectAtIndex:0];
        return YES;
    }
    return NO;
}

-(BOOL) getRowByID:(NSNumber *)ID
      toDictionary:(NSDictionary **)Dictionary
{
    return [self fetchQuerySingleRow:[NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE ID = ?", [self Fields], [self TableName]]
                       withArguments:[NSArray arrayWithObjects:ID, nil]
                        toDictionary:Dictionary];
}

-(BOOL) getRows:(NSNumber *)Start
          limit:(NSNumber *)Limit
        toArray:(NSArray **)Array
       rowCount:(NSNumber **)Count
{
    return [self fetchQuery:[NSString stringWithFormat:@"SELECT %@ FROM %@", [self Fields], [self TableName]]
              withArguments:[[NSArray alloc] init]
                      start:Start
                      limit:Limit
                    toArray:Array
                   rowCount:Count];
}

@end

@implementation AMTableModelTracks

-(id) initWithConnection:(FMDatabase *)database
{
    self = [super initWithConnection:database];
    if (self)
    {
        [self setTableName:@"tracks"];
        [self setFields:@"ID, Name, Location, ArtistID, AlbumID"];
        [self setCreateFields:@"ID integer primary key autoincrement, Name text, Location text, ArtistID integer, AlbumID integer"];
    }
    return self;
}

-(BOOL) insertTrack:(NSString *)Name
           Location:(NSString *)Location
           ArtistID:(NSNumber *)ArtistID
            AlbumID:(NSNumber *)AlbumID
              rowId:(NSNumber **)RowID
{
    [[self Database] executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (Name, Location, ArtistID, AlbumID) VALUES (?, ?, ?, ?)", [self TableName]]
             withArgumentsInArray:[NSArray arrayWithObjects: Name, Location, ArtistID, AlbumID, nil]];
    
    if (![[self Database] hadError])
    {
        *RowID = [NSNumber numberWithLongLong:[[self Database] lastInsertRowId]];
        return YES;
    }
    
    return NO;
}

-(BOOL) getTracksByArtist:(NSNumber *)ArtistID
                    start:(NSNumber *)Start
                    limit:(NSNumber *)Limit
                  toArray:(NSArray **)Array
                 rowCount:(NSNumber **)RowCount
{
    return [self fetchQuery:[NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE ArtistID = ?", [self Fields], [self TableName]]
              withArguments:[NSArray arrayWithObjects:ArtistID, nil]
                      start:Start
                      limit:Limit
                    toArray:Array
                   rowCount:RowCount];
}

-(BOOL) getTracksByAlbum:(NSNumber *)AlbumID
                   start:(NSNumber *)Start
                   limit:(NSNumber *)Limit
                 toArray:(NSArray **)Array
                rowCount:(NSNumber **)RowCount
{
    return [self fetchQuery:[NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE AlbumID = ?", [self Fields], [self TableName]]
              withArguments:[NSArray arrayWithObjects:AlbumID, nil]
                      start:Start
                      limit:Limit
                    toArray:Array
                   rowCount:RowCount];
}

-(BOOL) searchTracks:(NSString *)searchString
               start:(NSNumber *)Start
               limit:(NSNumber *)Limit
             toArray:(NSArray **)Array
            rowCount:(NSNumber **)RowCount
{
    return [self fetchQuery:[NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE Name LIKE ?", [self Fields], [self TableName]]
              withArguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%%%@%%", searchString], nil]
                      start:Start
                      limit:Limit
                    toArray:Array
                   rowCount:RowCount];
}

@end

@implementation AMTableModelArtists

-(id) initWithConnection:(FMDatabase *)database
{
    self = [super initWithConnection:database];
    if (self)
    {
        [self setTableName:@"artists"];
        [self setFields:@"ID, Name"];
        [self setCreateFields:@"ID integer primary key autoincrement, Name text"];
    }
    return self;
}

-(BOOL) insertArtist:(NSString *)Name
               rowId:(NSNumber **)RowID
{
    [[self Database] executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (Name) VALUES (?)", [self TableName]]
             withArgumentsInArray:[NSArray arrayWithObjects: Name, nil]];
    
    if (![[self Database] hadError])
    {
        *RowID = [NSNumber numberWithLongLong:[[self Database] lastInsertRowId]];
        return YES;
    }
    
    return NO;
}

-(BOOL) searchArtists:(NSString *)searchString
                start:(NSNumber *)Start
                limit:(NSNumber *)Limit
              toArray:(NSArray **)Array
             rowCount:(NSNumber **)RowCount
{
    return [self fetchQuery:[NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE Name LIKE ?", [self Fields], [self TableName]]
              withArguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%%%@%%", searchString], nil]
                      start:Start
                      limit:Limit
                    toArray:Array
                   rowCount:RowCount];
}

@end

@implementation AMTableModelAlbums

-(id) initWithConnection:(FMDatabase *)database
{
    self = [super initWithConnection:database];
    if (self)
    {
        [self setTableName:@"albums"];
        [self setFields:@"ID, Name, ArtistID"];
        [self setCreateFields:@"ID integer primary key autoincrement, Name text, ArtistID integer"];
    }
    return self;
}

-(BOOL) insertAlbum:(NSString *)Name
           ArtistID:(NSNumber *)ArtistID
              rowId:(NSNumber **)RowID
{
    [[self Database] executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (Name, ArtistID) VALUES (?, ?)", [self TableName]]
             withArgumentsInArray:[NSArray arrayWithObjects:Name, ArtistID, nil]];
    
    if (![[self Database] hadError])
    {
        *RowID = [NSNumber numberWithLongLong:[[self Database] lastInsertRowId]];
        return YES;
    }
    
    return NO;
}

-(BOOL) getAlbumsByArtist:(NSNumber *)ArtistID
                    start:(NSNumber *)Start
                    limit:(NSNumber *)Limit
                  toArray:(NSArray **)Array
                 rowCount:(NSNumber **)RowCount
{
    return [self fetchQuery:[NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE ArtistID = ?", [self Fields], [self TableName]]
              withArguments:[NSArray arrayWithObjects:ArtistID, nil]
                      start:Start
                      limit:Limit
                    toArray:Array
                   rowCount:RowCount];
}

-(BOOL) searchAlbums:(NSString *)searchString
               start:(NSNumber *)Start
               limit:(NSNumber *)Limit
             toArray:(NSArray **)Array
            rowCount:(NSNumber **)RowCount
{
    return [self fetchQuery:[NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE Name LIKE ?", [self Fields], [self TableName]]
              withArguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%%%@%%", searchString], nil]
                      start:Start
                      limit:Limit
                    toArray:Array
                   rowCount:RowCount];
}

@end