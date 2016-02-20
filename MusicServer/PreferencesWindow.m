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
#import "AMJSONResponder.h"

NSString *const API_LFM_TOKEN_REQUEST_URL = @"https://www.last.fm/api/auth/";

@implementation PreferencesWindow
@synthesize responder;

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
    AMMusicServerActiveData *activeData = [[self responder] activeData];
    [self setPwChanged:NO];
    [[self username] setStringValue:[activeData username]];
    [[self password] setStringValue:@"******"];
    [[self maxSessions] setIntegerValue:[[[[self responder] activeData] maxSessions] integerValue]];
    [[self maxCachedTracks] setIntegerValue:[[activeData maxCachedTracks] integerValue]];
    [[self lastFMUsername] setStringValue:[activeData lastFMUsername]];
    [[self currentSesssions] setIntegerValue:[[self responder] sessionCount]];
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
    AMMusicServerActiveData *activeData = [[self responder] activeData];
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
    [[self responder] clearSessions];
    [self loadSettings];
}

-(IBAction)addLastFMButtonPressed:(id)sender
{
    AMMusicServerActiveData *activeData = [[self responder] activeData];
    [activeData setLastFMSessionKey:@""];
    [activeData setLastFMUsername:@""];
    [self loadSettings];
    AMLastFMCommunicationManager *lastFMManager = [[AMLastFMCommunicationManager alloc]
                                                   initWithDelegate:self
                                                   activeData:[[self responder] activeData]
                                                   dataResponder:[[self responder] delegate]];
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