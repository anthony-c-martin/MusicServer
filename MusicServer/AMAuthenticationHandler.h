//
//  AMAuthenticationHandler.h
//  MusicServer
//
//  Created by Anthony Martin on 16/03/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMAPIAuthenticationDataResponder.h"

@class AMMusicServerActiveData;

@interface AMAuthenticationHandler : NSObject<AMAPIAuthenticationDataResponder>

@property (nonatomic, retain) NSMutableArray *activeTokens;
@property (nonatomic, retain) NSMutableDictionary *activeSessions;
@property (nonatomic, retain) AMMusicServerActiveData *activeData;

-(id) initWithActiveData:(AMMusicServerActiveData *)data;

@end