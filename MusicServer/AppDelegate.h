//
//  AppDelegate.h
//  MusicServer
//
//  Created by Anthony Martin on 30/10/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesWindow.h"
#import "AMPercentageValueUpdater.h"

@class AMMusicServerActiveData;
@class AMAPIHandlerITunes;
@class AMAuthenticationHandler;
@class AMLastFMCommunicationManager;
@class AMJSONResponder;
@class AMHTTPMusicServer;

@interface AppDelegate : NSObject <NSApplicationDelegate, AMPercentageValueUpdater>

@property (assign) IBOutlet PreferencesWindow *prefsWindow;
@property (nonatomic, retain) AMHTTPMusicServer *Server;
@property (nonatomic, retain) AMMusicServerActiveData *activeData;
@property (nonatomic, retain) AMAPIHandlerITunes *itunesHandler;
@property (nonatomic, retain) AMAuthenticationHandler *authHandler;
@property (nonatomic, retain) AMLastFMCommunicationManager *lastFMHandler;
@property (nonatomic, retain) AMJSONResponder *responder;

-(IBAction)showPrefsWindow:(id)sender;

@end