//
//  AMJSONResponder.m
//  MusicServer
//
//  Created by Anthony Martin on 30/10/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import "AMJSONResponder.h"
#import "AMAPIDataResponder.h"
#import "AMMusicServerActiveData.h"
#import "AMAPIAuthenticationDataResponder.h"
#import "AMLastFMCommunicationManager.h"
#import "AMAPILastFMResponder.h"

@implementation AMJSONResponder

-(id) initWithDelegate:(id<AMAPIDataResponder>)delegate
          authDelegate:(id<AMAPIAuthenticationDataResponder>)authDelegate
{
    self = [super init];
    if (self)
    {
        [self setDelegate:delegate];
        [self setAuthDelegate:authDelegate];
        [self setLastFMDelegate:[AMLastFMCommunicationManager sharedInstance]];
    }
    return self;
}

-(BOOL) validateSession:(NSString *)Session
{
    return [[self authDelegate] validateSession:Session];
}
 
-(BOOL) handleRequest:(NSData *)data
         responseData:(NSData **)responseData
         responseCode:(NSNumber **)responseCode
        connectedHost:(NSString *)ipAddress
{
    AMJSONAPIData *response = [AMJSONAPIData alloc];
    
    BOOL success = [self handleRequest:data
                              response:&response
                          responseCode:responseCode
                         connectedHost:ipAddress];
    
    if (success)
    {
        *responseData = [response dataFromObject];
        return YES;
    }
    return NO;
}

-(BOOL) handleRequest:(NSData *)data
             response:(AMJSONAPIData **)response
         responseCode:(NSNumber **)responseCode
        connectedHost:(NSString *)ipAddress;
{
    BOOL success = YES;
    NSError *error;
    NSDictionary *dictionary = [AMJSONAPIData deserialiseJSON:data Error:error];
    if (error)
    {
        *responseCode = [NSNumber numberWithInt:500];
        *response = nil;
        return NO;
    }
    
    AMJSONCommandOptions command = [AMJSONAPIData getCommand:dictionary];
    AMJSONAPIData *responseData = nil;
    
    if (command != AMJSONCommandGetSession && command != AMJSONCommandGetToken)
    {
        BOOL validated = NO;
        if ([dictionary objectForKey:@"Session"])
        {
            NSString *session = [dictionary objectForKey:@"Session"];
            validated = ([[self authDelegate] validateSession:session]);
        }
        if (!validated)
        {
            *responseCode = [NSNumber numberWithInt:401];
            *response = nil;
            return NO;
        }
    }
    
    switch (command)
    {
        case AMJSONCommandGetTrackByID:
            if ([[self delegate] respondsToSelector:@selector(getTrackByID:Response:)])
            {
                AMAPIITTrack *output;
                AMAPIDataStringRequest *request = [[AMAPIDataStringRequest alloc] initFromData:data];
                success = [[self delegate] getTrackByID:[request String]
                                               Response:&output];
                responseData = (AMJSONAPIData *)output;
            }
            break;
        case AMJSONCommandGetTracks:
            if ([[self delegate] respondsToSelector:@selector(getTracksResponse:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataRequest *request = [[AMAPIDataRequest alloc] initFromData:data];
                success = [[self delegate] getTracksResponse:&output
                                                       Start:[request Start]
                                                       Limit:[request Limit]];
                responseData = [[AMAPIITTracks alloc] init];
                [(AMAPIITTracks *)responseData setAMAPIITTrackArray:output];
            }
            break;
        case AMJSONCommandGetAlbums:
            if ([[self delegate] respondsToSelector:@selector(getAlbumsResponse:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataRequest *request = [[AMAPIDataRequest alloc] initFromData:data];
                success = [[self delegate] getAlbumsResponse:&output
                                                       Start:[request Start]
                                                       Limit:[request Limit]];
                responseData = [[AMAPIITAlbums alloc] init];
                [(AMAPIITAlbums *)responseData setAMAPIITAlbumArray:output];
            }
            break;
        case AMJSONCommandGetArtists:
            if ([[self delegate] respondsToSelector:@selector(getArtistsResponse:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataRequest *request = [[AMAPIDataRequest alloc] initFromData:data];
                success = [[self delegate] getArtistsResponse:&output
                                                        Start:[request Start]
                                                        Limit:[request Limit]];
                responseData = [[AMAPIITArtists alloc] init];
                [(AMAPIITArtists *)responseData setAMAPIITArtistArray:output];
            }
            break;
        case AMJSONCommandSearchTracks:
            if ([[self delegate] respondsToSelector:@selector(getTracksBySearchString:Response:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataStringRequest *request = [[AMAPIDataStringRequest alloc] initFromData:data];
                success = [[self delegate] getTracksBySearchString:[request String]
                                                          Response:&output
                                                             Start:[request Start]
                                                             Limit:[request Limit]];
                responseData = [[AMAPIITTracks alloc] init];
                [(AMAPIITTracks *)responseData setAMAPIITTrackArray:output];
            }
            break;
        case AMJSONCommandSearchAlbums:
            if ([[self delegate] respondsToSelector:@selector(getAlbumsBySearchString:Response:Start:Limit:)])
            {
                
                NSArray *output;
                AMAPIDataStringRequest *request = [[AMAPIDataStringRequest alloc] initFromData:data];
                success = [[self delegate] getAlbumsBySearchString:[request String]
                                                          Response:&output
                                                             Start:[request Start]
                                                             Limit:[request Limit]];
                responseData = [[AMAPIITAlbums alloc] init];
                [(AMAPIITAlbums *)responseData setAMAPIITAlbumArray:output];
            }
            break;
        case AMJSONCommandSearchArtists:
            if ([[self delegate] respondsToSelector:@selector(getArtistsBySearchString:Response:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataStringRequest *request = [[AMAPIDataStringRequest alloc] initFromData:data];
                success = [[self delegate] getArtistsBySearchString:[request String]
                                                          Response:&output
                                                             Start:[request Start]
                                                             Limit:[request Limit]];
                responseData = [[AMAPIITArtists alloc] init];
                [(AMAPIITArtists *)responseData setAMAPIITArtistArray:output];
            }
            break;
        case AMJSONCommandGetTracksByArtist:
            if ([[self delegate] respondsToSelector:@selector(getTracksByArtist:Response:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataIDRequest *request = [[AMAPIDataIDRequest alloc] initFromData:data];
                success = [[self delegate] getTracksByArtist:[request ID]
                                                    Response:&output
                                                       Start:[request Start]
                                                       Limit:[request Limit]];
                responseData = [[AMAPIITTracks alloc] init];
                [(AMAPIITTracks *)responseData setAMAPIITTrackArray:output];
            }
            break;
        case AMJSONCommandGetTracksByAlbum:
            if ([[self delegate] respondsToSelector:@selector(getTracksByAlbum:Response:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataIDRequest *request = [[AMAPIDataIDRequest alloc] initFromData:data];
                success = [[self delegate] getTracksByAlbum:[request ID]
                                                   Response:&output
                                                      Start:[request Start]
                                                      Limit:[request Limit]];
                responseData = [[AMAPIITTracks alloc] init];
                [(AMAPIITTracks *)responseData setAMAPIITTrackArray:output];
            }
            break;
        case AMJSONCommandGetAlbumsByArtist:
            if ([[self delegate] respondsToSelector:@selector(getAlbumsByArtist:Response:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataIDRequest *request = [[AMAPIDataIDRequest alloc] initFromData:data];
                success = [[self delegate] getAlbumsByArtist:[request ID]
                                                    Response:&output
                                                       Start:[request Start]
                                                       Limit:[request Limit]];
                responseData = [[AMAPIITAlbums alloc] init];
                [(AMAPIITAlbums *)responseData setAMAPIITAlbumArray:output];
            }
            break;
        case AMJSONCommandGetToken:
            if ([[self authDelegate] respondsToSelector:@selector(getToken:response:)])
            {
                AMAPIGetTokenRequest *request = [[AMAPIGetTokenRequest alloc] initFromData:data];
                AMAPIGetTokenResponse *output;
                
                success = [[self authDelegate] getToken:request
                                response:&output];
                
                responseData = (AMJSONAPIData *)output;
            }
            break;
        case AMJSONCommandGetSession:
            if ([[self authDelegate] respondsToSelector:@selector(getSession:response:)])
            {
                AMAPIGetSessionRequest *request = [[AMAPIGetSessionRequest alloc] initFromData:data];
                AMAPIGetSessionResponse *output;
                
                success = [[self authDelegate] getSession:request
                                  response:&output];
                
                if (!success) {
                    *responseCode = [NSNumber numberWithInt:401];
                    *response = nil;
                    [[AMMusicServerActiveData sharedInstance] auditFailedAuthFromIP:ipAddress];
                    return NO;
                }
                
                responseData = (AMJSONAPIData *)output;
            }
            break;
        case AMJSONCommandConvertTrackByID:
            if ([[self delegate] respondsToSelector:@selector(convertTrackByID:Response:)])
            {
                AMAPIConvertTrackResponse *output;
                AMAPIDataStringRequest *request = [[AMAPIDataStringRequest alloc] initFromData:data];
                success = [[self delegate] convertTrackByID:[request String]
                                                   Response:&output];
                responseData = (AMJSONAPIData *)output;
            }
            break;
/*
        case AMJSONCommandLFMScrobbleTrack:
            if ([[self lastFMDelegate] respondsToSelector:@selector(scrobbleTrackByID:)])
            {
                AMAPIScrobbleTrackResponse *output = [[AMAPIScrobbleTrackResponse alloc] init];
                AMAPIDataStringRequest *request = [[AMAPIDataStringRequest alloc] initFromData:data];
                [output setSuccess:[[self lastFMDelegate] scrobbleTrackByID:[request String]]];
                responseData = (AMJSONAPIData *)output;
            }
        case AMJSONCommandLFMNowPlayingTrack:
            if ([[self lastFMDelegate] respondsToSelector:@selector(nowPlayingTrackByID:)])
            {
                AMAPIScrobbleTrackResponse *output = [[AMAPIScrobbleTrackResponse alloc] init];
                AMAPIDataStringRequest *request = [[AMAPIDataStringRequest alloc] initFromData:data];
                [output setSuccess:[[self lastFMDelegate] nowPlayingTrackByID:[request String]]];
                responseData = (AMJSONAPIData *)output;
            }
*/
        case AMJSONCommandUnknown:
            success = NO;
            break;
    }
    if (success)
    {
        *responseCode = [NSNumber numberWithInt:200];
        *response = (AMJSONAPIData *)responseData;
    }
    else if (command == AMJSONCommandUnknown)
    {
        *responseCode = [NSNumber numberWithInt:404];
        *response = nil;
    }
    else
    {
        *responseCode = [NSNumber numberWithInt:500];
        *response = nil;
    }
    
    return success;
}

-(void) dealloc
{
    //[[self service] stopService];
}

@end