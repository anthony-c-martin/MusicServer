//
//  PreferencesWindow.h
//  MusicServer
//
//  Created by Anthony Martin on 31/03/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMScrobbleManagerDelegate.h"

@class AMJSONResponder;

@interface PreferencesWindow : NSWindow<NSTextFieldDelegate, AMScrobbleManagerDelegate>

@property (assign) IBOutlet NSTextField *username;
@property (assign) IBOutlet NSTextField *password;
@property (assign) IBOutlet NSTextField *maxSessions;
@property (assign) IBOutlet NSTextField *maxCachedTracks;
@property (assign) IBOutlet NSTextField *currentSesssions;

@property (assign) IBOutlet NSTextField *lastFMUsername;
@property (assign) IBOutlet NSTextField *lastFMActive;

@property (nonatomic, assign) Boolean pwChanged;
@property (nonatomic, retain) AMJSONResponder *responder;

-(void)loadSettings;
-(IBAction)saveButtonPressed:(id)sender;
-(IBAction)clearSessionsButtonPressed:(id)sender;
-(IBAction)addLastFMButtonPressed:(id)sender;
-(void)controlTextDidChange:(NSNotification *)aNotification;
-(void)requestTokenValidation:(NSString *)Token
                       APIKey:(NSString *)APIKey;
-(void)newSessionCreated;

@end

@interface OnlyIntegerValueFormatter : NSNumberFormatter

@end