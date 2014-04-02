//
//  AMLastFMCommunicationManager.m
//  MusicServer
//
//  Created by Anthony Martin on 01/04/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import "AMLastFMCommunicationManager.h"
#import "AMLastFMAPISecrets.h"
#import "AMMusicServerActiveData.h"
#import "AMAPIDataResponder.h"
#import "AMScrobbleManagerDelegate.h"
#import <LastFMAPI/AMDefinitions.h>

@implementation AMLastFMCommunicationManager
@synthesize trackRequest;
@synthesize authRequest;
@synthesize scrobblerDelegate;
@synthesize dataResponder;
@synthesize responseQueue;
@synthesize nowPlayingResponse;
@synthesize tokenResponse;
@synthesize sessionResponse;
@synthesize activeData;
@synthesize currentTrack;

-(id) initWithActiveData:(AMMusicServerActiveData *)data
{
    self = [super init];
    if (self)
    {
        [self setTrackRequest:[[AMTrackRequest alloc] initWithURL:AM_LFM_API_URL Key:AM_LFM_API_KEY Secret:AM_LFM_API_SECRET]];
        [self setAuthRequest:[[AMAuthRequest alloc] initWithURL:AM_LFM_API_URL Key:AM_LFM_API_KEY Secret:AM_LFM_API_SECRET]];
        [self setResponseQueue:[[NSMutableArray alloc] init]];
        [self setTokenResponse:nil];
        [self setSessionResponse:nil];
        [self setActiveData: data];
    }
    return self;
}

-(id)initWithDelegate:(id <AMScrobbleManagerDelegate>)delegate
           activeData:(AMMusicServerActiveData *)data
        dataResponder:(id <AMAPIDataResponder>)responder;

{
    self = [self initWithActiveData:data];
    if (self)
    {
        [self setDataResponder:responder];
        [self setScrobblerDelegate:delegate];
    }
    return self;
}

-(void)RequestNewToken
{
    [self setTokenResponse:[[AMAuthResponse alloc] initWithDelegate:self]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self authRequest] GetToken:[self tokenResponse]];
    });
    
}

-(void)RequestNewSession
{
    [self setSessionResponse:[[AMAuthResponse alloc] initWithDelegate:self]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self authRequest] GetSession:[self sessionResponse]
                                 Token:[[self activeData] lastFMToken]];
    });
}

-(void)TrackResponse:(AMTrackResponse *)Response Scrobble:(AMScrobbles *)Scrobbles
{
    [[self responseQueue] removeObject:Response];
}

-(void)TrackResponse:(AMTrackResponse *)Response UpdateNowPlaying:(AMNowPlaying *)NowPlaying
{

}

-(void)AuthResponse:(AMAuthResponse *)Response GetToken:(AMToken *)Token
{
    if ([Token Token])
    {
        [[self activeData] setLastFMToken:[Token Token]];
        if ([[self scrobblerDelegate] respondsToSelector:@selector(requestTokenValidation:APIKey:)])
        {
            [[self scrobblerDelegate] requestTokenValidation:[Token Token] APIKey:AM_LFM_API_KEY];
        }
    }
    [self setTokenResponse:nil];
}

-(void)AuthResponse:(AMAuthResponse *)Response GetSession:(AMSession *)Session
{
    if ([Session Key] && [Session Name])
    {
        [[self activeData] setLastFMSessionKey:[Session Key]];
        [[self activeData] setLastFMUsername:[Session Name]];
        if ([[self scrobblerDelegate] respondsToSelector:@selector(newSessionCreated)])
        {
            [[self scrobblerDelegate] newSessionCreated];
        }
    }
    [self setSessionResponse:nil];
}

-(void)Response:(AMBaseResponse *)Response Error:(NSError *)Error
{
    if ([Error domain] == AM_ERRDOMAIN_LASTFMAPI)
    {
        if ([Response Method] == AM_MTHD_AUTH_GETSESSION
            || [Response Method] == AM_MTHD_AUTH_GETTOKEN)
        {
            if ([Error code] == AM_ERR_AUTHENTICATION_FAILED
                || [Error code] == AM_ERR_UNAUTHORISED_TOKEN)
            {
                [[self activeData] setLastFMToken:nil];
                [self RequestNewToken];
                return;
            }
        }
        else
        {
            if ([Error code] == AM_ERR_SERVICE_OFFLINE
                || [Error code] == AM_ERR_SERVICE_TEMPORARILY_UNAVAILABLE
                || [Error code] == AM_ERR_OPERATION_FAILED
                || [Error code] == AM_ERR_INVALID_METHOD_SIGNATURE)
            {
                return;
            }
            else if ([Error code] == AM_ERR_INVALID_SESSION_KEY)
            {
                [[self activeData] setLastFMSessionKey:nil];
                [self RequestNewSession];
                return;
            }
            else
            {
                if ([Response Method] == AM_MTHD_TRACK_SCROBBLE)
                {
                    [[self responseQueue] removeObject:Response];
                }
                else if ([Response Method] == AM_MTHD_TRACK_UPDATENOWPLAYING)
                {
                    
                }
                return;
            }
        }
    }
}

-(void)scrobbleTrackByID:(NSString *)request
{
    if (![[self activeData] lastFMUsername]) {
        return;
    }
    AMAPIITTrack *trackDetails;
    [[self dataResponder] getTrackByID:request Response:&trackDetails];
    
    if (trackDetails)
    {
        NSInteger timeStamp;
        if ([self currentTrack] && [[self currentTrack] ID] == [trackDetails ID]) {
            timeStamp = [self startTime];
        }
        else {
             timeStamp = [[NSDate date] timeIntervalSince1970];
        }
        
        AMTrackResponse *response = [[AMTrackResponse alloc] initWithDelegate:self];
        [[self responseQueue] addObject:response];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self trackRequest] Scrobble:response
                                   Artist:[[trackDetails Artist] Name]
                                    Track:[trackDetails Name]
                                Timestamp:[NSNumber numberWithInteger:timeStamp]
                                    Album:[[trackDetails Album] Name]
                                  Context:nil
                                 StreamId:nil
                             ChosenByUser:nil
                              TrackNumber:[trackDetails TrackNumber]
                                     MBID:nil
                              AlbumArtist:[[[trackDetails Album] Artist] Name]
                                 Duration:[trackDetails Duration]
                               SessionKey:[[self activeData] lastFMSessionKey]];
        });
    }
}

-(void)nowPlayingTrackByID:(NSString *)request
{
    if (![[self activeData] lastFMUsername]) {
        return;
    }
    AMAPIITTrack *trackDetails;
    [[self dataResponder] getTrackByID:request Response:&trackDetails];
    [self setCurrentTrack:trackDetails];
    
    if (trackDetails)
    {
        [self setStartTime:[[NSDate date] timeIntervalSince1970]];
        
        if ([self nowPlayingResponse]) {
            [self setNowPlayingResponse:nil];
        }
        [self setNowPlayingResponse:[[AMTrackResponse alloc] initWithDelegate:self]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self trackRequest] UpdateNowPlaying:[self nowPlayingResponse]
                                           Artist:[[trackDetails Artist] Name]
                                            Track:[trackDetails Name]
                                            Album:[[trackDetails Album] Name]
                                      TrackNumber:[trackDetails TrackNumber]
                                          Context:nil
                                             MBID:nil
                                         Duration:[trackDetails Duration]
                                      AlbumArtist:[[[trackDetails Album] Artist] Name]
                                       SessionKey:[[self activeData] lastFMSessionKey]];
        });
    }

}

@end