//
//  AMMusicServerActiveData.h
//  MusicServer
//
//  Created by Anthony Martin on 25/02/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import "AMPersistentData.h"

@interface AMMusicServerActiveData : AMPersistentData

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *apiKey;
@property (nonatomic, retain) NSNumber *maxSessions;
@property (nonatomic, retain) NSNumber *maxCachedTracks;
@property (nonatomic, retain) NSNumber *useAlbumArt;

+(AMMusicServerActiveData *)sharedInstance;
-(void)addCachedTrack:(NSString *)name;
-(void)removeCachedTrack:(NSString *)name;
-(NSURL *)getCachedTrackLocation:(NSString *)name;
-(NSURL *)getLocationForTrack:(NSString *)name;
-(void)auditFailedAuthFromIP:(NSString *)ipAddress;
-(void)auditRequestFromIP:(NSString *)ipAddress;
-(BOOL)ipAddressIsBlackListed:(NSString *)ipAddress;

@end