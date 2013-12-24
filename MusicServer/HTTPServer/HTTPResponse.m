#import "HTTPResponse.h"

@implementation HTTPResponse {
	CFHTTPMessageRef      _response;
}

- ( id ) initWithResponseCode:(int) response_code {
	
    if( (self = [super init]) ) {
        
		_response = CFHTTPMessageCreateResponse(
                                                
                        NULL,
                        response_code,
                        NULL,
                        kCFHTTPVersion1_1
                    );
	}
	
    return self;
}

- ( id ) init {

	if( (self = [super init]) ) {
        
		_response = CFHTTPMessageCreateResponse(
                                                
                        NULL,
                        200,
                        NULL,
                        kCFHTTPVersion1_1
                    );
	}
	
    return self;
}

- ( void ) setHeaderField:(NSString*) header_field toValue:(NSString*) header_value {
	
    CFHTTPMessageSetHeaderFieldValue(
        
        _response,
        (CFStringRef)header_field,
        (CFStringRef)header_value
    );
    
}


- ( void ) setAllHeaders:(NSDictionary*) header_dict {
	
	for( NSString * key in [header_dict allKeys] ) {
		CFHTTPMessageSetHeaderFieldValue(

            _response,
		    (CFStringRef)key,
			(CFStringRef)[header_dict valueForKey:key]
		);
	}
}

- ( void ) setBodyText:(NSString*) body_text {
	
    CFHTTPMessageSetHeaderFieldValue(
    
        _response,
        CFSTR("Content-Type"),
        CFSTR("text/html")
    );
	
    CFHTTPMessageSetBody(
                         
        _response,
        (CFDataRef)[body_text dataUsingEncoding:NSUTF8StringEncoding]
    );

}

- ( void ) setBodyData:(NSData*) body_data {
		
    CFHTTPMessageSetBody( _response, (CFDataRef) body_data );
}

- ( NSData * ) serialize {
	
    return [(NSData*)
            CFHTTPMessageCopySerializedMessage( _response )
            autorelease];
}

- ( void ) dealloc {
    
    CFRelease( _response );
    [super dealloc];
}
@end
