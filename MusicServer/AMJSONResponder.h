//
//  AMJSONResponder.h
//  MusicServer
//
//  Created by Anthony Martin on 30/10/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMLastFMCommunicationManager.h"

@protocol AMAPIDataResponder;
@protocol AMAPIAuthenticationDataResponder;
@class AMMusicServerActiveData;

@interface AMJSONResponder : NSObject

@property (nonatomic, retain) id<AMAPIDataResponder> delegate;
@property (nonatomic, retain) id<AMAPIAuthenticationDataResponder> authDelegate;
@property (nonatomic, retain) AMLastFMCommunicationManager *lastFMDelegate;
@property (nonatomic, retain) AMMusicServerActiveData *activeData;

-(id) initWithDelegate:(id<AMAPIDataResponder>)delegate
          authDelegate:(id<AMAPIAuthenticationDataResponder>)authDelegate
        lastFMDelegate:(AMLastFMCommunicationManager *)lastFMDelegate
            activeData:(AMMusicServerActiveData *)data;

-(BOOL) handleRequest:(NSData *)data
         responseData:(NSData **)responseData
         responseCode:(NSNumber **)responseCode
        connectedHost:(NSString *)ipAddress;

-(BOOL) validateSession:(NSString *)Session;
-(NSString *)secretForSession:(NSString *)Session;

-(void) clearSessions;
-(NSInteger) sessionCount;

-(void) dealloc;

@end