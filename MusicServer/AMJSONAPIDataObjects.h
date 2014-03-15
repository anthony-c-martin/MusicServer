//
//  AMJSONAPIDataObjects.h
//  MusicServer
//
//  Created by Anthony Martin on 30/10/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "./AMJSONAPIData.h"

@class AMAPIITTrack;
@class AMAPIITAlbum;
@class AMAPIITArtist;

@interface AMAPIDataRequest : AMJSONAPIData
@property (nonatomic, retain) NSNumber *Start;
@property (nonatomic, retain) NSNumber *Limit;
@end

@interface AMAPIDataIDRequest : AMAPIDataRequest
@property (nonatomic, retain) NSNumber *ID;
@end

@interface AMAPIDataStringRequest : AMAPIDataRequest
@property (nonatomic, retain) NSString *String;
@end

@interface AMAPIGetTokenRequest : AMJSONAPIData
@property (nonatomic, retain) NSString *APIKey;
@end

@interface AMAPIGetSessionRequest : AMJSONAPIData
@property (nonatomic, retain) NSString *Authentication;
@property (nonatomic, retain) NSString *APIKey;
@property (nonatomic, retain) NSString *Token;
@end

@interface AMAPIGetTokenResponse : AMJSONAPIData
@property (nonatomic, retain) NSString *Token;
@end

@interface AMAPIGetSessionResponse : AMJSONAPIData
@property (nonatomic, retain) NSString *Session;
@end

@interface AMAPIConvertTrackResponse : AMJSONAPIData
@property (nonatomic, retain) NSString *Result;
@property (nonatomic, retain) NSString *FileName;
@end

@interface AMAPIITTrack : AMJSONAPIData
@property (nonatomic, retain) NSString *ID;
@property (nonatomic, retain) NSString *Name;
@property (nonatomic, retain) NSString *Location;
@property (nonatomic, retain) NSNumber *TrackNumber;
@property (nonatomic, retain) NSNumber *DiscNumber;
@property (nonatomic, retain) AMAPIITArtist *Artist;
@property (nonatomic, retain) AMAPIITAlbum *Album;
@end

@interface AMAPIITAlbum : AMJSONAPIData
@property (nonatomic, retain) NSNumber *ID;
@property (nonatomic, retain) NSString *Name;
@property (nonatomic, retain) AMAPIITArtist *Artist;
@property (nonatomic, retain) NSMutableSet *TrackSet;
@property (nonatomic, retain) NSArray *AMAPIITTrackArray;
@property (nonatomic, retain) NSString *Artwork;
@end

@interface AMAPIITArtist : AMJSONAPIData
@property (nonatomic, retain) NSNumber *ID;
@property (nonatomic, retain) NSString *Name;
@property (nonatomic, retain) NSMutableSet *AlbumSet;
@property (nonatomic, retain) NSMutableSet *TrackSet;
@property (nonatomic, retain) NSArray *AMAPIITAlbumArray;
@property (nonatomic, retain) NSArray *AMAPIITTrackArray;
@end

@interface AMAPIITTracks : AMJSONAPIData
@property (nonatomic, retain) NSArray *AMAPIITTrackArray;
@end

@interface AMAPIITAlbums : AMJSONAPIData
@property (nonatomic, retain) NSArray *AMAPIITAlbumArray;
@end

@interface AMAPIITArtists : AMJSONAPIData
@property (nonatomic, retain) NSArray *AMAPIITArtistArray;
@end