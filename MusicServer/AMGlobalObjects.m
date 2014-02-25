//
//  AMGlobalObjects.m
//  MusicServer
//
//  Created by Anthony Martin on 24/02/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import "AMGlobalObjects.h"
#import "AMJSONListener.h"

static AMJSONListener *_JSONListener = nil;

@implementation AMGlobalObjects

+(AMJSONListener *)JSONListener
{
    return _JSONListener;
}

+(void)setJSONListener:(AMJSONListener *)JSONListener
{
    _JSONListener = JSONListener;
}

@end