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

-(id) init
{
    self = [super init];
    if (self)
    {
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
                                                     [[AMMusicServerActiveData sharedInstance] username],
                                                     [[AMMusicServerActiveData sharedInstance] password],
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

@end
