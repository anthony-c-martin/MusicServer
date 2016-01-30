//
//  AMAudioConverter.m
//  MusicServer
//
//  Created by Anthony Martin on 03/11/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import "AMAudioConverter.h"
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioFile.h>

extern OSStatus DoConvertFile(CFURLRef sourceURL, CFURLRef destinationURL, OSType outputFileType, OSType outputFormat, Float64 outputSampleRate);

enum AMAudioConverterFormat
{
    kAMAudioConverterFormatPCM,
    kAMAudioConverterFormatM4A
};

@implementation AMAudioConverter

+(BOOL) ConvertFile:(NSURL *)input
             output:(NSURL *)output
           toFormat:(AMAudioConverterFormat)outputFormat
           withRate:(double)outputRate
{
    OSType format;
    OSType fileFormat;
    
    switch (outputFormat)
    {
        case kAMAudioConverterFormatPCM:
            format = kAudioFormatLinearPCM;
            fileFormat = kAudioFileCAFType;
            break;
        case kAMAudioConverterFormatM4A:
            format = kAudioFormatMPEG4AAC;
            fileFormat = kAudioFileM4AType;
            break;
    }
    
    UInt32 Status =  DoConvertFile((__bridge CFURLRef)input,
                                   (__bridge CFURLRef)output,
                                   fileFormat,
                                   format,
                                   outputRate);
    
    return !Status;
}

+(BOOL) ConvertToM4A:(NSURL *)input
              output:(NSURL *)output
{
    if (![AMAudioConverter ConvertFile:input
                                output:output
                              toFormat:kAMAudioConverterFormatM4A
                              withRate:44100.0])
    {
        return NO;
    }
    return YES;
}

+(BOOL) ConvertToPCM:(NSURL *)input
              output:(NSURL *)output
{
    if (![AMAudioConverter ConvertFile:input
                                output:output
                              toFormat:kAMAudioConverterFormatPCM
                              withRate:44100.0])
    {
        return NO;
    }
    return YES;
}


+(NSString *) pathForTemporaryFileWithPrefix:(NSString *)prefix
{
    NSString *  result;
    CFUUIDRef   uuid;
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    result = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", prefix, uuidStr]];
    assert(result != nil);
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

@end