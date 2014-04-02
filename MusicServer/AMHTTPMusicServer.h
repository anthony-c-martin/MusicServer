//
//  AMHTTPMusicServer.h
//  MusicServer
//
//  Created by Anthony Martin on 02/04/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaHTTPServer/HTTPServer.h>

@class AMJSONResponder;

@interface AMHTTPMusicServer : HTTPServer

@property (nonatomic, retain) AMJSONResponder *responder;

@end