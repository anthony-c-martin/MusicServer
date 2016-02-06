//
//  AppDelegate.m
//  MusicServer
//
//  Created by Anthony Martin on 30/10/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import "AppDelegate.h"
#import "AMJSONResponder.h"
#import "AMAPIHandlerITunes.h"
#import "AMAudioConverter.h"
#import "AMHTTPMusicServer.h"

#import "AMLastFMCommunicationManager.h"
#import "AMJSONResponder.h"
#import "AMMusicServerActiveData.h"
#import "AMAuthenticationHandler.h"

@implementation AppDelegate
{
    Boolean scanInProgress;
}
@synthesize activeData;
@synthesize itunesHandler;
@synthesize authHandler;
@synthesize lastFMHandler;
@synthesize responder;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self createStatusItem];
    [self setActiveData:[[AMMusicServerActiveData alloc] init]];
    [self setItunesHandler:[[AMAPIHandlerITunes alloc] initWithActiveData:[self activeData] valueUpdater:self]];
    [self setAuthHandler:[[AMAuthenticationHandler alloc] initWithActiveData:[self activeData]]];
    [self setLastFMHandler:[[AMLastFMCommunicationManager alloc] initWithDelegate:nil activeData:[self activeData] dataResponder:[self itunesHandler]]];
    [self setResponder:[[AMJSONResponder alloc] initWithDelegate:[self itunesHandler] authDelegate:[self authHandler] lastFMDelegate:[self lastFMHandler] activeData:[self activeData]]];
    [self setServer:[[AMHTTPMusicServer alloc] initWithResponder:responder]];
    [self initializeLibrary];
}

-(void)createStatusItem
{
    NSSize imageSize;
    imageSize.width = [[NSFont menuFontOfSize:0] pointSize];
    imageSize.height = imageSize.width;
    NSImage *statusItemImage = [NSImage imageNamed:@"Note"];
    [statusItemImage setSize:imageSize];
    
    [self setStatusItem:[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength]];
    [[self statusItem] setMenu:[self statusMenu]];
    [[self statusItem] setHighlightMode:YES];
    [[self statusItem] setImage:statusItemImage];
}

-(void)initializeLibrary
{
    if (self->scanInProgress)
    {
        return;
    }
    @synchronized([self Server])
    {
        self->scanInProgress = YES;
        if ([[self Server] isStarted])
        {
            [[self Server] stop];
        }
        
        dispatch_queue_t loadQueue = dispatch_queue_create("AppDelegateLoad", NULL);
        dispatch_async(loadQueue, ^{
            [[self itunesHandler] loadLibrary];
            [[self Server] start];
            self->scanInProgress = NO;
        });
    }
}

-(IBAction)rescanLibrary:(id)sender
{
    [self initializeLibrary];
}

-(void)setProgress:(NSNumber *)percentComplete {
    NSDockTile *docTile = [[NSApplication sharedApplication] dockTile];
    if (percentComplete != nil) {
        NSString *pcComplete = [NSString stringWithFormat:@"%ld%%", (long)[percentComplete integerValue]];
        [[self statusItem] setTitle:pcComplete];
        [docTile setBadgeLabel:pcComplete];
    }
    else {
        [[self statusItem] setTitle:nil];
        [docTile setBadgeLabel:nil];
    }
}

-(NSMenu *)applicationDockMenu:(NSApplication *)sender
{
    NSMenu *menu = [[NSMenu alloc] init];
    NSMenuItem *menuItem1;
    menuItem1 = [[NSMenuItem alloc]
                 initWithTitle:@"Launch Web Interface"
                 action:@selector(showWebInterface:)
                 keyEquivalent:@""];
    NSMenuItem *menuItem2 = [[NSMenuItem alloc]
                 initWithTitle:@"Rescan Library"
                 action:@selector(rescanLibrary:)
                 keyEquivalent:@""];
    [menu addItem:menuItem1];
    [menu addItem:menuItem2];
    return menu;
}

-(IBAction)showAboutWindow:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:sender];
}

-(IBAction)showPrefsWindow:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    [[self prefsWindow] setResponder:[self responder]];
    [[self prefsWindow] loadSettings];
    [[self prefsWindow] makeKeyAndOrderFront:self];
}

-(IBAction)showWebInterface:(id)sender
{
    NSString *token;
    NSString *authentication;
    [[self authHandler] getAuthentication:&authentication token:&token];
    NSString *appURL = [NSString stringWithFormat:@"http://localhost:12345/#/login?auth=%@&token=%@", authentication, token];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:appURL]];
}

@end