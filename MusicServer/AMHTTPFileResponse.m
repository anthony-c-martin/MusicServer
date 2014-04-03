//
//  AMHTTPFileResponse.m
//  MusicServer
//
//  Created by Anthony Martin on 03/04/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import "AMHTTPFileResponse.h"

@implementation AMHTTPFileResponse
@synthesize contentType;

- (id)initWithFilePath:(NSString *)fpath forConnection:(HTTPConnection *)parent
{
    self = [super initWithFilePath:fpath forConnection:parent];
    if (self)
    {
        NSString *extension = [fpath pathExtension];
        if ([extension isEqualToString:@"html"]) {
            contentType = @"text/html";
        }
        else if ([extension isEqualToString:@"css"]) {
            contentType = @"text/css";
        }
        else if ([extension isEqualToString:@"js"]) {
            contentType = @"application/javascript";
        }
        else if ([extension isEqualToString:@"svg"]) {
            contentType = @"image/svg+xml";
        }
        else {
            contentType = @"text/plain";
        }
    }
    return self;
}

-(NSDictionary *)httpHeaders
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"max-age=86400, must-revalidate", @"Cache-Control",
            contentType, @"Content-Type",
            nil];
}

@end