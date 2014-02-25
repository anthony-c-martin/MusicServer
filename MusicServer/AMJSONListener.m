//
//  AMJSONListener.m
//  MusicServer
//
//  Created by Anthony Martin on 30/10/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import "AMJSONListener.h"
#import "./AMJSONAPIDataObjects.h"

#define AMSessionUsername @"antm88"
#define AMSessionPassword @"bhu*9ol."
#define AMAPIKey @"iv78vu87gyv879Gf8YIyrTDLUyfpocI2"

@implementation AMJSONListener

-(id) initOnPort:(NSUInteger)port
    withDelegate:(id<AMAPIDataResponder>)delegate
{
    self = [super init];
    if (self)
    {

        
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

/*
-(HTTPResponse *) GET:(HTTPRequest *) request
{
    NSString *queryString = [[request url] query];
    NSArray *pairs = [queryString componentsSeparatedByString:@"&"];
    NSMutableDictionary *kvPairs = [NSMutableDictionary dictionary];
    for (NSString * pair in pairs)
    {
        NSArray * bits = [pair componentsSeparatedByString:@"="];
        NSString * key = [[bits objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString * value = [[bits objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [kvPairs setObject:value forKey:key];
    }

    NSString *sessionKey;
    NSString *filePath;
    if ([kvPairs objectForKey:@"file"] && ([kvPairs objectForKey:@"session"]))
    {
        filePath = [NSString stringWithFormat:@"%@%@", @"/Library/WebServer/AMMusicServer/", [kvPairs objectForKey:@"file"]];
        sessionKey = [kvPairs objectForKey:@"session"];
    }
    
    NSData *fileData = [[NSData alloc] initWithContentsOfFile:filePath];
    
    if (![[request headers] objectForKey:@"Range"])
    {
        return [[HTTPResponse alloc] initWithResponseCode:404];
    }
    
    NSString *range = [[request headers] objectForKey:@"Range"];
    NSString *bytes = [range substringToIndex:6];
    if (![bytes isEqualToString:@"bytes="])
    {
        return [[HTTPResponse alloc] initWithResponseCode:404];
    }
    
    range = [range substringFromIndex:6];
    NSArray *components = [range componentsSeparatedByString:@"-"];
    if (![components objectAtIndex:0] && [components objectAtIndex:1])
    {
        return [[HTTPResponse alloc] initWithResponseCode:404];
    }
    NSInteger startBytes = [[components objectAtIndex:0] integerValue];
    NSInteger endBytes = [[components objectAtIndex:1] integerValue];
    
    if ([[components objectAtIndex:1] isEqualToString:@""] || endBytes >= [fileData length])
    {
        endBytes = [fileData length] - 1;
    }
    
    HTTPResponse * response = [[HTTPResponse alloc] initWithResponseCode:206];
    [response setHeaderField:@"Content-Range" toValue:[NSString stringWithFormat:@"bytes %ld-%ld/%ld", startBytes, endBytes, [fileData length]]];
    [response setHeaderField:@"Content-Length" toValue:[NSString stringWithFormat:@"%ld", (endBytes - startBytes) + 1]];
    [response setBodyData:[fileData subdataWithRange:NSMakeRange(startBytes, endBytes + 1)]];
    
    return response;
}
*/

/*
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
*/
 
-(BOOL) handleRequest:(NSData *)data
         responseData:(NSData **)responseData
         responseCode:(NSNumber **)responseCode
{
    AMJSONAPIData *response = [AMJSONAPIData alloc];
    
    BOOL success = [self handleRequest:data
                              response:&response
                          responseCode:responseCode];
    
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

-(void) dealloc
{
    //[[self service] stopService];
}

@end