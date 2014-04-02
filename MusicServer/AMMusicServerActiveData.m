//
//  AMMusicServerActiveData.m
//  MusicServer
//
//  Created by Anthony Martin on 25/02/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import "AMMusicServerActiveData.h"
#import "AMPersistentData.h"
#import "AMJSONAPIData.h"

#define AMDefaultUsername @"username"
#define AMDefaultPassword @"75476581dd1db581d18afc1cfcd52ecb" //this is 'password', hashed against the username
#define AMDefaultMaxSessions 5
#define AMDefaultMaxCachedTracks 100
#define AMDefaultUseAlbumArt 0
#define AMMusicServerPlistName @"com.acm.AMMusicServer"

#define REQUEST_BLACKLIST_AGE 600

@interface AMMusicServerActiveData()
{
    @private
    int requestsCounter;
    int authRequestsCounter;
    int ipBlackListCounter;
}

@property (nonatomic, retain) NSMutableArray *cachedTracks;
@property (nonatomic, retain) NSMutableDictionary *requests;
@property (nonatomic, retain) NSMutableDictionary *authRequests;
@property (nonatomic, retain) NSMutableDictionary *ipBlackList;
@property (nonatomic, retain) AMPersistentData *persistentData;

@end

@interface AMRequestHistory : NSObject
{
    @public
    int lastInterval;
    int count;
}
@end

@implementation AMRequestHistory
@end

@implementation AMMusicServerActiveData

@synthesize username;
@synthesize password;
@synthesize maxSessions;
@synthesize maxCachedTracks;
@synthesize cachedTracks;
@synthesize useAlbumArt;
@synthesize requests;
@synthesize authRequests;
@synthesize ipBlackList;
@synthesize lastFMToken;
@synthesize lastFMSessionKey;
@synthesize lastFMUsername;

-(id)init
{
    self = [super init];
    if (self)
    {
        [self setRequests:[[NSMutableDictionary alloc] init]];
        [self setAuthRequests:[[NSMutableDictionary alloc] init]];
        [self setIpBlackList:[[NSMutableDictionary alloc] init]];
        [self setPersistentData:[[AMPersistentData alloc] initWithPlist:AMMusicServerPlistName]];
    }
    return self;
}

-(void)setUsername:(NSString *)value
{
    username = [NSString stringWithString:value];
    [[self persistentData] setString:username WithKey:@"Username"];
}

-(NSString *)username
{
    if (!username)
    {
        username = [NSString stringWithString:[[self persistentData] getStringWithKey:@"Username"]];
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
    [[self persistentData] setString:password WithKey:@"Password"];
}

-(NSString *)password
{
    if (!password)
    {
        password = [NSString stringWithString:[[self persistentData] getStringWithKey:@"Password"]];
        if (!password)
        {
            [self setPassword:AMDefaultPassword];
        }
    }
    return password;
}

-(void)storeCredentials:(NSString *)newUsername password:(NSString *)newPassword
{
    NSString *pwHash = [NSString stringWithFormat:@"%@:%@:%@", newUsername, AMMusicServerPlistName, newPassword];
    
    [self setPassword:[AMJSONAPIData CalculateMD5:pwHash]];
    [self setUsername:newUsername];
}

-(void)setMaxSessions:(NSNumber *)value
{
    maxSessions = value;
    [[self persistentData] setNumber:maxSessions WithKey:@"MaxSessions"];
}

-(NSNumber *)maxSessions
{
    if (!maxSessions)
    {
        maxSessions = [[self persistentData] getNumberWithKey:@"MaxSessions"];
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
    [[self persistentData] setNumber:maxCachedTracks WithKey:@"MaxCachedTracks"];
}

-(NSNumber *)maxCachedTracks
{
    if (!maxCachedTracks)
    {
        maxCachedTracks = [[self persistentData] getNumberWithKey:@"MaxCachedTracks"];
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
    [[self persistentData] setNumber:useAlbumArt WithKey:@"UseAlbumArt"];
}

-(NSNumber *)useAlbumArt
{
    if (!useAlbumArt)
    {
        useAlbumArt = [[self persistentData] getNumberWithKey:@"UseAlbumArt"];
        if (!useAlbumArt)
        {
            [self setUseAlbumArt:[NSNumber numberWithInt:AMDefaultUseAlbumArt]];
        }
    }
    return useAlbumArt;
}

-(void)setLastFMSessionKey:(NSString *)value
{
    lastFMSessionKey = value;
    [[self persistentData] setString:lastFMSessionKey WithKey:@"LastFMSessionKey"];
}

-(NSString *)lastFMSessionKey
{
    if (!lastFMSessionKey)
    {
        lastFMSessionKey = [[self persistentData] getStringWithKey:@"LastFMSessionKey"];
        if (!lastFMSessionKey)
        {
            [self setLastFMSessionKey:@""];
        }
    }
    return lastFMSessionKey;
}

-(void)setLastFMUsername:(NSString *)value
{
    lastFMUsername = value;
    [[self persistentData] setString:lastFMUsername WithKey:@"LastFMUsername"];
}

-(NSString *)lastFMUsername
{
    if (!lastFMUsername)
    {
        lastFMUsername = [[self persistentData] getStringWithKey:@"LastFMUsername"];
        if (!lastFMUsername)
        {
            [self setLastFMUsername:@""];
        }
    }
    return lastFMUsername;
}

-(void)saveCachedTracks
{
    [[self persistentData] setArray:cachedTracks WithKey:@"CachedTracks"];
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
        cachedTracks = [NSMutableArray arrayWithArray:[[self persistentData] getArrayWithKey:@"CachedTracks"]];
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

-(int)logRequestFromIP:(NSString *)ipAddress
          inDictionary:(NSMutableDictionary *)dictionary
           withCounter:(int *)counter
                maxAge:(int)maxAge
{
    int rate;
    @synchronized(dictionary)
    {
        AMRequestHistory *recentRequest;
        int currentTime = (int)[[NSDate date] timeIntervalSince1970];
        
        if ([dictionary objectForKey:ipAddress])
        {
            recentRequest = [dictionary objectForKey:ipAddress];
            if (currentTime > recentRequest->lastInterval + 60)
            {
                recentRequest->lastInterval = currentTime;
                recentRequest->count = 1;
            }
            else
            {
                recentRequest->count++;
            }
        }
        else
        {
            recentRequest = [[AMRequestHistory alloc] init];
            recentRequest->lastInterval = currentTime;
            recentRequest->count = 1;
            [dictionary setValue:recentRequest forKey:ipAddress];
        }
        rate = recentRequest->count;
    }
    [self removeOldEntriesForRequestDictionary:dictionary withCounter:counter olderThan:maxAge];
    
    return rate;
}

-(void)removeOldEntriesForRequestDictionary:(NSMutableDictionary *)dictionary
                         withCounter:(int *)counter
                           olderThan:(int)interval
{
    int timeBeforeInterval = (int)[[NSDate date] timeIntervalSince1970] - interval;
    if (*counter < timeBeforeInterval)
    {
        @synchronized(dictionary)
        {
            [[dictionary copy] enumerateKeysAndObjectsUsingBlock: ^(id key, AMRequestHistory *recentRequest, BOOL *stop) {
                if (recentRequest->lastInterval < timeBeforeInterval)
                {
                    [dictionary removeObjectForKey:key];
                }
            }];
        }
        *counter = (int)[[NSDate date] timeIntervalSince1970];
    }
}

-(BOOL)doesRequestDictionaryContainIP:(NSString *)ipAddress
                         inDictionary:(NSMutableDictionary *)dictionary
                          withCounter:(int *)counter
                               maxAge:(int)maxAge
{
    @synchronized(dictionary)
    {
        [self removeOldEntriesForRequestDictionary:dictionary
                                       withCounter:counter
                                         olderThan:maxAge];
        
        return ([dictionary objectForKey:ipAddress] != nil);
    }
}

-(void)auditFailedAuthFromIP:(NSString *)ipAddress
{
    int rate = [self logRequestFromIP:ipAddress
                         inDictionary:[self authRequests]
                          withCounter:&(self->authRequestsCounter)
                               maxAge:REQUEST_BLACKLIST_AGE];
    if (rate > 2)
    {
        [self logRequestFromIP:ipAddress
                  inDictionary:[self ipBlackList]
                   withCounter:&(self->ipBlackListCounter)
                        maxAge:REQUEST_BLACKLIST_AGE];
    }
}

-(void)auditRequestFromIP:(NSString *)ipAddress
{
    int rate = [self logRequestFromIP:ipAddress
                         inDictionary:[self requests]
                          withCounter:&(self->requestsCounter)
                               maxAge:REQUEST_BLACKLIST_AGE];
    if (rate > 60)
    {
        [self logRequestFromIP:ipAddress
                  inDictionary:[self ipBlackList]
                   withCounter:&(self->ipBlackListCounter)
                        maxAge:REQUEST_BLACKLIST_AGE];
    }
}

-(BOOL)ipAddressIsBlackListed:(NSString *)ipAddress
{
    BOOL test = [self doesRequestDictionaryContainIP:ipAddress
                                   inDictionary:[self ipBlackList]
                                    withCounter:&(self->ipBlackListCounter)
                                         maxAge:REQUEST_BLACKLIST_AGE];
    return test;
}

@end