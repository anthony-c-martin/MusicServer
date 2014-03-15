//
//  AMHTTPConnection.m
//  MusicServer
//
//  Created by Anthony Martin on 24/02/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import "AMHTTPConnection.h"
#import "AMJSONITunesResponder.h"
#import "AMMusicServerActiveData.h"
#import "AMHTTPAsyncJSONResponse.h"
#import "AMHTTPErrorResponse.h"
#import <CocoaHTTPServer/HTTPMessage.h>
#import <CocoaHTTPServer/HTTPAsyncFileResponse.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@implementation AMHTTPConnection

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
    if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/api"])
    {
        return requestContentLength < 2048;
    }
    
	return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
    if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/api"])
    {
        return YES;
    }
    
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    if ([[AMMusicServerActiveData sharedInstance] ipAddressIsBlackListed:[self connectedHost]])
    {
        return [[AMHTTPErrorResponse alloc] initWithCode:[NSNumber numberWithInt:400]];
    }
    
	if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/api"])
	{
        return [[AMHTTPAsyncJSONResponse alloc] initWithRequest:[request body]
                                                   JSONResponder:[AMJSONITunesResponder sharedInstance]
                                                     Connection:self];
	}
    
    if ([method isEqualToString:@"GET"])
    {
        NSURL *url = [NSURL URLWithString:path];
        if ([[url path] isEqualToString:@"/stream"])
        {
            NSString *queryString = [url query];
            NSArray *pairs = [queryString componentsSeparatedByString:@"&"];
            NSMutableDictionary *kvPairs = [NSMutableDictionary dictionary];
            for (NSString * pair in pairs)
            {
                NSArray * bits = [pair componentsSeparatedByString:@"="];
                NSString * key = [[bits objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString * value = [[bits objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [kvPairs setObject:value forKey:key];
            }
            
            BOOL authorised = NO;
            if ([kvPairs objectForKey:@"FileName"] && [kvPairs objectForKey:@"Session"] && [kvPairs objectForKey:@"APIKey"])
            {
                authorised = [[AMJSONITunesResponder sharedInstance] validateSession:[kvPairs objectForKey:@"Session"] APIKey:[kvPairs objectForKey:@"APIKey"]];
            }
            
            if (authorised)
            {
                NSURL *fileURL = [[AMMusicServerActiveData sharedInstance] getCachedTrackLocation:[kvPairs objectForKey:@"FileName"]];
                if (fileURL != nil)
                {
                    NSString *filePath = [fileURL path];
                    return [[HTTPAsyncFileResponse alloc] initWithFilePath:filePath forConnection:self];
                }
            }
            return [super httpResponseForMethod:method URI:path];
        }
        
        if ([[url path] isEqualToString:@"/"])
        {
            return [super httpResponseForMethod:method URI:@"/index.html"];
        }
        return [super httpResponseForMethod:method URI:path];
    }
    
    return [[AMHTTPErrorResponse alloc] initWithCode:[NSNumber numberWithInt:500]];
}

- (void)processBodyData:(NSData *)postDataChunk
{
	[request appendData:postDataChunk];
}

-(id)initWithAsyncSocket:(GCDAsyncSocket *)newSocket configuration:(HTTPConfig *)aConfig
{
    self = [super initWithAsyncSocket:newSocket configuration:aConfig];
    if (self)
    {
        [self setConnectedHost:[[newSocket connectedHost] copy]];
        [[AMMusicServerActiveData sharedInstance] auditRequestFromIP:[self connectedHost]];
    }
    return self;
}

@end