//
//  AMJSONAPIDataObjects.m
//  MusicServer
//
//  Created by Anthony Martin on 30/10/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import "AMJSONAPIDataObjects.h"

@implementation AMAPIDataRequest
-(id) initFromData:(NSData *)data
         responder:(AMJSONResponder *)responder
{
    self = [super initFromData:data responder:responder];
    if (self)
    {
        if (![self Start]) [self setStart:[NSNumber numberWithInt:0]];
        if (![self Limit]) [self setLimit:[NSNumber numberWithInt:0]];
    }
    return self;
}
@end

@implementation AMAPIDataIDRequest
-(id) initFromData:(NSData *)data
         responder:(AMJSONResponder *)responder
{
    self = [super initFromData:data responder:responder];
    if (self)
    {
        if (![self ID]) [self setID:[NSNumber numberWithInt:0]];
    }
    return self;
}
@end

@implementation AMAPIDataStringRequest
-(id) initFromData:(NSData *)data
         responder:(AMJSONResponder *)responder
{
    self = [super initFromData:data responder:responder];
    if (self)
    {
        if (![self String]) [self setString:@""];
    }
    return self;
}
@end

@implementation AMAPIGetSessionRequest
-(id) initFromData:(NSData *)data
         responder:(AMJSONResponder *)responder
{
    self = [super initFromData:data responder:responder];
    if (self)
    {
        if (![self Token]) [self setToken:@""];
        if (![self Authentication]) [self setAuthentication:@""];
    }
    return self;
}
@end

@implementation AMAPIBlankRequest
-(id) initFromData:(NSData *)data
         responder:(AMJSONResponder *)responder
{
    self = [super initFromData:data responder:responder];
    if (self)
    {
        
    }
    return self;
}
@end

@implementation AMAPIGetSessionResponse
-(NSDictionary *) propertiesToDictionaryEntriesMapping
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"Session", @"Session",
            @"Secret", @"Secret",
            nil];
}
@end

@implementation AMAPIGetTokenResponse
-(NSDictionary *) propertiesToDictionaryEntriesMapping
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"Token", @"Token",
            nil];
}
@end

@implementation AMAPIGetUserPreferencesResponse
-(NSDictionary *) propertiesToDictionaryEntriesMapping
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"ScrobblingEnabled", @"ScrobblingEnabled",
            nil];
}
@end

@implementation AMAPIConvertTrackResponse
-(NSDictionary *) propertiesToDictionaryEntriesMapping
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"Result", @"Result",
            @"FileName", @"FileName",
            nil];
}
@end

@implementation AMAPIScrobbleTrackResponse
-(NSDictionary *) propertiesToDictionaryEntriesMapping
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"Success", @"Success",
            nil];
}
@end

@implementation AMAPIITArtist
-(id) init
{
    self = [super init];
    if (self)
    {
        [self setAlbumSet:[[NSMutableSet alloc] init]];
        [self setTrackSet:[[NSMutableSet alloc] init]];
    }
    return self;
}

-(NSComparisonResult) compare:(id)object
{
    if (![object isKindOfClass:[AMAPIITArtist class]])
    {
        return NSOrderedAscending;
    }
    return [[self Name] compare:[object Name] options:NSCaseInsensitiveSearch];
}

-(BOOL) isEqual:(id)object
{
    return [object isKindOfClass:[AMAPIITArtist class]]
    && [[self Name] isEqual:[object Name]];
}

-(NSUInteger) hash
{
    return [[self Name] hash];
}

-(NSDictionary *) propertiesToDictionaryEntriesMapping
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"ID", @"ID",
            @"Name", @"Name",
            nil];
}
@end

@implementation AMAPIITAlbum
-(id) init
{
    self = [super init];
    if (self)
    {
        [self setTrackSet:[[NSMutableSet alloc] init]];
    }
    return self;
}

-(NSComparisonResult) compare:(id)object
{
    NSComparisonResult result;
    if (![object isKindOfClass:[AMAPIITAlbum class]])
    {
        return NSOrderedAscending;
    }

    result = [[self Artist] compare:[object Artist]];
    if (result != NSOrderedSame)
    {
        return result;
    }
    
    return [[self Name] compare:[object Name] options:NSCaseInsensitiveSearch];
}

-(BOOL) isEqual:(id)object
{
    return [object isKindOfClass:[AMAPIITAlbum class]]
        && [[self Name] isEqual:[object Name]]
        && [[self Artist] isEqual:[object Artist]];
}

-(NSUInteger) hash
{
    return [[self Name] hash] ^ [[self Artist] hash];
}

-(NSDictionary *) propertiesToDictionaryEntriesMapping
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"ID", @"ID",
            @"Name", @"Name",
            @"Artist", @"Artist",
            @"Artwork", @"Artwork",
            nil];
}
@end

@implementation AMAPIITTrack
-(id) init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}   

-(NSComparisonResult)compare:(id)object
{
    NSComparisonResult result;
    if (![object isKindOfClass:[AMAPIITTrack class]])
    {
        return NSOrderedAscending;
    }
    
    result = [[self Artist] compare:[object Artist]];
    if (result != NSOrderedSame)
    {
        return result;
    }
    
    result = [[self Album] compare:[object Album]];
    if (result != NSOrderedSame)
    {
        return result;
    }
    
    return [[self Name] compare:[object Name] options:NSCaseInsensitiveSearch];
}

-(BOOL) isEqual:(id)object
{
    return [object isKindOfClass:[AMAPIITTrack class]] && [[self ID] isEqual:[object ID]];
}

-(NSUInteger) hash
{
    return [[self ID] hash];
}

-(NSDictionary *) propertiesToDictionaryEntriesMapping
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"ID", @"ID",
            @"Name", @"Name",
            @"TrackNumber", @"TrackNumber",
            @"DiscNumber", @"DiscNumber",
            @"Duration", @"Duration",
            @"Artist", @"Artist",
            @"Album", @"Album",
            nil];
}
@end

@implementation AMAPIITTracks
-(NSDictionary *) propertiesToDictionaryEntriesMapping
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"AMAPIITTrackArray", @"Tracks",
            nil];
}
@end

@implementation AMAPIITAlbums
-(NSDictionary *) propertiesToDictionaryEntriesMapping
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"AMAPIITAlbumArray", @"Albums",
            nil];
}
@end

@implementation AMAPIITArtists
-(NSDictionary *) propertiesToDictionaryEntriesMapping
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"AMAPIITArtistArray", @"Artists",
            nil];
}
@end