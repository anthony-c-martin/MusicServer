//
//  AMJSONResponder.h
//  MusicServer
//
//  Created by Anthony Martin on 30/10/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMAPIDataResponder;
@protocol AMAPIAuthenticationDataResponder;

@interface AMJSONResponder : NSObject

@property (nonatomic, retain) id<AMAPIDataResponder> delegate;
@property (nonatomic, retain) id<AMAPIAuthenticationDataResponder> authDelegate;

-(id) initWithDelegate:(id<AMAPIDataResponder>)delegate
          authDelegate:(id<AMAPIAuthenticationDataResponder>)authDelegate;

-(BOOL) handleRequest:(NSData *)data
         responseData:(NSData **)responseData
         responseCode:(NSNumber **)responseCode
        connectedHost:(NSString *)ipAddress;

-(BOOL) validateSession:(NSString *)Session
                 APIKey:(NSString *)APIKey;

-(void) dealloc;

@end