//
//  AMAPIHandlerITunes.h
//  MusicServer
//
//  Created by Anthony Martin on 02/11/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMAPIDataResponder.h"

@class AMMusicServerActiveData;
@protocol AMPercentageValueUpdater;

@interface AMAPIHandlerITunes : NSObject<AMAPIDataResponder>

@property (nonatomic, retain) NSArray *Tracks;
@property (nonatomic, retain) NSArray *Artists;
@property (nonatomic, retain) NSArray *Albums;
@property (nonatomic, retain) AMMusicServerActiveData *activeData;
@property (nonatomic, retain) id <AMPercentageValueUpdater> valueUpdater;

-(id) initWithActiveData:(AMMusicServerActiveData *)data valueUpdater:(id <AMPercentageValueUpdater>)updater;
-(BOOL) loadLibrary;

@end