//
//  AMHTTPAsyncJSONResponse.h
//  MusicServer
//
//  Created by Anthony Martin on 01/03/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoaHTTPServer/HTTPResponse.h>

@class AMJSONResponder;
@class HTTPConnection;

@interface AMHTTPAsyncJSONResponse : NSObject <HTTPResponse>
{
	dispatch_queue_t requestQueue;
	HTTPConnection *connection;
    BOOL isSuccessful;
    BOOL isDataLoaded;
	UInt64 responseOffset;
    NSData *responseData;
    NSNumber *responseCode;
}

-(id)initWithRequest:(NSData *)request
       JSONResponder:(AMJSONResponder *)responder
          Connection:(HTTPConnection *)parent;

@end