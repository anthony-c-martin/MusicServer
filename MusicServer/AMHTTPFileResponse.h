//
//  AMHTTPFileResponse.h
//  MusicServer
//
//  Created by Anthony Martin on 03/04/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import <CocoaHTTPServer/HTTPFileResponse.h>

@interface AMHTTPFileResponse : HTTPFileResponse

@property (nonatomic, retain) NSString *contentType;

@end