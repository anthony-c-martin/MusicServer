//
//  AppDelegate.m
//  MusicServer
//
//  Created by Anthony Martin on 30/10/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import "AppDelegate.h"
#import "AMHTTPConnection.h"
#import "AMJSONListener.h"
#import "AMAPIHandlerITunes.h"
#import "AMAudioConverter.h"
#import "AMGlobalObjects.h"
#import <CocoaHTTPServer/HTTPServer.h>

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setJSONListener:[[AMJSONListener alloc] initOnPort:12345 withDelegate:[[AMAPIHandlerITunes alloc] init]]];
    [AMGlobalObjects setJSONListener:[self JSONListener]];
    
    [self setServer:[[HTTPServer alloc] init]];
    [[self Server] setType:@"_http._tcp"];
    [[self Server] setPort:12345];
    [[self Server] setConnectionClass:[AMHTTPConnection class]];
    [[self Server] setDocumentRoot:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"webroot"]];
    [[self Server] start:nil];
}

@end