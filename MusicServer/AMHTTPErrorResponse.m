//
//  AMHTTPErrorResponse.m
//  MusicServer
//
//  Created by Anthony Martin on 15/03/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import "AMHTTPErrorResponse.h"

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