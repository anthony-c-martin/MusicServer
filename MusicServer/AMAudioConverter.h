//
//  AMAudioConverter.h
//  MusicServer
//
//  Created by Anthony Martin on 03/11/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMAudioConverter : NSObject

+(BOOL) ConvertToM4A:(NSURL *)input
              output:(NSURL *)output;

+(BOOL) ConvertToPCM:(NSURL *)input
              output:(NSURL *)output;

@end