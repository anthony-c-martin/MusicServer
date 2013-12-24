//
//  AppDelegate.m
//  MusicServer
//
//  Created by Anthony Martin on 30/10/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import "AppDelegate.h"
#import "./AMJSONListener.h"
#import "./AMAPIHandlerITunes.h"
#import "./AMAudioConverter.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    /*
    AMAPIHandlerITunes *handler = [[AMAPIHandlerITunes alloc] init];
    AMAPIDataIDRequest *request = [[AMAPIDataIDRequest alloc] init];
    [request setID:[NSNumber numberWithUnsignedLong:-6733784602019770963]];
    AMAPIITTrack *test;
    [handler getTrackByID:[request ID] Response:&test];

    AMAPIDataStringRequest *stringRequest = [[AMAPIDataStringRequest alloc] init];
    [stringRequest setString:@"Test"];
    NSArray *output;
    [handler getTracksBySearchString:[stringRequest String]
                            Response:&output
                               Start:[NSNumber numberWithInt:0]
                               Limit:[NSNumber numberWithInt:0]];
    */
    
    [self setHandler:[[AMAPIHandlerITunes alloc] init]];
    [self setListener:[[AMJSONListener alloc] initOnPort:12345 withDelegate:[self Handler]]];
}

@end