//
//  AMJSONListener.m
//  MusicServer
//
//  Created by Anthony Martin on 30/10/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import "AMJSONListener.h"
#import "./AMJSONAPIDataObjects.h"
#import "./HTTPServer/HttpService.h"
#import "./HTTPServer/HTTPRequest.h"
#import "./HTTPServer/HTTPResponse.h"

#define AMSessionUsername @"antm88"
#define AMSessionPassword @"bhu*9ol."
#define AMAPIKey @"iv78vu87gyv879Gf8YIyrTDLUyfpocI2"

@interface AMJSONListener()
@property HttpService *service;
-(HTTPResponse *) GET:(HTTPRequest *) request;
-(HTTPResponse *) POST:(HTTPRequest *) request;
@end

@implementation AMJSONListener

-(id) initOnPort:(NSUInteger)port
    withDelegate:(id<AMAPIDataResponder>)delegate
{
    self = [super init];
    if (self)
    {
        [self setService:[[HttpService alloc] init]];
        [[self service] setResponder:self];
        [[self service] startServiceOnPort:port];
        [self setDelegate:delegate];
        [self setAuthDelegate:(id <AMAPIAuthenticationDataResponder>)self];
        [self setActiveSessions:[[NSMutableDictionary alloc] init]];
        [self setActiveTokens:[[NSMutableDictionary alloc] init]];
    }
    return self;
}

-(BOOL) getSession:(AMAPIGetSessionRequest *)request
        response:(AMAPIGetSessionResponse **)response
{
    @synchronized(self)
    {
        [self removeStaleTokens];
        
        *response = [[AMAPIGetSessionResponse alloc] init];
        __block BOOL found = NO;
        NSMutableArray *tokens = [[self activeTokens] objectForKey:[request APIKey]];
        [tokens enumerateObjectsUsingBlock:^(NSArray *token, NSUInteger idx, BOOL *stop) {
            if ([[request Token] isEqualTo:[token objectAtIndex:0]])
            {
                found = YES;
                *stop = YES;
            }
        }];
        if (!found)
        {
            return NO;
        }
        
        NSString *MD5 = [AMJSONAPIData CalculateMD5:[NSString stringWithFormat:@"%@:%@:%@:%@:%@",
                                                     [request Token],
                                                     AMSessionUsername,
                                                     AMSessionPassword,
                                                     [request APIKey],
                                                     [request Token]]];
        
        if ([MD5 isEqualTo:[request Authentication]])
        {
            [*response setSession:[AMJSONAPIData randomAlphanumericString]];
            [[self activeSessions] setObject:[request APIKey] forKey:[*response Session]];
            return YES;
        }
        return NO;
    }
}

-(BOOL) validateSession:(NSString *)Session
                 APIKey:(NSString *)APIKey
{
    @synchronized(self)
    {
        return ([[self activeSessions] objectForKey:Session]
                && [APIKey isEqualTo:[[self activeSessions] objectForKey:Session]]);
    }
}

-(BOOL) getToken:(AMAPIGetTokenRequest *)request
          response:(AMAPIGetTokenResponse **)response
{
    @synchronized(self)
    {
        [self removeStaleTokens];
        
        *response = [[AMAPIGetTokenResponse alloc] init];
        [*response setToken:[AMJSONAPIData randomAlphanumericString]];
        
        if (![[self activeTokens] objectForKey:[request APIKey]])
        {
            [[self activeTokens] setObject:[[NSMutableArray alloc] init] forKey:[request APIKey]];
        }
        
        NSMutableArray *tokenArray = [[self activeTokens] objectForKey:[request APIKey]];
        NSDate *expiry = [[NSDate date] dateByAddingTimeInterval:3600];
        [tokenArray addObject:[NSArray arrayWithObjects:[*response Token], expiry, nil]];
        return YES;
    }
}

-(void) removeStaleTokens
{
    @synchronized(self)
    {
        for (id key in [self activeTokens])
        {
            NSMutableArray *tokens = [[self activeTokens] objectForKey:key];
            [tokens enumerateObjectsUsingBlock:^(NSArray *token, NSUInteger idx, BOOL *stop) {
                NSDate *expiryDate = [token objectAtIndex:1];
                if ([expiryDate compare:[NSDate date]] == NSOrderedAscending)
                {
                    [tokens removeObjectAtIndex:idx];
                }
            }];
            
            if (![tokens count])
            {
                [[self activeTokens] removeObjectForKey:key];
            }
        }
    }
}

-(HTTPResponse *) GET:(HTTPRequest *) request
{
    HTTPResponse * response = [[HTTPResponse alloc] initWithResponseCode:404];
    return response;
}

-(BOOL) handleRequest:(NSData *)data
             response:(AMJSONAPIData **)response
         responseCode:(NSNumber **)responseCode
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
        if ([dictionary objectForKey:@"Session"] && [dictionary objectForKey:@"APIKey"])
        {
            NSString *session = [dictionary objectForKey:@"Session"];
            NSString *apiKey = [dictionary objectForKey:@"APIKey"];
            validated = ([[self AuthDelegate] validateSession:session APIKey:apiKey]);
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
            if ([[self Delegate] respondsToSelector:@selector(getTrackByID:Response:)])
            {
                AMAPIITTrack *output;
                AMAPIDataStringRequest *request = [[AMAPIDataStringRequest alloc] initFromData:data];
                success = [[self Delegate] getTrackByID:[request String]
                                               Response:&output];
                responseData = (AMJSONAPIData *)output;
            }
            break;
        case AMJSONCommandGetTracks:
            if ([[self Delegate] respondsToSelector:@selector(getTracksResponse:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataRequest *request = [[AMAPIDataRequest alloc] initFromData:data];
                success = [[self Delegate] getTracksResponse:&output
                                                       Start:[request Start]
                                                       Limit:[request Limit]];
                responseData = [[AMAPIITTracks alloc] init];
                [(AMAPIITTracks *)responseData setAMAPIITTrackArray:output];
            }
            break;
        case AMJSONCommandGetAlbums:
            if ([[self Delegate] respondsToSelector:@selector(getAlbumsResponse:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataRequest *request = [[AMAPIDataRequest alloc] initFromData:data];
                success = [[self Delegate] getAlbumsResponse:&output
                                                       Start:[request Start]
                                                       Limit:[request Limit]];
                responseData = [[AMAPIITAlbums alloc] init];
                [(AMAPIITAlbums *)responseData setAMAPIITAlbumArray:output];
            }
            break;
        case AMJSONCommandGetArtists:
            if ([[self Delegate] respondsToSelector:@selector(getArtistsResponse:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataRequest *request = [[AMAPIDataRequest alloc] initFromData:data];
                success = [[self Delegate] getArtistsResponse:&output
                                                        Start:[request Start]
                                                        Limit:[request Limit]];
                responseData = [[AMAPIITArtists alloc] init];
                [(AMAPIITArtists *)responseData setAMAPIITArtistArray:output];
            }
            break;
        case AMJSONCommandSearchTracks:
            if ([[self Delegate] respondsToSelector:@selector(getTracksBySearchString:Response:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataStringRequest *request = [[AMAPIDataStringRequest alloc] initFromData:data];
                success = [[self Delegate] getTracksBySearchString:[request String]
                                                          Response:&output
                                                             Start:[request Start]
                                                             Limit:[request Limit]];
                responseData = [[AMAPIITTracks alloc] init];
                [(AMAPIITTracks *)responseData setAMAPIITTrackArray:output];
            }
            break;
        case AMJSONCommandSearchAlbums:
            if ([[self Delegate] respondsToSelector:@selector(getAlbumsBySearchString:Response:Start:Limit:)])
            {
                
                NSArray *output;
                AMAPIDataStringRequest *request = [[AMAPIDataStringRequest alloc] initFromData:data];
                success = [[self Delegate] getAlbumsBySearchString:[request String]
                                                          Response:&output
                                                             Start:[request Start]
                                                             Limit:[request Limit]];
                responseData = [[AMAPIITAlbums alloc] init];
                [(AMAPIITAlbums *)responseData setAMAPIITAlbumArray:output];
            }
            break;
        case AMJSONCommandSearchArtists:
            if ([[self Delegate] respondsToSelector:@selector(getArtistsBySearchString:Response:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataStringRequest *request = [[AMAPIDataStringRequest alloc] initFromData:data];
                success = [[self Delegate] getArtistsBySearchString:[request String]
                                                          Response:&output
                                                             Start:[request Start]
                                                             Limit:[request Limit]];
                responseData = [[AMAPIITArtists alloc] init];
                [(AMAPIITArtists *)responseData setAMAPIITArtistArray:output];
            }
            break;
        case AMJSONCommandGetTracksByArtist:
            if ([[self Delegate] respondsToSelector:@selector(getTracksByArtist:Response:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataIDRequest *request = [[AMAPIDataIDRequest alloc] initFromData:data];
                success = [[self Delegate] getTracksByArtist:[request ID]
                                                    Response:&output
                                                       Start:[request Start]
                                                       Limit:[request Limit]];
                responseData = [[AMAPIITTracks alloc] init];
                [(AMAPIITTracks *)responseData setAMAPIITTrackArray:output];
            }
            break;
        case AMJSONCommandGetTracksByAlbum:
            if ([[self Delegate] respondsToSelector:@selector(getTracksByAlbum:Response:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataIDRequest *request = [[AMAPIDataIDRequest alloc] initFromData:data];
                success = [[self Delegate] getTracksByAlbum:[request ID]
                                                   Response:&output
                                                      Start:[request Start]
                                                      Limit:[request Limit]];
                responseData = [[AMAPIITTracks alloc] init];
                [(AMAPIITTracks *)responseData setAMAPIITTrackArray:output];
            }
            break;
        case AMJSONCommandGetAlbumsByArtist:
            if ([[self Delegate] respondsToSelector:@selector(getAlbumsByArtist:Response:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataIDRequest *request = [[AMAPIDataIDRequest alloc] initFromData:data];
                success = [[self Delegate] getAlbumsByArtist:[request ID]
                                                    Response:&output
                                                       Start:[request Start]
                                                       Limit:[request Limit]];
                responseData = [[AMAPIITAlbums alloc] init];
                [(AMAPIITAlbums *)responseData setAMAPIITAlbumArray:output];
            }
            break;
        case AMJSONCommandGetToken:
            if ([[self AuthDelegate] respondsToSelector:@selector(getToken:response:)])
            {
                AMAPIGetTokenRequest *request = [[AMAPIGetTokenRequest alloc] initFromData:data];
                AMAPIGetTokenResponse *output;
                
                success = [self getToken:request
                                response:&output];
                
                responseData = (AMJSONAPIData *)output;
            }
            break;
        case AMJSONCommandGetSession:
            if ([[self AuthDelegate] respondsToSelector:@selector(getSession:response:)])
            {
                AMAPIGetSessionRequest *request = [[AMAPIGetSessionRequest alloc] initFromData:data];
                AMAPIGetSessionResponse *output;
                
                success = [self getSession:request
                                  response:&output];
                
                if (!success) {
                    *responseCode = [NSNumber numberWithInt:401];
                    *response = nil;
                    return NO;
                }
                
                responseData = (AMJSONAPIData *)output;
            }
            break;
        case AMJSONCommandConvertTrackByID:
            if ([[self Delegate] respondsToSelector:@selector(convertTrackByID:Response:)])
            {
                AMAPIConvertTrackResponse *output;
                AMAPIDataStringRequest *request = [[AMAPIDataStringRequest alloc] initFromData:data];
                success = [[self Delegate] convertTrackByID:[request String]
                                                   Response:&output];
                responseData = (AMJSONAPIData *)output;
            }
            break;
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

-(HTTPResponse *) POST:(HTTPRequest *) request
{
    AMJSONAPIData *responseData = [AMJSONAPIData alloc];
    NSNumber *responseCode = [NSNumber alloc];
    BOOL success = [self handleRequest:[request body]
                              response:&responseData
                          responseCode:&responseCode];
    
    HTTPResponse *httpResponse = [[HTTPResponse alloc] initWithResponseCode:[responseCode intValue]];
    if (success)
    {
        [httpResponse setBodyData:[responseData dataFromObject]];
    }
    return httpResponse;
}

-(void) dealloc
{
    [[self service] stopService];
}

@end