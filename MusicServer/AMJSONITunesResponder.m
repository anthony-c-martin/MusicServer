//
//  AMJSONITunesResponder.m
//  MusicServer
//
//  Created by Anthony Martin on 02/03/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import "AMJSONITunesResponder.h"
#import "AMAPIHandlerITunes.h"

@interface AMJSONITunesResponder()

@property (nonatomic, retain) AMAPIHandlerITunes *itHandler;

@end

@implementation AMJSONITunesResponder

-(id) init
{
    self = [super initWithDelegate:[AMAPIHandlerITunes sharedInstance]];
    if (self)
    {
        
    }
    return self;
}

+(AMJSONITunesResponder *)sharedInstance
{
    static AMJSONITunesResponder *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMJSONITunesResponder alloc] init];
    });
    return sharedInstance;
}

@end