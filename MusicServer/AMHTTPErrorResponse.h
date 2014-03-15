//
//  AMHTTPErrorResponse.h
//  MusicServer
//
//  Created by Anthony Martin on 15/03/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaHTTPServer/HTTPResponse.h>

@interface AMHTTPErrorResponse : NSObject <HTTPResponse>
{
    NSInteger statusCode;
}

-(id) initWithCode:(NSNumber *)code;
-(NSInteger) status;

@end