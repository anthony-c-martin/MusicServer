//
//  AMDatabaseModel.h
//  MusicServer
//
//  Created by Anthony Martin on 30/10/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabase;

@interface AMTableModel : NSObject

@property (nonatomic, retain) FMDatabase *Database;
@property (nonatomic, retain) NSString *TableName;
@property (nonatomic, retain) NSString *Fields;
@property (nonatomic, retain) NSString *CreateFields;

-(id) initWithConnection:(FMDatabase *)database;

-(BOOL) create;

-(BOOL) getRowByID:(NSNumber *)ID
      toDictionary:(NSDictionary **)Dictionary;

-(BOOL) getRows:(NSNumber *)Start
          limit:(NSNumber *)Limit
        toArray:(NSArray **)Array
       rowCount:(NSNumber **)Count;

@end

@interface AMTableModelTracks : AMTableModel

-(BOOL) insertTrack:(NSString *)Name
           Location:(NSString *)Location
           ArtistID:(NSNumber *)ArtistID
            AlbumID:(NSNumber *)AlbumID
              rowId:(NSNumber **)RowID;

-(BOOL) getTracksByArtist:(NSNumber *)ArtistID
                    start:(NSNumber *)Start
                    limit:(NSNumber *)Limit
                  toArray:(NSArray **)Array
                 rowCount:(NSNumber **)RowCount;

-(BOOL) getTracksByAlbum:(NSNumber *)AlbumID
                   start:(NSNumber *)Start
                   limit:(NSNumber *)Limit
                 toArray:(NSArray **)Array
                rowCount:(NSNumber **)RowCount;

-(BOOL) searchTracks:(NSString *)searchString
               start:(NSNumber *)Start
               limit:(NSNumber *)Limit
             toArray:(NSArray **)Array
            rowCount:(NSNumber **)RowCount;

@end

@interface AMTableModelArtists : AMTableModel

-(BOOL) insertArtist:(NSString *)Name
               rowId:(NSNumber **)RowID;

-(BOOL) searchArtists:(NSString *)searchString
                start:(NSNumber *)Start
                limit:(NSNumber *)Limit
              toArray:(NSArray **)Array
             rowCount:(NSNumber **)RowCount;

@end

@interface AMTableModelAlbums : AMTableModel

-(BOOL) insertAlbum:(NSString *)Name
           ArtistID:(NSNumber *)ArtistID
              rowId:(NSNumber **)RowID;

-(BOOL) getAlbumsByArtist:(NSNumber *)ArtistID
                    start:(NSNumber *)Start
                    limit:(NSNumber *)Limit
                  toArray:(NSArray **)Array
                 rowCount:(NSNumber **)RowCount;

-(BOOL) searchAlbums:(NSString *)searchString
               start:(NSNumber *)Start
               limit:(NSNumber *)Limit
             toArray:(NSArray **)Array
            rowCount:(NSNumber **)RowCount;

@end

@interface AMDatabaseModel : NSObject

@property (nonatomic, retain) FMDatabase *Database;
@property (nonatomic, retain) NSString *DatabaseFolder;
@property (nonatomic, retain) NSString *DatabaseLocation;
@property (nonatomic, retain) AMTableModelTracks *TracksModel;
@property (nonatomic, retain) AMTableModelArtists *ArtistsModel;
@property (nonatomic, retain) AMTableModelAlbums *AlbumsModel;

-(id) initCreate;
-(id) initOpen;

@end