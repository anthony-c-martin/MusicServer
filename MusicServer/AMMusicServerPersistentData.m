//
//  AMMusicServerPersistentData.m
//  MusicServer
//
//  Created by Anthony Martin on 25/02/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import "AMMusicServerPersistentData.h"

#define AMDefaultUsername @"username"
#define AMDefaultPassword @"password"
#define AMDefaultAPIKey @"iv78vu87gyv879Gf8YIyrTDLUyfpocI2"
#define AMDefaultMaxSessions 5
#define AMDefaultMaxCachedTracks 100
#define AMDefaultUseAlbumArt 0

@interface AMMusicServerPersistentData()

@property (nonatomic, retain) NSMutableArray *cachedTracks;

@end

@implementation AMMusicServerPersistentData

@synthesize username;
@synthesize password;
@synthesize apiKey;
@synthesize maxSessions;
@synthesize maxCachedTracks;
@synthesize cachedTracks;
@synthesize useAlbumArt;

-(id)init
{
    self = [super initWithPlist:@"com.acm.AMMusicServer"];
    if (self)
    {
        
    }
    return self;
}

-(void)setUsername:(NSString *)value
{
    username = [NSString stringWithString:value];
    [self setString:username WithKey:@"Username"];
}

-(NSString *)username
{
    if (!username)
    {
        username = [NSString stringWithString:[self getStringWithKey:@"Username"]];
        if (!username)
        {
            [self setUsername:AMDefaultUsername];
        }
    }
    return username;
}

-(void)setPassword:(NSString *)value
{
    password = [NSString stringWithString:value];
    [self setString:password WithKey:@"Password"];
}

-(NSString *)password
{
    if (!password)
    {
        password = [NSString stringWithString:[self getStringWithKey:@"Password"]];
        if (!password)
        {
            [self setPassword:AMDefaultPassword];
        }
    }
    return password;
}

-(void)setApiKey:(NSString *)value
{
    apiKey = [NSString stringWithString:value];
    [self setString:apiKey WithKey:@"APIKey"];
}

-(NSString *)apiKey
{
    if (!apiKey)
    {
        apiKey = [NSString stringWithString:[self getStringWithKey:@"APIKey"]];
        if (!apiKey)
        {
            [self setApiKey:AMDefaultAPIKey];
        }
    }
    return apiKey;
}

-(void)setMaxSessions:(NSNumber *)value
{
    maxSessions = value;
    [self setNumber:maxSessions WithKey:@"MaxSessions"];
}

-(NSNumber *)maxSessions
{
    if (!maxSessions)
    {
        maxSessions = [self getNumberWithKey:@"MaxSessions"];
        if (!maxSessions)
        {
            [self setMaxSessions:[NSNumber numberWithInt:AMDefaultMaxSessions]];
        }
    }
    return maxSessions;
}

-(void)setMaxCachedTracks:(NSNumber *)value
{
    maxCachedTracks = value;
    [self setNumber:maxCachedTracks WithKey:@"MaxCachedTracks"];
}

-(NSNumber *)maxCachedTracks
{
    if (!maxCachedTracks)
    {
        maxCachedTracks = [self getNumberWithKey:@"MaxCachedTracks"];
        if (!maxCachedTracks)
        {
            [self setMaxCachedTracks:[NSNumber numberWithInt:AMDefaultMaxCachedTracks]];
        }
    }
    return maxCachedTracks;
}

-(void)setUseAlbumArt:(NSNumber *)value
{
    useAlbumArt = value;
    [self setNumber:useAlbumArt WithKey:@"UseAlbumArt"];
}

-(NSNumber *)useAlbumArt
{
    if (!useAlbumArt)
    {
        useAlbumArt = [self getNumberWithKey:@"UseAlbumArt"];
        if (!useAlbumArt)
        {
            [self setUseAlbumArt:[NSNumber numberWithInt:AMDefaultUseAlbumArt]];
        }
    }
    return useAlbumArt;
}

-(void)saveCachedTracks
{
    [self setArray:cachedTracks WithKey:@"CachedTracks"];
}

-(void)setCachedTracks:(NSMutableArray *)value
{
    cachedTracks = [NSMutableArray arrayWithArray:value];
    [self saveCachedTracks];
}

-(NSMutableArray *)cachedTracks
{
    if (!cachedTracks)
    {
        cachedTracks = [NSMutableArray arrayWithArray:[self getArrayWithKey:@"CachedTracks"]];
        if (!cachedTracks)
        {
            [self setCachedTracks:[[NSMutableArray alloc] init]];
        }
    }
    return cachedTracks;
}

-(void)addCachedTrack:(NSString *)name
{
    [self removeCachedTrack:name saveData:NO deleteFile:NO];
    
    while ([[self maxCachedTracks] isLessThanOrEqualTo:[NSNumber numberWithInteger:[[self cachedTracks] count]]]
           && [[self cachedTracks] count] > 0)
    {
        [self removeCachedTrack:[[self cachedTracks] lastObject] saveData:NO deleteFile:YES];
    }
    
    [[self cachedTracks] insertObject:name atIndex:0];
    [self saveCachedTracks];
}

-(void)removeCachedTrack:(NSString *)name saveData:(BOOL)save deleteFile:(BOOL)delete
{
    if ([[self cachedTracks] containsObject:name])
    {
        if (delete)
        {
            NSString *path = [[self getCachedTrackLocation:name] path];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:path] && [fileManager isDeletableFileAtPath:path])
            {
                [fileManager removeItemAtPath:path error:nil];
            }
        }
        
        [[self cachedTracks] removeObject:name];
        
        if (save)
        {
            [self saveCachedTracks];
        }
    }
}

-(void)removeCachedTrack:(NSString *)name
{
    [self removeCachedTrack:name saveData:YES deleteFile:YES];
}

-(NSURL *)getCachedTrackLocation:(NSString *)name
{
    if ([[self cachedTracks] containsObject:name])
    {
        return [self getLocationForTrack:name];
    }
    return nil;
}

-(NSURL *)getLocationForTrack:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths firstObject];
    NSURL *fileURL = [[[NSURL fileURLWithPath:applicationSupportDirectory] URLByAppendingPathComponent:@"AMMusicServer"] URLByAppendingPathComponent:name];
    return fileURL;
}

@end