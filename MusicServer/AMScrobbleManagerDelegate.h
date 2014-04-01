//
//  AMScrobbleManagerDelegate.h
//  MusicServer
//
//  Created by Anthony Martin on 01/04/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMScrobbleManagerDelegate <NSObject>

-(void)requestTokenValidation:(NSString *)Token APIKey:(NSString *)APIKey;

@end