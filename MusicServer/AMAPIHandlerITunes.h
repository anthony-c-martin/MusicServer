//
//  AMAPIHandlerITunes.h
//  MusicServer
//
//  Created by Anthony Martin on 02/11/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMAPIDataResponder.h"

@interface AMAPIHandlerITunes : NSObject<AMAPIDataResponder>

@property (nonatomic, retain) NSSet *Tracks;
@property (nonatomic, retain) NSSet *Artists;
@property (nonatomic, retain) NSSet *Albums;

-(id) init;
-(BOOL) loadLibrary;
+(AMAPIHandlerITunes *)sharedInstance;

@end