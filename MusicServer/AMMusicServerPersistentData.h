//
//  AMMusicServerPersistentData.h
//  MusicServer
//
//  Created by Anthony Martin on 25/02/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import "AMPersistentData.h"

@interface AMMusicServerPersistentData : AMPersistentData

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *apiKey;
@property (nonatomic, retain) NSNumber *maxSessions;
@property (nonatomic, retain) NSNumber *maxCachedTracks;

-(void)addCachedTrack:(NSString *)name AtLocation:(NSURL *)location;
-(NSURL *)getCachedTrackLocation:(NSString *)name;

@end