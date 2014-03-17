//
//  AMAPIDataResponder.h
//  MusicServer
//
//  Created by Anthony Martin on 15/03/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMJSONAPIDataObjects.h"

@protocol AMAPIDataResponder <NSObject>

-(BOOL) getTrackByID:(NSString *)request
            Response:(AMAPIITTrack **)response;

-(BOOL) convertTrackByID:(NSString *)request
                Response:(AMAPIConvertTrackResponse **)response;

-(BOOL) getTracksResponse:(NSArray **)response
                    Start:(NSNumber *)start
                    Limit:(NSNumber *)limit;

-(BOOL) getAlbumsResponse:(NSArray **)response
                    Start:(NSNumber *)start
                    Limit:(NSNumber *)limit;

-(BOOL) getArtistsResponse:(NSArray **)response
                     Start:(NSNumber *)start
                     Limit:(NSNumber *)limit;

-(BOOL) getTracksBySearchString:(NSString *)request
                       Response:(NSArray **)response
                          Start:(NSNumber *)start
                          Limit:(NSNumber *)limit;

-(BOOL) getAlbumsBySearchString:(NSString *)request
                       Response:(NSArray **)response
                          Start:(NSNumber *)start
                          Limit:(NSNumber *)limit;

-(BOOL) getArtistsBySearchString:(NSString *)request
                        Response:(NSArray **)response
                           Start:(NSNumber *)start
                           Limit:(NSNumber *)limit;

-(BOOL) getTracksByArtist:(NSNumber *)request
                 Response:(NSArray **)response
                    Start:(NSNumber *)start
                    Limit:(NSNumber *)limit;

-(BOOL) getTracksByAlbum:(NSNumber *)request
                Response:(NSArray **)response
                   Start:(NSNumber *)start
                   Limit:(NSNumber *)limit;

-(BOOL) getAlbumsByArtist:(NSNumber *)request
                 Response:(NSArray **)response
                    Start:(NSNumber *)start
                    Limit:(NSNumber *)limit;

@end