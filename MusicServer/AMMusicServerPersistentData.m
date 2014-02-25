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

-(void)addCachedTrack:(NSString *)name AtLocation:(NSURL *)location
{
    NSDictionary *cachedTrack = [self getCachedTrack:name];
    if (cachedTrack != nil)
    {
        [self removeCachedTrack:cachedTrack saveData:NO deleteFile:NO];
    }
    
    while ([[self maxCachedTracks] isLessThanOrEqualTo:[NSNumber numberWithInteger:[[self cachedTracks] count]]]
           && [[self cachedTracks] count] > 0)
    {
        [self removeCachedTrack:[[self cachedTracks] lastObject] saveData:NO deleteFile:YES];
    }
    
    [[self cachedTracks] insertObject:[NSDictionary dictionaryWithObjectsAndKeys:name, @"Name", [location path], @"Location", nil] atIndex:0];
    [self saveCachedTracks];
}

-(void)removeCachedTrack:(NSDictionary *)cachedTrack saveData:(BOOL)save deleteFile:(BOOL)delete
{
    [[self cachedTracks] removeObject:cachedTrack];
    
    if (delete)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *path = [[cachedTrack valueForKey:@"Location"] path];
        if ([fileManager fileExistsAtPath:path] && [fileManager isDeletableFileAtPath:path])
        {
            [fileManager removeItemAtPath:path error:nil];
        }
    }
    
    if (save)
    {
        [self saveCachedTracks];
    }
}

-(NSURL *)getCachedTrackLocation:(NSString *)name
{
    NSDictionary *cachedTrack = [self getCachedTrack:name];
    if (cachedTrack != nil)
    {
        return [NSURL fileURLWithPath:[cachedTrack valueForKey:@"Location"]];
    }
    
    return nil;
}

-(NSDictionary *)getCachedTrack:(NSString *)name
{
    for (NSDictionary *cachedTrack in [self cachedTracks])
    {
        if ([[cachedTrack objectForKey:@"Name"] isEqualToString:name])
        {
            return cachedTrack;
        }
    }
    
    return nil;
}

@end