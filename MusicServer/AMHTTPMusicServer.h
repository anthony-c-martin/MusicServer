//
//  AMHTTPMusicServer.h
//  MusicServer
//
//  Created by Anthony Martin on 02/04/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMJSONResponder;

@interface AMHTTPMusicServer : NSObject

@property (nonatomic, retain) AMJSONResponder *responder;

@property (nonatomic, strong) dispatch_queue_t requestQueue;

-(id)initWithResponder:(AMJSONResponder *)jsonResponder;

-(void)start;

-(void)stop;

@end