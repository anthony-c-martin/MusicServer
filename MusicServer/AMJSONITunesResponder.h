//
//  AMJSONITunesResponder.h
//  MusicServer
//
//  Created by Anthony Martin on 02/03/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import "AMJSONResponder.h"

@class AMAPIHandlerITunes;

@interface AMJSONITunesResponder : AMJSONResponder

+(AMJSONITunesResponder *)sharedInstance;

@end