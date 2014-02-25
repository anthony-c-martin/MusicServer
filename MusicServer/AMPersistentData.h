//
//  AMPersistentData.h
//  MusicServer
//
//  Created by Anthony Martin on 25/02/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMPersistentData : NSObject

@property (nonatomic, retain) NSString *bundlePlist;
@property (nonatomic, retain) NSString *mainPlist;

-(id)initWithPlist:(NSString *)plistName;

-(NSString *)getStringWithKey:(NSString *)key;

-(NSNumber *)getNumberWithKey:(NSString *)key;

-(NSArray *)getArrayWithKey:(NSString *)key;

-(BOOL)getBoolWithKey:(NSString *)key;

-(void)setString:(NSString *)string WithKey:(NSString *)key;

-(void)setNumber:(NSNumber *)number WithKey:(NSString *)key;

-(void)setBool:(BOOL)value WithKey:(NSString *)key;

-(void)setArray:(NSArray *)array WithKey:(NSString *)key;

@end