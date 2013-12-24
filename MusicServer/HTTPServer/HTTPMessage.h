#import <Foundation/Foundation.h>

@interface HTTPMessage : NSObject

@property (nonatomic, readonly) CFHTTPMessageRef request;

- ( BOOL ) isRequestComplete:(NSData *) append_data;

@end
