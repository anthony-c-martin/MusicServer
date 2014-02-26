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
@property (nonatomic, retain) NSNumber *useAlbumArt;

-(void)addCachedTrack:(NSString *)name;
-(void)removeCachedTrack:(NSString *)name;
-(NSURL *)getCachedTrackLocation:(NSString *)name;
-(NSURL *)getLocationForTrack:(NSString *)name;

@end