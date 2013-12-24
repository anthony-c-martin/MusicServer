#import <Foundation/Foundation.h>

@class HTTPResponse;

@interface HttpService : NSObject

@property (nonatomic, assign) id responder;

- ( void ) startServiceOnPort:(NSUInteger) port;


- ( void ) stopService;

@end
