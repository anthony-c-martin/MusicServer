#import <Foundation/Foundation.h>

@interface HTTPResponse : NSObject

- ( id ) initWithResponseCode:(int) response_code;

- ( void ) setHeaderField:(NSString*) header_field
                  toValue:(NSString*) header_value;

- ( void ) setAllHeaders:(NSDictionary*) header_dict;

- ( void ) setBodyText:(NSString *) body_text;
- ( void ) setBodyData:(NSData   *) body_data;

- ( NSData       * ) serialize;

@end