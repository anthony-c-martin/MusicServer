//
//  AMAuthenticationHandler.m
//  MusicServer
//
//  Created by Anthony Martin on 16/03/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import "AMAuthenticationHandler.h"
#import "AMJSONAPIDataObjects.h"
#import "AMAPIDataResponder.h"
#import "AMMusicServerActiveData.h"

@implementation AMAuthenticationHandler

-(id) initWithActiveData:(AMMusicServerActiveData *)data
{
    self = [super init];
    if (self)
    {
        [self setActiveSessions:[[NSMutableDictionary alloc] init]];
        [self setActiveTokens:[[NSMutableArray alloc] init]];
        [self setActiveData:data];
    }
    return self;
}

-(BOOL) getAuthentication:(NSString **)authentication
                    token:(NSString **)token
{
    @synchronized(self)
    {
        *token = [self generateTokenWithAccessKey:YES accessKey:authentication];
        
        return YES;
    }
}

-(NSString *) getAuthentication:(NSString *)token
{
    return [AMJSONAPIData CalculateMD5:[NSString stringWithFormat:@"%@:%@:%@:%@",
                                                 token,
                                                 [[self activeData] username],
                                                 [[self activeData] password],
                                                 token]];
}

-(BOOL) getSession:(AMAPIGetSessionRequest *)request
          response:(AMAPIGetSessionResponse **)response
{
    @synchronized(self)
    {
        [self removeStaleTokens];
        
        *response = [[AMAPIGetSessionResponse alloc] init];
        __block BOOL accessKeyMatches = NO;
        __block BOOL tokenFound = NO;
        [[self activeTokens] enumerateObjectsUsingBlock:^(NSArray *token, NSUInteger idx, BOOL *stop) {
            if ([[request Token] isEqualTo:[token objectAtIndex:0]])
            {
                tokenFound = YES;
                *stop = YES;
                accessKeyMatches = ([token count] > 2) && [[request Authentication] isEqualTo:[token objectAtIndex:2]];
            }
        }];
        if (!tokenFound)
        {
            return NO;
        }
        
        if (accessKeyMatches || [[self getAuthentication:[request Token]] isEqualTo:[request Authentication]])
        {
            [*response setSession:[AMJSONAPIData randomAlphanumericString]];
            [*response setSecret:[AMJSONAPIData randomAlphanumericString]];
            if ([[self activeSessions] count] > 0 && [[self activeSessions] count] == [[[self activeData] maxSessions] integerValue]) {
                [[self activeSessions] removeObjectForKey:[[[self activeSessions] allKeys] objectAtIndex:0]];
            }
            [[self activeSessions] setObject:[*response Secret] forKey:[*response Session]];
            return YES;
        }
        return NO;
    }
}

-(BOOL) validateSession:(NSString *)Session;
{
    @synchronized(self)
    {
        return ([[self activeSessions] objectForKey:Session] != nil);
    }
}

-(BOOL) getToken:(AMAPIBlankRequest *)request
        response:(AMAPIGetTokenResponse **)response
{
    *response = [[AMAPIGetTokenResponse alloc] init];
    [*response setToken:[self generateToken]];

    return YES;
}

-(NSString *) generateToken
{
    NSString *accessKey;
    return [self generateTokenWithAccessKey:NO accessKey:&accessKey];
}

-(NSString *) generateTokenWithAccessKey:(BOOL)withAccessKey
                               accessKey:(NSString **)accessKey
{
    @synchronized(self)
    {
        [self removeStaleTokens];
        
        NSString *token = [AMJSONAPIData randomAlphanumericString];
        NSDate *expiry = [[NSDate date] dateByAddingTimeInterval:3600];
        *accessKey = withAccessKey ? [AMJSONAPIData randomAlphanumericString] : nil;
        [[self activeTokens] addObject:[NSArray arrayWithObjects:token, expiry, *accessKey, nil]];

        return token;
    }
}

-(void) removeStaleTokens
{
    @synchronized(self)
    {
        [[self activeTokens] enumerateObjectsUsingBlock:^(NSArray *token, NSUInteger idx, BOOL *stop) {
            NSDate *expiryDate = [token objectAtIndex:1];
            if ([expiryDate compare:[NSDate date]] == NSOrderedAscending)
            {
                [[self activeTokens] removeObjectAtIndex:idx];
            }
        }];
    }
}

-(void) clearSessions
{
    @synchronized(self)
    {
        [[self activeSessions] removeAllObjects];
        [[self activeTokens] removeAllObjects];
    }
}

-(NSInteger) sessionCount
{
    return [[self activeSessions] count];
}

-(NSString *)secretForSession:(NSString *)Session
{
    @synchronized(self)
    {
        NSString *Secret = [[self activeSessions] objectForKey:Session];
        return Secret;
    }
}

@end
