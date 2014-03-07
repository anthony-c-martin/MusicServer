//
//  AMHTTPConnection.h
//  MusicServer
//
//  Created by Anthony Martin on 24/02/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoaHTTPServer/HTTPConnection.h>

@interface AMHTTPConnection : HTTPConnection

@property (nonatomic, retain) NSString *connectedHost;

@end