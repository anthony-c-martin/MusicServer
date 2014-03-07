//
//  AMHTTPAsyncJSONResponse.m
//  MusicServer
//
//  Created by Anthony Martin on 01/03/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import "AMHTTPAsyncJSONResponse.h"
#import "AMJSONResponder.h"
#import "AMHTTPConnection.h"

@implementation AMHTTPAsyncJSONResponse

-(id)initWithRequest:(NSData *)request
       JSONResponder:(AMJSONResponder *)responder
          Connection:(AMHTTPConnection *)parent
{
    self = [super init];
    if (self)
    {
        connection = parent;
        requestQueue = dispatch_queue_create("AMHTTPAsyncJSONResponse", NULL);
        isCompleted = NO;
        isSuccessful = NO;
        responseOffset = 0;
        responseData = [[NSData alloc] init];
        responseCode = [[NSNumber alloc] init];
        
        dispatch_async(requestQueue, ^{
            NSData *data = responseData;
            NSNumber *code = responseCode;
            
            isSuccessful = [responder handleRequest:request
                                      responseData:&data
                                      responseCode:&code
                                      connectedHost:[parent connectedHost]];
            
            isCompleted = YES;
            responseData = data;
            responseCode = code;
            [connection responseHasAvailableData:self];
        });
    }
    return self;
}

-(UInt64)contentLength
{
    return (isSuccessful) ? [responseData length] : 0;
}

-(UInt64)offset
{
    return responseOffset;
}

-(void)setOffset:(UInt64)offset
{
    responseOffset = offset;
}

-(NSData *)readDataOfLength:(NSUInteger)lengthParameter
{
	if (isSuccessful)
	{
		NSUInteger remaining = [responseData length] - responseOffset;
        NSUInteger length = lengthParameter < remaining ? lengthParameter : remaining;
        
        void *bytes = (void *)([responseData bytes] + responseOffset);
        responseOffset += length;
		
		return [NSData dataWithBytesNoCopy:bytes length:length freeWhenDone:NO];
	}
    
    return nil;
}

-(BOOL)isDone
{
    return isCompleted;
}

-(BOOL)delayResponseHeaders
{
    return !isCompleted;
}

-(NSInteger)status
{
    if (responseCode)
    {
        return [responseCode integerValue];
    }
    
    return 500;
}

- (void)connectionDidClose
{
    dispatch_sync(requestQueue, ^{
        connection = nil;
    });
}

@end