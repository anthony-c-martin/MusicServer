//
//  AMJSONAPIData.m
//  MusicServer
//
//  Created by Anthony Martin on 30/10/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import "AMJSONAPIData.h"
#import <CommonCrypto/CommonDigest.h>

@implementation AMJSONAPIData

-(id) initFromData:(NSData *)data
{
    NSError *error;
    NSDictionary *dictionary = [AMJSONAPIData deserialiseJSON:data Error:error];
    if (error)
    {
        return nil;
    }
    
    self = [super initWithDictionary:dictionary];
    if (self)
    {
        
    }
    return self;
}

-(id) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if (self)
    {
        if (![self validateSignature:dictionary])
        {
            return nil;
        }
    }
    return self;
}

-(BOOL) validateSignature:(NSDictionary *)dictionary
{
    if (![dictionary objectForKey:@"Signature"])
    {
        return NO;
    }
    
    NSMutableString *dataString = [NSMutableString stringWithString:@""];
    NSMutableDictionary *sortedDictionary;
    
    for (id key in [[dictionary allKeys] sortedArrayUsingSelector: @selector(caseSensitive)])
    {
        [sortedDictionary setObject:[dictionary valueForKey:key] forKey:key];
    }
    
    for (NSString *key in sortedDictionary)
    {
        if (![[sortedDictionary objectForKey:key] isEqualToString:@"Signature"])
        {
            [dataString appendFormat:@"%@:%@;", key, [sortedDictionary objectForKey:key]];
        }
    }
    
    return ([[dictionary objectForKey:@"Signature"] isEqualToString:[AMJSONAPIData CalculateMD5:dataString]]);
}

+(NSString *) CalculateMD5:(NSString *)input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *MD5Result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    {
        [MD5Result appendFormat:@"%02x", digest[i]];
    }
    
    return MD5Result;
}

+(NSString *) randomAlphanumericString
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:32];
    
    for (int i = 0; i < 32; i++)
    {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
    }
    
    return randomString;
}

-(NSData *) dataFromObject
{
    NSError *error = nil;
    NSData *data;
    NSDictionary *dictionary = [self dictionaryFromObject];
    if ([dictionary count] == 1)
    {
        id firstObject = [dictionary objectForKey:[[dictionary allKeys] objectAtIndex:0]];
        if ([firstObject isKindOfClass:[NSArray class]])
        {
            data = [AMJSONAPIData serialiseJSONArray:firstObject Error:error];
            if (!error)
            {
                return data;
            }
            return nil;
        }
    }
    
    data = [AMJSONAPIData serialiseJSON:dictionary Error:error];
    if (!error)
    {
        return data;
    }
    return nil;
}

-(id) serialiseObject:(id)input
{
    id output;
    if ([input isKindOfClass:[NSDictionary class]])
    {
        output = [self serialiseDictionary:input];
    }
    else if ([input isKindOfClass:[NSArray class]])
    {
        output = [self serialiseArray:input];
    }
    else if ([input isKindOfClass:[AMJSONAPIData class]])
    {
        output = [(AMJSONAPIData *)input dictionaryFromObject];
    }
    else
    {
        output = input;
    }
    return (id)output;
}

-(NSArray *) serialiseArray:(NSArray *)input
{
    NSMutableArray *output = [[NSMutableArray alloc] init];
    
    for (id object in input)
    {
        [output addObject:[self serialiseObject:object]];
    }
    
    return (NSArray *)output;
}

-(NSDictionary *) serialiseDictionary:(NSDictionary *)input
{
    NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
    NSDictionary *entryMapping = [self dictionaryEntriesToPropertiesMapping];
    
    for (NSString *key in input)
    {
        NSString *newKey = [entryMapping objectForKey:key];
        id object = [input objectForKey:key];
        [output setObject:[self serialiseObject:object] forKey:newKey];
    }
    
    return (NSDictionary *)output;
}

-(NSDictionary *) dictionaryFromObject
{
    NSDictionary *dictionary = [self dictionaryWithValuesForKeys:[[self propertiesToDictionaryEntriesMapping] allValues]];
    
    return [self serialiseDictionary:dictionary];
}

-(NSDictionary *) dictionaryEntriesToPropertiesMapping
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    NSDictionary *propertiesMapping = [self propertiesToDictionaryEntriesMapping];
    
    for (NSString *key in propertiesMapping)
    {
        [dictionary setObject:key forKey:[propertiesMapping objectForKey:key]];
    }
    
    return (NSDictionary *)dictionary;
}

+(NSDictionary *) deserialiseJSON:(NSData *)data
                            Error:(NSError *)error
{
    NSDictionary *output = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if ([object isKindOfClass:[NSDictionary class]])
    {
        output = object;
    }
    
    return output;
}

+(NSData *) serialiseJSONArray:(NSArray *)array
                         Error:(NSError *)error
{
    return [NSJSONSerialization dataWithJSONObject:array options:0 error:&error];
}

+(NSData *) serialiseJSON:(NSDictionary *)dictionary
                    Error:(NSError *)error
{
    return [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
}

+(AMJSONCommandOptions) getCommand:(NSDictionary *)dictionary
{
    NSString *commandString = [dictionary objectForKey:@"Command"];
    if (!commandString)
    {
        return AMJSONCommandUnknown;
    }
    
    NSArray *commands = [[NSArray alloc] initWithObjects: AMJSONCommands];
    
    NSUInteger retVal = [commands indexOfObject:commandString];
    if (retVal == NSNotFound)
    {
        return AMJSONCommandUnknown;
    }
    
    return (AMJSONCommandOptions)retVal;
}

@end