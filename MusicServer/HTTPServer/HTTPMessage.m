#import "HTTPMessage.h"
#import "HTTPRequest.h"

@implementation HTTPMessage {

}

@synthesize request = _request;

- ( id ) init {
    
    if( (self = [super init]) ) {
    
        _request = CFHTTPMessageCreateEmpty( NULL, TRUE );
    }
    
    return self;
}


- ( BOOL ) isRequestComplete:(NSData *) append_data {
    
    CFHTTPMessageAppendBytes( _request,
                             [append_data bytes],
                             [append_data length] );
    
    if( CFHTTPMessageIsHeaderComplete(_request) ) {
        
        NSString * content_hdr
            = [(NSString *)CFHTTPMessageCopyHeaderFieldValue(
                                                        
                                                _request,
                                                 CFSTR("Content-Length") )
                                                 autorelease];
        
        
        NSData * body  = [(NSData *)CFHTTPMessageCopyBody( _request )
                          autorelease];
        
        int     content_length = [content_hdr intValue];
        
        if( [body length] >= content_length ) {
            return YES;
        }
    }
    
    return NO;
}



- ( void ) dealloc {

    CFRelease(_request);
    [super dealloc];
}

@end