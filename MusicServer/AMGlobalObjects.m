//
//  AMGlobalObjects.m
//  MusicServer
//
//  Created by Anthony Martin on 24/02/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import "AMGlobalObjects.h"
#import "AMJSONListener.h"
#import "AMMusicServerPersistentData.h"

static AMJSONListener *_JSONListener = nil;
static AMMusicServerPersistentData *_PersistentData = nil;

@implementation AMGlobalObjects

+(AMJSONListener *)JSONListener
{
    return _JSONListener;
}

+(void)setJSONListener:(AMJSONListener *)JSONListener
{
    _JSONListener = JSONListener;
}

+(AMMusicServerPersistentData *)PersistentData
{
    if (_PersistentData == nil)
    {
        _PersistentData = [[AMMusicServerPersistentData alloc] init];
    }
    return _PersistentData;
}

@end