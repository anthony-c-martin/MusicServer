//
//  PreferencesWindow.m
//  MusicServer
//
//  Created by Anthony Martin on 31/03/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import "PreferencesWindow.h"
#import "AMMusicServerActiveData.h"
#import "AMLastFMCommunicationManager.h"
#import "AMAPIHandlerITunes.h"
#import "AMJSONITunesResponder.h"

NSString *const API_LFM_TOKEN_REQUEST_URL = @"http://www.last.fm/api/auth/";

@implementation PreferencesWindow

-(void)controlTextDidChange:(NSNotification *)aNotification
{
    if ([aNotification object] == [self username])
    {
        if (![self pwChanged])
        {
            [[self password] setStringValue:@""];
            [self setPwChanged:YES];
        }
    }
    else if ([aNotification object] == [self password])
    {
        [self setPwChanged:YES];
    }
}

-(void)loadSettings
{
    AMMusicServerActiveData *activeData = [AMMusicServerActiveData sharedInstance];
    AMJSONITunesResponder *jsonResponder = [AMJSONITunesResponder sharedInstance];
    [self setPwChanged:NO];
    [[self username] setStringValue:[activeData username]];
    [[self password] setStringValue:@"******"];
    [[self maxSessions] setIntegerValue:[[activeData maxSessions] integerValue]];
    [[self maxCachedTracks] setIntegerValue:[[activeData maxCachedTracks] integerValue]];
    [[self lastFMUsername] setStringValue:[activeData lastFMUsername]];
    [[self currentSesssions] setIntegerValue:[jsonResponder sessionCount]];
    if ([[activeData lastFMSessionKey] length] > 0)
    {
        [[self lastFMActive] setStringValue:@"Active"];
    }
    else
    {
        [[self lastFMActive] setStringValue:@"Inactive"];
    }
}

-(IBAction)saveButtonPressed:(id)sender
{
    AMMusicServerActiveData *activeData = [AMMusicServerActiveData sharedInstance];
    if ([self pwChanged])
    {
        [activeData storeCredentials:[[self username] stringValue] password:[[self password] stringValue]];
    }
    [activeData setMaxSessions:[NSNumber numberWithInteger:[[self maxSessions] integerValue]]];
    [activeData setMaxCachedTracks:[NSNumber numberWithInteger:[[self maxCachedTracks] integerValue]]];
    [self close];
}

-(IBAction)clearSessionsButtonPressed:(id)sender
{
    AMJSONITunesResponder *jsonResponder = [AMJSONITunesResponder sharedInstance];
    [jsonResponder clearSessions];
    [self loadSettings];
}

-(IBAction)addLastFMButtonPressed:(id)sender
{
    AMMusicServerActiveData *activeData = [AMMusicServerActiveData sharedInstance];
    [activeData setLastFMSessionKey:@""];
    [activeData setLastFMUsername:@""];
    [self loadSettings];
    AMLastFMCommunicationManager *lastFMManager = [[AMLastFMCommunicationManager alloc]
                                                   initWithDelegate:self
                                                   activeData:[AMMusicServerActiveData sharedInstance]
                                                   itunesHandler:[AMAPIHandlerITunes sharedInstance]];
    [lastFMManager RequestNewSession];
}

-(void)requestTokenValidation:(NSString *)Token
                       APIKey:(NSString *)APIKey
{
    NSString *validationURL = [NSString stringWithFormat:@"%@?api_key=%@&token=%@",
                               API_LFM_TOKEN_REQUEST_URL, APIKey, Token];
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:validationURL]];
}

-(void)newSessionCreated
{
    [self loadSettings];
}

@end

@implementation OnlyIntegerValueFormatter

- (BOOL)isPartialStringValid:(NSString*)partialString newEditingString:(NSString**)newString errorDescription:(NSString**)error
{
    if([partialString length] == 0) {
        return YES;
    }
    
    NSScanner* scanner = [NSScanner scannerWithString:partialString];
    
    if(!([scanner scanInt:0] && [scanner isAtEnd])) {
        NSBeep();
        return NO;
    }
    
    return YES;
}

@end