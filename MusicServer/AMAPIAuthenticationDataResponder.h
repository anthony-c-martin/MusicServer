//
//  AMAPIAuthenticationDataResponder.h
//  MusicServer
//
//  Created by Anthony Martin on 15/03/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMJSONAPIDataObjects.h"

@protocol AMAPIAuthenticationDataResponder <NSObject>

-(BOOL) getAuthentication:(NSString **)authentication
                    token:(NSString **)token;

-(BOOL) getSession:(AMAPIGetSessionRequest *)request
          response:(AMAPIGetSessionResponse **)response;

-(BOOL) getToken:(AMAPIBlankRequest *)request
        response:(AMAPIGetTokenResponse **)response;

-(BOOL) validateSession:(NSString *)Session;
-(NSString *)secretForSession:(NSString *)Session;

-(void) clearSessions;
-(NSInteger) sessionCount;

@end