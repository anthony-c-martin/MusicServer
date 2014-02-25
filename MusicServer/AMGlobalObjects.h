//
//  AMGlobalObjects.h
//  MusicServer
//
//  Created by Anthony Martin on 24/02/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMJSONListener;

@interface AMGlobalObjects : NSObject

+(AMJSONListener *)JSONListener;
+(void)setJSONListener:(AMJSONListener *)JSONListener;

@end