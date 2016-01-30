//
//  AMHTTPMusicServer.m
//  MusicServer
//
//  Created by Anthony Martin on 02/04/2014.
//  Copyright (c) 2014 Anthony Martin. All rights reserved.
//

#import "AMHTTPMusicServer.h"
#import "AMJSONResponder.h"
#import "AMMusicServerActiveData.h"
#import <GCDWebServers/GCDWebServer.h>
#import <GCDWebServers/GCDWebServerDataRequest.h>
#import <GCDWebServers/GCDWebServerDataResponse.h>
#import <GCDWebServers/GCDWebServerFileResponse.h>
#import <GCDWebServers/GCDWebServerErrorResponse.h>

@implementation AMHTTPMusicServer
{
    GCDWebServer *webServer;
}

@synthesize responder;

-(id)initWithResponder:(AMJSONResponder *)jsonResponder
{
    self = [super init];
    if (self)
    {
        webServer = [[GCDWebServer alloc] init];
        [self setResponder:jsonResponder];
        [self setRequestQueue:dispatch_queue_create("AMHTTPMusicServer", NULL)];
        __weak typeof(self) weakSelf = self;
        
        [webServer addGETHandlerForBasePath:@"/"
                              directoryPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"dist"]
                              indexFilename:@"index.html"
                                   cacheAge:86400
                         allowRangeRequests:NO];
        
        [webServer addHandlerForMethod:@"GET"
                                  path:@"/stream"
                          requestClass:[GCDWebServerRequest class]
                          processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                              
                              __strong typeof(self) strongSelf = weakSelf;
                              BOOL authorised = NO;
                              NSString *queryFilename;
                              NSString *querySession;
                              
                              
                              if ([request query] &&
                                  [[request query] valueForKey:@"FileName"] &&
                                  [[request query] valueForKey:@"Session"])
                              {
                                  queryFilename = [[request query] valueForKey:@"FileName"];
                                  querySession = [[request query] valueForKey:@"Session"];
                                  authorised = [[self responder] validateSession:querySession];
                              }
                              
                              if (authorised)
                              {
                                  NSURL *fileURL = [[[strongSelf responder] activeData] getCachedTrackLocation:queryFilename];
                                  if (fileURL != nil)
                                  {
                                      NSString *filePath = [fileURL path];
                                      return [GCDWebServerFileResponse responseWithFile:filePath byteRange:request.byteRange];
                                  }
                                  
                                  return [[GCDWebServerErrorResponse alloc] initWithStatusCode:404];
                              }
                              
                              return [[GCDWebServerErrorResponse alloc] initWithStatusCode:404];

                          }];
        
        [webServer addHandlerForMethod:@"POST"
                                  path:@"/api"
                          requestClass:[GCDWebServerDataRequest class]
                     asyncProcessBlock:^(GCDWebServerRequest* request, GCDWebServerCompletionBlock completionBlock) {
                         
                         __strong typeof(self) strongSelf = weakSelf;
                         GCDWebServerDataRequest *dataRequest = (GCDWebServerDataRequest *)request;
                         dispatch_async([strongSelf requestQueue], ^{
                             NSData *responseData;
                             NSInteger responseCode;
                             if ([[strongSelf responder] handleRequest:[dataRequest data]
                                                          responseData:&responseData
                                                          responseCode:&responseCode
                                                         connectedHost:[request remoteAddressString]])
                             {
                                 completionBlock([GCDWebServerDataResponse responseWithData:responseData contentType:@"application/json"]);
                             }
                             else
                             {
                                 completionBlock([[GCDWebServerErrorResponse alloc] initWithStatusCode:responseCode]);
                             }
                         });
                         
                     }];
    }
    return self;
}

-(void)start
{
    [webServer startWithPort:12345 bonjourName:nil];
}

-(void)stop
{
    [webServer stop];
}

@end