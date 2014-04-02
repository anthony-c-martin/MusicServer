//
//  AppDelegate.m
//  MusicServer
//
//  Created by Anthony Martin on 30/10/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import "AppDelegate.h"
#import "AMHTTPConnection.h"
#import "AMJSONResponder.h"
#import "AMAPIHandlerITunes.h"
#import "AMAudioConverter.h"
#import "AMHTTPMusicServer.h"


#import "AMLastFMCommunicationManager.h"
#import "AMJSONResponder.h"
#import "AMMusicServerActiveData.h"
#import "AMAuthenticationHandler.h"

@implementation AppDelegate
@synthesize activeData;
@synthesize itunesHandler;
@synthesize authHandler;
@synthesize lastFMHandler;
@synthesize responder;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setActiveData:[[AMMusicServerActiveData alloc] init]];
    [self setItunesHandler:[[AMAPIHandlerITunes alloc] initWithActiveData:[self activeData]]];
    [self setAuthHandler:[[AMAuthenticationHandler alloc] initWithActiveData:[self activeData]]];
    [self setLastFMHandler:[[AMLastFMCommunicationManager alloc] initWithDelegate:nil activeData:[self activeData] dataResponder:[self itunesHandler]]];
    [self setResponder:[[AMJSONResponder alloc] initWithDelegate:[self itunesHandler] authDelegate:[self authHandler] lastFMDelegate:[self lastFMHandler] activeData:[self activeData]]];
    
    [[self itunesHandler] loadLibrary];
    
    [self setServer:[[AMHTTPMusicServer alloc] init]];
    [[self Server] setType:@"_https._tcp"];
    [[self Server] setPort:12345];
    [[self Server] setConnectionClass:[AMHTTPConnection class]];
    [[self Server] setDocumentRoot:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"webroot"]];
    [[self Server] setResponder:[self responder]];
    [[self Server] start:nil];
}

-(IBAction)showPrefsWindow:(id)sender
{
    [[self prefsWindow] setResponder:[self responder]];
    [[self prefsWindow] loadSettings];
    [[self prefsWindow] makeKeyAndOrderFront:self];
}

@end