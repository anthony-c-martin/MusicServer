//
//  AppDelegate.h
//  MusicServer
//
//  Created by Anthony Martin on 30/10/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AMJSONListener;
@protocol AMAPIDataResponder;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) AMJSONListener *Listener;
@property (nonatomic, retain) NSObject<AMAPIDataResponder> *Handler;

@end