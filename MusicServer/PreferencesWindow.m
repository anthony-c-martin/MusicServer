//
//  PreferencesWindow.m
//  MusicServer
//
//  Created by Anthony Martin on 31/03/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import "PreferencesWindow.h"
#import "AMMusicServerActiveData.h"

@implementation PreferencesWindow

-(void)controlTextDidChange:(NSNotification *)aNotification
{
    if ([aNotification object] == [self username])
    {
        if (![self pwChanged])
        {
            [[self password] setStringValue:@""];
            [self setPwChanged:YES];
        }
    }
    else if ([aNotification object] == [self password])
    {
        [self setPwChanged:YES];
    }
}

-(void)loadSettings
{
    AMMusicServerActiveData *activeData = [AMMusicServerActiveData sharedInstance];
    [self setPwChanged:NO];
    [[self username] setStringValue:[activeData username]];
    [[self password] setStringValue:@"******"];
    [[self maxSessions] setIntegerValue:[[activeData maxSessions] integerValue]];
    [[self maxCachedTracks] setIntegerValue:[[activeData maxCachedTracks] integerValue]];
    [[self lastFMUsername] setStringValue:@""];
}

-(IBAction)saveButtonPressed:(id)sender
{
    AMMusicServerActiveData *activeData = [AMMusicServerActiveData sharedInstance];
    if ([self pwChanged])
    {
        [activeData storeCredentials:[[self username] stringValue] password:[[self password] stringValue]];
    }
    [activeData setMaxSessions:[NSNumber numberWithInteger:[[self maxSessions] integerValue]]];
    [activeData setMaxCachedTracks:[NSNumber numberWithInteger:[[self maxCachedTracks] integerValue]]];
    [self close];
}

-(IBAction)clearSessionsButtonPressed:(id)sender
{
    
}

-(IBAction)addLastFMButtonPressed:(id)sender
{
    
}

@end

@implementation OnlyIntegerValueFormatter

- (BOOL)isPartialStringValid:(NSString*)partialString newEditingString:(NSString**)newString errorDescription:(NSString**)error
{
    if([partialString length] == 0) {
        return YES;
    }
    
    NSScanner* scanner = [NSScanner scannerWithString:partialString];
    
    if(!([scanner scanInt:0] && [scanner isAtEnd])) {
        NSBeep();
        return NO;
    }
    
    return YES;
}

@end