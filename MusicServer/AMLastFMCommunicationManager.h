//
//  AMLastFMCommunicationManager.h
//  MusicServer
//
//  Created by Anthony Martin on 01/04/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMAPILastFMResponder.h"
#import "AMScrobbleManagerDelegate.h"
#import <LastFMAPI/AMAuthRequest.h>
#import <LastFMAPI/AMTrackRequest.h>

@class AMMusicServerActiveData;
@class AMAPIHandlerITunes;
@class AMAPIITTrack;

@interface AMLastFMCommunicationManager : NSObject <AMTrackResponseDelegate, AMAuthResponseDelegate, AMAPILastFMResponder>

@property (nonatomic, retain) AMTrackRequest *trackRequest;
@property (nonatomic, retain) AMAuthRequest *authRequest;
@property (nonatomic, assign) id <AMScrobbleManagerDelegate> scrobblerDelegate;
@property (nonatomic, retain) NSMutableArray *responseQueue;
@property (nonatomic, retain) AMAuthResponse *tokenResponse;
@property (nonatomic, retain) AMAuthResponse *sessionResponse;
@property (nonatomic, retain) AMMusicServerActiveData *activeData;
@property (nonatomic, retain) AMAPIHandlerITunes *itunesHandler;
@property (nonatomic, retain) AMAPIITTrack *currentTrack;
@property (nonatomic, assign) NSInteger startTime;

-(id)initWithDelegate:(id <AMScrobbleManagerDelegate>)delegate
           activeData:(AMMusicServerActiveData *)data
        itunesHandler:(AMAPIHandlerITunes *)itHandler;

-(void)TrackResponse:(AMTrackResponse *)Response UpdateNowPlaying:(AMNowPlaying *)NowPlaying;
-(void)TrackResponse:(AMTrackResponse *)Response Scrobble:(AMScrobbles *)Scrobbles;
-(void)AuthResponse:(AMAuthResponse *)Response GetToken:(AMToken *)Token;
-(void)AuthResponse:(AMAuthResponse *)Response GetSession:(AMSession *)Session;
-(void)RequestNewSession;

+(AMLastFMCommunicationManager *)sharedInstance;
-(void)Response:(AMBaseResponse *)Response Error:(NSError *)Error;

@end