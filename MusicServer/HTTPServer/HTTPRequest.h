#import <Foundation/Foundation.h>
@class HTTPMessage;

@interface HTTPRequest : NSObject

@property (readonly) NSDictionary * headers;
@property (readonly) NSString     * method;
@property (readonly) NSURL        * url;
@property (readonly) NSData       * body;
	

- ( NSString * ) getBodyAsText;
- ( id         ) initWithHTTPMessage:( HTTPMessage * ) http_message;

@end
