//
//  AMAuthenticationHandler.h
//  MusicServer
//
//  Created by Anthony Martin on 16/03/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMAPIAuthenticationDataResponder.h"

@interface AMAuthenticationHandler : NSObject<AMAPIAuthenticationDataResponder>

@property (nonatomic, retain) NSMutableDictionary *activeTokens;
@property (nonatomic, retain) NSMutableDictionary *activeSessions;

@end