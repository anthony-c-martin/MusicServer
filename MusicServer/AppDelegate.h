//
//  AppDelegate.h
//  MusicServer
//
//  Created by Anthony Martin on 30/10/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoaHTTPServer/HTTPServer.h>

@class AMJSONListener;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property HTTPServer *Server;
@property (nonatomic, retain) AMJSONListener *JSONListener;

@end