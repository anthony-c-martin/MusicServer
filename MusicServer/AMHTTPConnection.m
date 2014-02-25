//
//  AMHTTPConnection.m
//  MusicServer
//
//  Created by Anthony Martin on 24/02/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import "AMHTTPConnection.h"
#import "AMGlobalObjects.h"
#import "AMJSONListener.h"
#import <CocoaHTTPServer/HTTPMessage.h>
#import <CocoaHTTPServer/HTTPResponse.h>
#import <CocoaHTTPServer/HTTPDataResponse.h>
#import <CocoaHTTPServer/HTTPAsyncFileResponse.h>

@interface AMHTTPErrorResponse : NSObject <HTTPResponse>
{
    NSInteger statusCode;
}

-(id) initWithCode:(NSNumber *)code;
-(NSInteger) status;

@end

@implementation AMHTTPErrorResponse

-(id) initWithCode:(NSNumber *)code;
{
	if((self = [super init]))
	{
        statusCode = [code integerValue];
	}
	return self;
}

-(NSInteger) status
{
    return statusCode;
}

-(UInt64) contentLength
{
    return 0;
}

-(UInt64) offset
{
    return 0;
}

-(void) setOffset:(UInt64)offset
{
    
}

-(NSData *) readDataOfLength:(NSUInteger)length
{
    return nil;
}

-(BOOL) isDone
{
    return YES;
}

@end

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
	if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/api"])
	{
        NSData *postData = [request body];
        NSData *responseData = nil;
        NSNumber *responseCode = nil;
        
        BOOL success = [[AMGlobalObjects JSONListener] handleRequest:postData
                                                        responseData:&responseData
                                                        responseCode:&responseCode];
        
        if (success)
        {
            return [[HTTPDataResponse alloc] initWithData:responseData];
        }
        else
        {
            return [[AMHTTPErrorResponse alloc] initWithCode:responseCode];
        }
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
                authorised = [[AMGlobalObjects JSONListener] validateSession:[kvPairs objectForKey:@"Session"] APIKey:[kvPairs objectForKey:@"APIKey"]];
            }
            
            if (authorised)
            {
                NSString *filePath = [NSString stringWithFormat:@"%@%@", @"/Library/WebServer/AMMusicServer/", [kvPairs objectForKey:@"FileName"]];
                return [[HTTPAsyncFileResponse alloc] initWithFilePath:filePath forConnection:self];
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

@end