//
//  AMPercentageValueUpdater.h
//  MusicServer
//
//  Created by Anthony Martin on 05/04/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMPercentageValueUpdater <NSObject>

-(void)setProgress:(NSNumber *)percentComplete;

@end