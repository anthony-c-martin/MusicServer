//
//  AMJSONListener.h
//  MusicServer
//
//  Created by Anthony Martin on 30/10/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMAPIDataResponder;
@protocol AMAPIAuthenticationDataResponder;

@interface AMJSONListener : NSObject

@property (nonatomic, retain) id<AMAPIDataResponder> Delegate;
@property (nonatomic, retain) id<AMAPIAuthenticationDataResponder> AuthDelegate;
@property (nonatomic, retain) NSMutableDictionary *activeTokens;
@property (nonatomic, retain) NSMutableDictionary *activeSessions;

-(id) initOnPort:(NSUInteger)port
    withDelegate:(id<AMAPIDataResponder>)delegate;

-(BOOL) handleRequest:(NSData *)data
         responseData:(NSData **)responseData
         responseCode:(NSNumber **)responseCode;

-(BOOL) validateSession:(NSString *)Session
                 APIKey:(NSString *)APIKey;

-(void) dealloc;

@end