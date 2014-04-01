//
//  AMAPILastFMResponder.h
//  MusicServer
//
//  Created by Anthony Martin on 01/04/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMAPILastFMResponder <NSObject>

-(BOOL) scrobbleTrackByID:(NSString *)request;

-(BOOL) nowPlayingTrackByID:(NSString *)request;

@end