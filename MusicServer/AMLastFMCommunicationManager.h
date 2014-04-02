//
//  AMLastFMCommunicationManager.h
//  MusicServer
//
//  Created by Anthony Martin on 01/04/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LastFMAPI/AMAuthRequest.h>
#import <LastFMAPI/AMTrackRequest.h>

@class AMMusicServerActiveData;
@class AMAPIITTrack;
@protocol AMAPIDataResponder;
@protocol AMScrobbleManagerDelegate;

@interface AMLastFMCommunicationManager : NSObject <AMTrackResponseDelegate, AMAuthResponseDelegate>

@property (nonatomic, retain) AMTrackRequest *trackRequest; 
@property (nonatomic, retain) AMAuthRequest *authRequest;
@property (nonatomic, retain) id <AMScrobbleManagerDelegate> scrobblerDelegate;
@property (nonatomic, retain) id <AMAPIDataResponder> dataResponder;
@property (nonatomic, retain) NSMutableArray *responseQueue;
@property (nonatomic, retain) AMTrackResponse *nowPlayingResponse;
@property (nonatomic, retain) AMAuthResponse *tokenResponse;
@property (nonatomic, retain) AMAuthResponse *sessionResponse;
@property (nonatomic, retain) AMMusicServerActiveData *activeData;
@property (nonatomic, retain) AMAPIITTrack *currentTrack;
@property (nonatomic, assign) NSInteger startTime;

-(id)initWithDelegate:(id <AMScrobbleManagerDelegate>)delegate
           activeData:(AMMusicServerActiveData *)data
        dataResponder:(id <AMAPIDataResponder>)dataResponder;

-(void)TrackResponse:(AMTrackResponse *)Response UpdateNowPlaying:(AMNowPlaying *)NowPlaying;
-(void)TrackResponse:(AMTrackResponse *)Response Scrobble:(AMScrobbles *)Scrobbles;
-(void)AuthResponse:(AMAuthResponse *)Response GetToken:(AMToken *)Token;
-(void)AuthResponse:(AMAuthResponse *)Response GetSession:(AMSession *)Session;

-(void)scrobbleTrackByID:(NSString *)request;
-(void)nowPlayingTrackByID:(NSString *)request;
-(void)RequestNewSession;

-(void)Response:(AMBaseResponse *)Response Error:(NSError *)Error;

@end