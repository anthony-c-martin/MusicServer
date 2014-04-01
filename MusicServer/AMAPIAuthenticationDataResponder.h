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

-(BOOL) getSession:(AMAPIGetSessionRequest *)request
          response:(AMAPIGetSessionResponse **)response;

-(BOOL) getToken:(AMAPIGetTokenRequest *)request
        response:(AMAPIGetTokenResponse **)response;

-(BOOL) validateSession:(NSString *)Session;

@end