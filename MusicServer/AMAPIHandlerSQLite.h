//
//  AMAPIHandlerSQLite.h
//  MusicServer
//
//  Created by Anthony Martin on 02/11/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "./AMJSONAPIDataObjects.h"

@class AMDatabaseModel;

@interface AMAPIHandlerSQLite : NSObject<AMAPIDataResponder>

@property (nonatomic, retain) AMDatabaseModel *Database;

-(id) init;

-(BOOL) getTrackByID:(AMAPIDataIDRequest *)request
            Response:(AMAPIDataTrack **)response;

-(BOOL) getTracks:(AMAPIDataRequest *)request
         Response:(AMAPIDataTracks **)response;

-(BOOL) searchTracks:(AMAPIDataStringRequest *)request
            Response:(AMAPIDataTracks **)response;

-(BOOL) getTracksByArtistID:(AMAPIDataIDRequest *)request
                   Response:(AMAPIDataTracks **)response;

-(BOOL) getTracksByAlbumID:(AMAPIDataIDRequest *)request
                  Response:(AMAPIDataTracks **)response;

-(BOOL) getAlbumByID:(AMAPIDataIDRequest *)request
            Response:(AMAPIDataAlbum **)response;

-(BOOL) getAlbums:(AMAPIDataRequest *)request
         Response:(AMAPIDataAlbums **)response;

-(BOOL) searchAlbums:(AMAPIDataStringRequest *)request
            Response:(AMAPIDataAlbums **)response;

-(BOOL) getAlbumsByArtistID:(AMAPIDataIDRequest *)request
                   Response:(AMAPIDataAlbums **)response;

-(BOOL) getArtistByID:(AMAPIDataIDRequest *)request
             Response:(AMAPIDataArtist **)response;

-(BOOL) getArtists:(AMAPIDataRequest *)request
          Response:(AMAPIDataArtists **)response;

-(BOOL) searchArtists:(AMAPIDataStringRequest *)request
             Response:(AMAPIDataArtists **)response;

@end
