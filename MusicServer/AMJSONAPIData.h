//
//  AMJSONAPIData.h
//  MusicServer
//
//  Created by Anthony Martin on 30/10/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "./IAModelBase/IAModelBase.h"

typedef NS_OPTIONS(NSUInteger, AMJSONCommandOptions)
{
    AMJSONCommandGetTrackByID,
    AMJSONCommandGetTracks,
    AMJSONCommandGetAlbums,
    AMJSONCommandGetArtists,
    AMJSONCommandSearchTracks,
    AMJSONCommandSearchAlbums,
    AMJSONCommandSearchArtists,
    AMJSONCommandGetTracksByArtist,
    AMJSONCommandGetTracksByAlbum,
    AMJSONCommandGetAlbumsByArtist,
    AMJSONCommandGetToken,
    AMJSONCommandGetSession,
    AMJSONCommandConvertTrackByID,
    AMJSONCommandLFMScrobbleTrack,
    AMJSONCommandLFMNowPlayingTrack,
    AMJSONCommandUnknown,
};

#define AMJSONCommands @"GetTrackByID", @"GetTracks", @"GetAlbums", @"GetArtists", @"SearchTracks", @"SearchAlbums", @"SearchArtists", @"GetTracksByArtist", @"GetTracksByAlbum", @"GetAlbumsByArtist", @"GetToken", @"GetSession", @"ConvertTrackByID", @"LFMScrobbleTrack", @"LFMNowPlayingTrack", nil

@interface AMJSONAPIData : IAModelBase

@property (nonatomic, retain) NSString *Signature;

-(id) initFromData:(NSData *)data;

-(NSData *) dataFromObject;

+(NSString *) CalculateMD5:(NSString *)input;

+(NSString *) randomAlphanumericString;

+(NSDictionary *) deserialiseJSON:(NSData *)data
                            Error:(NSError *)error;

+(NSData *) serialiseJSON:(NSDictionary *)dictionary
                    Error:(NSError *)error;

+(NSData *) serialiseJSONArray:(NSArray *)array
                    Error:(NSError *)error;

+(AMJSONCommandOptions) getCommand:(NSDictionary *)dictionary;

@end