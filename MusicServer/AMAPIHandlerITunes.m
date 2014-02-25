//
//  AMAPIHandlerITunes.m
//  MusicServer
//
//  Created by Anthony Martin on 02/11/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import "AMAPIHandlerITunes.h"
#import <iTunesLibrary/ITLibrary.h>
#import <iTunesLibrary/ITLibMediaItem.h>
#import <iTunesLibrary/ITLibArtist.h>
#import <iTunesLibrary/ITLibAlbum.h>
#import <iTunesLibrary/ITLibArtwork.h>
#import "./AMJSONAPIDataObjects.h"
#import "./AMAudioConverter.h"
#import "AMGlobalObjects.h"
#import "AMMusicServerPersistentData.h"

@interface NSImage (scalingAdditions)
-(NSString *) base64String;
- (NSImage*) imageByScalingProportionallyToSize:(NSSize)targetSize;
@end

@implementation NSImage (scalingAdditions)
-(NSString *) base64String
{
    NSImage *scaledDown = [self imageByScalingProportionallyToSize:NSMakeSize(148, 148)];
    NSData *imageData = [scaledDown TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    return [[NSString alloc] initWithData:[imageData base64EncodedDataWithOptions:0] encoding:NSUTF8StringEncoding];
}

-(NSImage*) imageByScalingProportionallyToSize:(NSSize)targetSize
{
    NSImage* sourceImage = self;
    NSImage* newImage = nil;
    
    if ([sourceImage isValid]){
        NSSize imageSize = [sourceImage size];
        float width  = imageSize.width;
        float height = imageSize.height;
        
        float targetWidth  = targetSize.width;
        float targetHeight = targetSize.height;
        
        float scaleFactor  = 0.0;
        float scaledWidth  = targetWidth;
        float scaledHeight = targetHeight;
        
        NSPoint thumbnailPoint = NSZeroPoint;
        
        if ( NSEqualSizes( imageSize, targetSize ) == NO )
        {
            
            float widthFactor  = targetWidth / width;
            float heightFactor = targetHeight / height;
            
            if ( widthFactor < heightFactor )
                scaleFactor = widthFactor;
            else
                scaleFactor = heightFactor;
            
            scaledWidth  = width  * scaleFactor;
            scaledHeight = height * scaleFactor;
            
            if ( widthFactor < heightFactor )
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
            else if ( widthFactor > heightFactor )
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
        newImage = [[NSImage alloc] initWithSize:targetSize];
        [newImage lockFocus];
        NSRect thumbnailRect;
        thumbnailRect.origin = thumbnailPoint;
        thumbnailRect.size.width = scaledWidth;
        thumbnailRect.size.height = scaledHeight;
        [sourceImage drawInRect: thumbnailRect
                       fromRect: NSZeroRect
                      operation: NSCompositeSourceOver
                       fraction: 1.0];
        [newImage unlockFocus];
    }
    return newImage;
}
@end

@implementation AMAPIHandlerITunes

-(id) init
{
    self = [super init];
    if (self)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSString *applicationSupportDirectory = [paths firstObject];
        NSURL *cacheFolder = [[NSURL fileURLWithPath:applicationSupportDirectory] URLByAppendingPathComponent:@"AMMusicServer"];
        [[NSFileManager defaultManager] createDirectoryAtPath:[cacheFolder path] withIntermediateDirectories:NO attributes:nil error:nil];
        [self setTracks:[[NSSet alloc] init]];
        [self setArtists:[[NSSet alloc] init]];
        [self setAlbums:[[NSSet alloc] init]];
        [self loadLibrary];
    }
    return self;
}

-(BOOL) loadLibrary
{
    NSError *error = nil;
    ITLibrary *library = [ITLibrary libraryWithAPIVersion:@"1.0" error:&error];
    
    if (!error && library)
    {
        NSMutableSet *tracks = [[NSMutableSet alloc] init];
        NSMutableSet *albums = [[NSMutableSet alloc] init];
        NSMutableSet *artists = [[NSMutableSet alloc] init];
        int albumID = 1;
        int artistID = 1;
        
        for (ITLibMediaItem *mediaItem in [library allMediaItems])
        {
            NSImage *artwork = nil;
//            if ([mediaItem hasArtworkAvailable])
//            {
//                artwork = [[mediaItem artwork] image];
//            }
            [self addMediaItem:mediaItem
                      trackSet:tracks
                      albumSet:albums
                       albumID:&albumID
                     artistSet:artists
                      artistID:&artistID
                       artwork:artwork]; 
        }
        
        [self setTracks:(NSSet *)tracks];
        [self setAlbums:(NSSet *)albums];
        [self setArtists:(NSSet *)artists];
        
        return YES;
    }
    return NO;
}

+(NSArray *)artistSortDescriptors
{
    return [NSArray arrayWithObjects:
            [[NSSortDescriptor alloc] initWithKey:@"Name" ascending:YES],
            nil];
}

+(NSArray *)albumSortDescriptors
{
    return [NSArray arrayWithObjects:
            [[NSSortDescriptor alloc] initWithKey:@"Artist.Name" ascending:YES],
            [[NSSortDescriptor alloc] initWithKey:@"Name" ascending:YES],
            nil];
}

+(NSArray *)trackSortDescriptors
{
    return [NSArray arrayWithObjects:
            [[NSSortDescriptor alloc] initWithKey:@"Album.Artist.Name" ascending:YES],
            [[NSSortDescriptor alloc] initWithKey:@"Album.Name" ascending:YES],
            [[NSSortDescriptor alloc] initWithKey:@"DiscNumber" ascending: YES],
            [[NSSortDescriptor alloc] initWithKey:@"TrackNumber" ascending:YES],
            [[NSSortDescriptor alloc] initWithKey:@"Name" ascending:YES],
            nil];
}

-(void) addArtist:(AMAPIITArtist **)artist
            toSet:(NSMutableSet *)artistSet
        currentID:(int *)currentID
{
    if (![artistSet containsObject:*artist])
    {
        [*artist setID:[NSNumber numberWithInt:(*currentID)++]];
    }
    [self getPointer:artist fromSet:artistSet];
}

-(void) addAlbum:(AMAPIITAlbum **)album
            toSet:(NSMutableSet *)albumSet
        currentID:(int *)currentID
         artwork:(NSImage *)artwork
{
    if (![albumSet containsObject:*album])
    {
        [*album setID:[NSNumber numberWithInt:(*currentID)++]];
        [*album setArtwork:[artwork base64String]];
    }
    [self getPointer:album fromSet:albumSet];
}

-(void) addMediaItem:(ITLibMediaItem *)mediaItem
            trackSet:(NSMutableSet *)trackSet
            albumSet:(NSMutableSet *)albumSet
             albumID:(int *)albumID
           artistSet:(NSMutableSet *)artistSet
            artistID:(int *)artistID
             artwork:(NSImage *)artwork
{
    if ([mediaItem mediaKind] == ITLibMediaItemMediaKindSong)
    {
        AMAPIITTrack *track = [[AMAPIITTrack alloc] init];
        AMAPIITAlbum *album = [[AMAPIITAlbum alloc] init];
        AMAPIITArtist *artist = [[AMAPIITArtist alloc] init];
        
        [artist setName:[[mediaItem artist] name]];
        [self addArtist:&artist toSet:artistSet currentID:artistID];

        if ([[mediaItem album] isCompilation])
        {
            AMAPIITArtist *albumArtist = [[AMAPIITArtist alloc] init];
            if ([[mediaItem album] albumArtist])
            {
                [albumArtist setName:[[mediaItem album] albumArtist]];
            }
            else
            {
                [albumArtist setName:@"Various Artists"];
            }
            [self addArtist:&albumArtist toSet:artistSet currentID:artistID];
            [album setArtist:albumArtist];
        }
        else
        {
            [album setArtist:artist];
        }
        
        [album setName:[[mediaItem album] title]];
        [self addAlbum:&album toSet:albumSet currentID:albumID artwork:artwork];
        
        [track setName:[mediaItem title]];
        [track setTrackNumber:[NSNumber numberWithUnsignedInteger:[mediaItem trackNumber]]];
        [track setLocation:[[mediaItem location] absoluteString]];
        [track setID:[[mediaItem persistentID] stringValue]];
        [track setAlbum:album];
        [track setArtist:artist];
        [track setDiscNumber:[NSNumber numberWithInteger:[[mediaItem album] discNumber]]];
        [self getPointer:&track fromSet:trackSet];
        if (![[artist AlbumSet] containsObject:album])
        {
            [[artist AlbumSet] addObject:album];
        }
        if (![[artist TrackSet] containsObject:track])
        {
            [[artist TrackSet] addObject:track];
        }
        if (![[album TrackSet] containsObject:track])
        {
            [[album TrackSet] addObject:track];
        }
    }
}

-(void) getPointer:(id *)object
           fromSet:(NSMutableSet *)set
{
    if (![set containsObject:*object])
    {
        [set addObject:*object];
    }
    else
    {
        for (id existingObject in set)
        {
            if ([*object isEqual:existingObject])
            {
                *object = existingObject;
            }
        }
    }
}

-(BOOL) matchObjectsInSet:(NSSet *)inputSet
                withBlock:(void (^)(id object, BOOL *matched))matchBlock
                  matches:(NSArray **)matches
      sortedByDescriptors:(NSArray *)descriptors
            startPosition:(NSNumber *)startPosition
               countLimit:(NSNumber *)countLimit
{
    NSArray *sortedArray = [inputSet sortedArrayUsingDescriptors:descriptors];
    
    __block NSMutableArray *matchMutableArray = [[NSMutableArray alloc] init];
    __block BOOL matched;
    __block int matchCount = 0;
    __block int start = [startPosition intValue];
    __block int limit = [countLimit intValue];
    
    [sortedArray enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        matched = NO;
        matchBlock(object, &matched);
        if (matched)
        {
            if (matchCount >= start)
            {
                [matchMutableArray addObject:object];
            }
            
            matchCount++;
            if (limit > 0 && matchCount >= start + limit)
            {
                *stop = YES;
            }
        }
    }];
    
    *matches = [NSArray arrayWithArray:matchMutableArray];
    return YES;
}

-(BOOL) getFirstObjectInSet:(NSSet *)inputSet
                  withBlock:(void (^)(id object, BOOL *matched))matchBlock
              matchedObject:(id *)matchedObject
        sortedByDescriptors:(NSArray *)descriptors
{
    NSArray *matches = nil;
    
    [self matchObjectsInSet:inputSet
                      withBlock:matchBlock
                        matches:&matches
            sortedByDescriptors:descriptors
                  startPosition:[NSNumber numberWithInt:0]
                     countLimit:[NSNumber numberWithInt:1]];
    *matchedObject = ([matches count] > 0) ? [matches objectAtIndex:0] : nil;
    return YES;
}

-(BOOL) matchTracksWithBlock:(void (^)(AMAPIITTrack *track, BOOL *matched))matchBlock
                     matches:(NSArray **)matches
         sortedByDescriptors:(NSArray *)descriptors
               startPosition:(NSNumber *)startPosition
                  countLimit:(NSNumber *)countLimit
{
    return [self matchObjectsInSet:[self Tracks]
                         withBlock:matchBlock
                           matches:matches
               sortedByDescriptors:descriptors
                     startPosition:startPosition
                        countLimit:countLimit];
}

-(BOOL) getFirstTrackWithBlock:(void (^)(AMAPIITTrack *track, BOOL *matched))matchBlock
                  matchedTrack:(AMAPIITTrack **)matchedTrack
           sortedByDescriptors:(NSArray *)descriptors
{
    return [self getFirstObjectInSet:[self Tracks]
                           withBlock:matchBlock
                       matchedObject:matchedTrack
                 sortedByDescriptors:descriptors];
}

-(BOOL) matchArtistsWithBlock:(void (^)(AMAPIITArtist *artist, BOOL *matched))matchBlock
                      matches:(NSArray **)matches
          sortedByDescriptors:(NSArray *)descriptors
                startPosition:(NSNumber *)startPosition
                   countLimit:(NSNumber *)countLimit
{
    return [self matchObjectsInSet:[self Artists]
                         withBlock:matchBlock
                           matches:matches
               sortedByDescriptors:descriptors
                     startPosition:startPosition
                        countLimit:countLimit];
}

-(BOOL) getFirstArtistWithBlock:(void (^)(AMAPIITArtist *artist, BOOL *matched))matchBlock
                  matchedArtist:(AMAPIITArtist **)matchedArtist
            sortedByDescriptors:(NSArray *)descriptors
{
    return [self getFirstObjectInSet:[self Artists]
                           withBlock:matchBlock
                       matchedObject:matchedArtist
                 sortedByDescriptors:descriptors];
}

-(BOOL) matchAlbumsWithBlock:(void (^)(AMAPIITAlbum *album, BOOL *matched))matchBlock
                     matches:(NSArray **)matches
         sortedByDescriptors:(NSArray *)descriptors
               startPosition:(NSNumber *)startPosition
                  countLimit:(NSNumber *)countLimit
{
    return [self matchObjectsInSet:[self Albums]
                         withBlock:matchBlock
                           matches:matches
               sortedByDescriptors:descriptors
                     startPosition:startPosition
                        countLimit:countLimit];
}

-(BOOL) getFirstAlbumWithBlock:(void (^)(AMAPIITAlbum *track, BOOL *matched))matchBlock
                  matchedAlbum:(AMAPIITAlbum **)matchedAlbum
           sortedByDescriptors:(NSArray *)descriptors
{
    return [self getFirstObjectInSet:[self Albums]
                           withBlock:matchBlock
                       matchedObject:matchedAlbum
                 sortedByDescriptors:descriptors];
}

-(BOOL) getTrackByID:(NSString *)request
            Response:(AMAPIITTrack **)response
{
    return [self getFirstTrackWithBlock:^(AMAPIITTrack *track, BOOL *matched) {
        *matched = ([[track ID] isEqualToString:request]);
    }
                           matchedTrack:response
                    sortedByDescriptors:[AMAPIHandlerITunes trackSortDescriptors]];
}

-(BOOL) getTracksBySearchString:(NSString *)request
                       Response:(NSArray **)response
                          Start:(NSNumber *)start
                          Limit:(NSNumber *)limit
{
    return [self matchTracksWithBlock:^(AMAPIITTrack *track, BOOL *matched) {
        *matched = ([[track Name] rangeOfString:request options:NSCaseInsensitiveSearch].length > 0);
    }
                              matches:response
                  sortedByDescriptors:[AMAPIHandlerITunes trackSortDescriptors]
                        startPosition:start
                           countLimit:limit];
}

-(BOOL) getArtistsBySearchString:(NSString *)request
                        Response:(NSArray **)response
                           Start:(NSNumber *)start
                           Limit:(NSNumber *)limit
{
    return [self matchArtistsWithBlock:^(AMAPIITArtist *artist, BOOL *matched) {
        *matched = ([[artist Name] rangeOfString:request options:NSCaseInsensitiveSearch].length > 0);
    }
                              matches:response
                  sortedByDescriptors:[AMAPIHandlerITunes artistSortDescriptors]
                        startPosition:start
                           countLimit:limit];
}

-(BOOL) getAlbumsBySearchString:(NSString *)request
                        Response:(NSArray **)response
                           Start:(NSNumber *)start
                           Limit:(NSNumber *)limit
{
    return [self matchAlbumsWithBlock:^(AMAPIITAlbum *album, BOOL *matched) {
        *matched = ([[album Name] rangeOfString:request options:NSCaseInsensitiveSearch].length > 0);
    }
                               matches:response
                   sortedByDescriptors:[AMAPIHandlerITunes albumSortDescriptors]
                         startPosition:start
                            countLimit:limit];
}

-(BOOL) getTracksByArtist:(NSNumber *)request
                 Response:(NSArray **)response
                    Start:(NSNumber *)start
                    Limit:(NSNumber *)limit
{
    AMAPIITArtist *artist;
    if ([self getFirstArtistWithBlock:^(AMAPIITArtist *artist, BOOL *matched) {
        *matched = ([request isEqualTo:[artist ID]]);
    }
                        matchedArtist:&artist
                  sortedByDescriptors:[AMAPIHandlerITunes artistSortDescriptors]])
    {
        NSInteger startLoc = [start integerValue];
        NSInteger limitLoc = [limit integerValue];
        
        if (!artist || startLoc >= [[artist TrackSet] count])
        {
            *response = [[NSArray alloc] init];
            return YES;
        }
        
        if (limitLoc + startLoc > [[artist TrackSet] count])
        {
            limitLoc = [[artist TrackSet] count] - startLoc;
        }
        
        NSRange range = NSMakeRange(startLoc, limitLoc);
        *response = [[[artist TrackSet] allObjects] subarrayWithRange: range];
        return YES;
    }
    return NO;
}

-(BOOL) getTracksByAlbum:(NSNumber *)request
                 Response:(NSArray **)response
                    Start:(NSNumber *)start
                    Limit:(NSNumber *)limit
{
    AMAPIITAlbum *album;
    if ([self getFirstAlbumWithBlock:^(AMAPIITAlbum *album, BOOL *matched) {
        *matched = ([request isEqualTo:[album ID]]);
    }
                        matchedAlbum:&album
                  sortedByDescriptors:[AMAPIHandlerITunes albumSortDescriptors]])
    {
        NSInteger startLoc = [start integerValue];
        NSInteger limitLoc = [limit integerValue];
        
        if (!album || startLoc >= [[album TrackSet] count])
        {
            *response = [[NSArray alloc] init];
            return YES;
        }
        
        if (limitLoc + startLoc > [[album TrackSet] count])
        {
            limitLoc = [[album TrackSet] count] - startLoc;
        }
        
        NSRange range = NSMakeRange(startLoc, limitLoc);
        *response = [[[[album TrackSet] allObjects] sortedArrayUsingDescriptors:[AMAPIHandlerITunes trackSortDescriptors]]subarrayWithRange: range];
        return YES;
    }
    return NO;
}

-(BOOL) getAlbumsByArtist:(NSNumber *)request
                 Response:(NSArray **)response
                    Start:(NSNumber *)start
                    Limit:(NSNumber *)limit
{
    AMAPIITArtist *artist;
    if ([self getFirstArtistWithBlock:^(AMAPIITArtist *artist, BOOL *matched) {
        *matched = ([request isEqualTo:[artist ID]]);
    }
                        matchedArtist:&artist
                  sortedByDescriptors:[AMAPIHandlerITunes artistSortDescriptors]])
    {
        NSInteger startLoc = [start integerValue];
        NSInteger limitLoc = [limit integerValue];
        
        if (!artist || startLoc >= [[artist AlbumSet] count])
        {
            *response = [[NSArray alloc] init];
            return YES;
        }
        
        if (limitLoc + startLoc > [[artist AlbumSet] count])
        {
            limitLoc = [[artist AlbumSet] count] - startLoc;
        }
        
        NSRange range = NSMakeRange(startLoc, limitLoc);
        *response = [[[artist AlbumSet] allObjects] subarrayWithRange: range];
        return YES;
        
    }
    return NO;
}

-(BOOL) getTracksResponse:(NSArray **)response
                    Start:(NSNumber *)start
                    Limit:(NSNumber *)limit
{
    return [self matchTracksWithBlock:^(AMAPIITTrack *track, BOOL *matched) {
        *matched = YES;
    }
                              matches:response
                  sortedByDescriptors:[AMAPIHandlerITunes trackSortDescriptors]
                        startPosition:start
                           countLimit:limit];
}

-(BOOL) getAlbumsResponse:(NSArray **)response
                   Start:(NSNumber *)start
                   Limit:(NSNumber *)limit
{
    return [self matchAlbumsWithBlock:^(AMAPIITAlbum *album, BOOL *matched) {
        *matched = YES;
    }
                              matches:response
                  sortedByDescriptors:[AMAPIHandlerITunes albumSortDescriptors]
                        startPosition:start
                           countLimit:limit];
}

-(BOOL) getArtistsResponse:(NSArray **)response
                    Start:(NSNumber *)start
                    Limit:(NSNumber *)limit
{
    return [self matchArtistsWithBlock:^(AMAPIITArtist *artist, BOOL *matched) {
        *matched = YES;
    }
                               matches:response
                   sortedByDescriptors:[AMAPIHandlerITunes artistSortDescriptors]
                         startPosition:start
                            countLimit:limit];
}

-(BOOL) convertTrackByID:(NSString *)request
                Response:(AMAPIConvertTrackResponse **)response
{
    BOOL result = NO;
    AMAPIITTrack *track = nil;
    *response = [[AMAPIConvertTrackResponse alloc] init];
    if ([self getTrackByID:request Response:&track])
    {
        if ([track Location])
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
            NSString *applicationSupportDirectory = [paths firstObject];
            NSString *fileName = [NSString stringWithFormat:@"%@", [track ID]];
            [*response setFileName:fileName];
            NSURL *output = [[[NSURL fileURLWithPath:applicationSupportDirectory] URLByAppendingPathComponent:@"AMMusicServer"] URLByAppendingPathComponent:fileName];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:[output path]])
            {
                result = [AMAudioConverter ConvertToM4A:[NSURL URLWithString:[track Location]] output:output];
            }
            else
            {
                result = YES;
            }
            
            if (result)
            {
                [[AMGlobalObjects PersistentData] addCachedTrack:fileName AtLocation:output];
            }
            else
            {
                [[NSFileManager defaultManager] removeItemAtPath:[output path] error:nil];
            }
        }
    }
    result ? [*response setResult:@"Success"] : [*response setResult:@"Error"];
    return result;
}

@end
