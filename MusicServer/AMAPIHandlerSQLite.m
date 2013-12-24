//
//  AMAPIHandlerSQLite.m
//  MusicServer
//
//  Created by Anthony Martin on 02/11/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import "AMAPIHandlerSQLite.h"
#import "./AMDatabaseModel.h"

@implementation AMAPIHandlerSQLite

-(id) init
{
    self = [super init];
    if (self)
    {
        [self setDatabase:[[AMDatabaseModel alloc] initOpen]];
    }
    return self;
}

-(BOOL) getTrackByID:(AMAPIDataIDRequest *)request
            Response:(AMAPIDataTrack **)response
{
    NSDictionary *dictionary;
    if ([[[self Database] TracksModel] getRowByID:[request ID] toDictionary:&dictionary])
    {
        *response = [[AMAPIDataTrack alloc] initWithDictionary:dictionary];
        return !!response;
    }
    
    return NO;
}

-(BOOL) getTracks:(AMAPIDataRequest *)request
         Response:(AMAPIDataTracks **)response
{
    NSArray *array;
    NSNumber *rowCount;
    if ([[[self Database] TracksModel] getRows:[request Start]
                                         limit:[request Limit]
                                       toArray:&array
                                      rowCount:&rowCount])
    {
        *response = [[AMAPIDataTracks alloc] initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:array, @"AMAPIDataTrackCollection", nil]];
        return !!response;
    }
    return NO;
}

-(BOOL) getTracksByArtistID:(AMAPIDataIDRequest *)request
                   Response:(AMAPIDataTracks **)response
{
    NSArray *array;
    NSNumber *rowCount;
    if ([[[self Database] TracksModel] getTracksByArtist:[request ID]
                                                   start:[request Start]
                                                   limit:[request Limit]
                                                 toArray:&array
                                                rowCount:&rowCount])
    {
        *response = [[AMAPIDataTracks alloc] initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:array, @"AMAPIDataTrackCollection", nil]];
        return !!response;
    }
    return NO;
}

-(BOOL) searchTracks:(AMAPIDataStringRequest *)request
            Response:(AMAPIDataTracks **)response
{
    NSArray *array;
    NSNumber *rowCount;
    if ([[[self Database] TracksModel] searchTracks:[request String]
                                              start:[request Start]
                                              limit:[request Limit]
                                            toArray:&array
                                           rowCount:&rowCount])
    {
        *response = [[AMAPIDataTracks alloc] initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:array, @"AMAPIDataTrackCollection", nil]];
        return !!response;
    }
    return NO;
}

-(BOOL) getTracksByAlbumID:(AMAPIDataIDRequest *)request
                  Response:(AMAPIDataTracks **)response
{
    NSArray *array;
    NSNumber *rowCount;
    if ([[[self Database] TracksModel] getTracksByAlbum:[request ID]
                                                  start:[request Start]
                                                  limit:[request Limit]
                                                toArray:&array
                                               rowCount:&rowCount])
    {
        *response = [[AMAPIDataTracks alloc] initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:array, @"AMAPIDataTrackCollection", nil]];
        return !!response;
    }
    return NO;
}

-(BOOL) getAlbumByID:(AMAPIDataIDRequest *)request
            Response:(AMAPIDataAlbum **)response
{
    NSDictionary *dictionary;
    if ([[[self Database] AlbumsModel] getRowByID:[request ID] toDictionary:&dictionary])
    {
        *response = [[AMAPIDataAlbum alloc] initWithDictionary:dictionary];
        return !!response;
    }
    
    return NO;
}

-(BOOL) getAlbums:(AMAPIDataRequest *)request
         Response:(AMAPIDataAlbums **)response
{
    NSArray *array;
    NSNumber *rowCount;
    if ([[[self Database] AlbumsModel] getRows:[request Start]
                                         limit:[request Limit]
                                       toArray:&array
                                      rowCount:&rowCount])
    {
        *response = [[AMAPIDataAlbums alloc] initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:array, @"AMAPIDataAlbumCollection", nil]];
        return !!response;
    }
    return NO;
}

-(BOOL) searchAlbums:(AMAPIDataStringRequest *)request
            Response:(AMAPIDataAlbums **)response
{
    NSArray *array;
    NSNumber *rowCount;
    if ([[[self Database] AlbumsModel] searchAlbums:[request String]
                                              start:[request Start]
                                              limit:[request Limit]
                                            toArray:&array
                                           rowCount:&rowCount])
    {
        *response = [[AMAPIDataAlbums alloc] initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:array, @"AMAPIDataAlbumCollection", nil]];
        return !!response;
    }
    return NO;
}

-(BOOL) getAlbumsByArtistID:(AMAPIDataIDRequest *)request
                   Response:(AMAPIDataAlbums **)response
{
    NSArray *array;
    NSNumber *rowCount;
    if ([[[self Database] AlbumsModel] getAlbumsByArtist:[request ID]
                                                   start:[request Start]
                                                   limit:[request Limit]
                                                 toArray:&array
                                                rowCount:&rowCount])
    {
        *response = [[AMAPIDataAlbums alloc] initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:array, @"AMAPIDataAlbumCollection", nil]];
        return !!response;
    }
    return NO;
}

-(BOOL) getArtistByID:(AMAPIDataIDRequest *)request
             Response:(AMAPIDataArtist **)response
{
    NSDictionary *dictionary;
    if ([[[self Database] ArtistsModel] getRowByID:[request ID] toDictionary:&dictionary])
    {
        *response = [[AMAPIDataArtist alloc] initWithDictionary:dictionary];
        return !!response;
    }
    
    return NO;
}

-(BOOL) getArtists:(AMAPIDataRequest *)request
          Response:(AMAPIDataArtists **)response
{
    NSArray *array;
    NSNumber *rowCount;
    if ([[[self Database] ArtistsModel] getRows:[request Start]
                                         limit:[request Limit]
                                       toArray:&array
                                      rowCount:&rowCount])
    {
        *response = [[AMAPIDataArtists alloc] initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:array, @"AMAPIDataArtistCollection", nil]];
        return !!response;
    }
    return NO;
}

-(BOOL) searchArtists:(AMAPIDataStringRequest *)request
             Response:(AMAPIDataArtists **)response
{
    NSArray *array;
    NSNumber *rowCount;
    if ([[[self Database] ArtistsModel] searchArtists:[request String]
                                                start:[request Start]
                                                limit:[request Limit]
                                              toArray:&array
                                             rowCount:&rowCount])
    {
        *response = [[AMAPIDataArtists alloc] initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:array, @"AMAPIDataArtistCollection", nil]];
        return !!response;
    }
    return NO;
}

@end