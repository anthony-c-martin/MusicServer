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

-(BOOL) getSession:(AMAPIGetSessionRequest *)request
          response:(AMAPIGetSessionResponse **)response
{
    @synchronized(self)
    {
        [self removeStaleTokens];
        
        *response = [[AMAPIGetSessionResponse alloc] init];
        __block BOOL found = NO;
        [[self activeTokens] enumerateObjectsUsingBlock:^(NSArray *token, NSUInteger idx, BOOL *stop) {
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
        
        NSString *MD5 = [AMJSONAPIData CalculateMD5:[NSString stringWithFormat:@"%@:%@:%@:%@",
                                                     [request Token],
                                                     [[self activeData] username],
                                                     [[self activeData] password],
                                                     [request Token]]];
        
        if ([MD5 isEqualTo:[request Authentication]])
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
    @synchronized(self)
    {
        [self removeStaleTokens];
        
        *response = [[AMAPIGetTokenResponse alloc] init];
        [*response setToken:[AMJSONAPIData randomAlphanumericString]];
        
        NSDate *expiry = [[NSDate date] dateByAddingTimeInterval:3600];
        [[self activeTokens] addObject:[NSArray arrayWithObjects:[*response Token], expiry, nil]];
        return YES;
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
