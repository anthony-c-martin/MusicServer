//
//  AMPersistentData.m
//  MusicServer
//
//  Created by Anthony Martin on 25/02/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import "AMPersistentData.h"

@implementation AMPersistentData

@synthesize bundlePlist;
@synthesize mainPlist;

-(id)initWithPlist:(NSString *)plistName
{
    self = [super init];
    if (self)
    {
        [self setBundlePlist:[NSString stringWithString:[[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"]]];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *libDirectory = [paths objectAtIndex:0];
        [self setMainPlist:[[[libDirectory stringByAppendingPathComponent:@"Preferences"] stringByAppendingPathComponent:plistName] stringByAppendingPathExtension:@"plist"]];
        [self initialiseMainPlist];
    }
    return self;
}

-(BOOL)doesPlistExist:(NSString *)plist
{
    BOOL exists = FALSE;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if ([fileManager fileExistsAtPath:plist])
    {
        exists = TRUE;
    }
    return exists;
}

-(void)initialiseMainPlist
{
    if (![self doesPlistExist:mainPlist])
    {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        [fileManager createFileAtPath:mainPlist contents:NULL attributes:NULL];
        NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:bundlePlist];
        [plistData writeToFile:mainPlist atomically:YES];
    }
}

-(id)getObjectWithKey:(NSString *)key
{
    NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:mainPlist];
    if ([plistDict objectForKey:key])
    {
        return [plistDict valueForKey:key];
    }
    return nil;
}

-(void)setObject:(id)object WithKey:(NSString *)key
{
    NSMutableDictionary *plistDict = [NSMutableDictionary dictionaryWithContentsOfFile:mainPlist];
    [plistDict setValue:object forKey:key];
    [plistDict writeToFile:mainPlist atomically:YES];
}

-(NSString *)getStringWithKey:(NSString *)key
{
    return (NSString *)[self getObjectWithKey:key];
}

-(NSNumber *)getNumberWithKey:(NSString *)key
{
    return (NSNumber *)[self getObjectWithKey:key];
}

-(NSArray *)getArrayWithKey:(NSString *)key
{
    return (NSArray *)[self getObjectWithKey:key];
}

-(BOOL)getBoolWithKey:(NSString *)key
{
    NSNumber *numValue = [self getNumberWithKey:key];
    if (numValue == nil)
    {
        return NO;
    }
    return [numValue boolValue];
}

-(void)setString:(NSString *)string WithKey:(NSString *)key
{
    [self setObject:string WithKey:key];
}

-(void)setNumber:(NSNumber *)number WithKey:(NSString *)key
{
    [self setObject:number WithKey:key];
}

-(void)setBool:(BOOL)value WithKey:(NSString *)key
{
    [self setNumber:[NSNumber numberWithBool:value] WithKey:key];
}

-(void)setArray:(NSArray *)array WithKey:(NSString *)key
{
    [self setObject:array WithKey:key];
}

@end