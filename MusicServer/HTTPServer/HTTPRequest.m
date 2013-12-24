#import "HTTPRequest.h"
#import "HTTPMessage.h"

@implementation HTTPRequest
	
@synthesize headers = _headers;
@synthesize method  = _method;
@synthesize url     = _url;
@synthesize body    = _body;


- ( id ) initWithHTTPMessage:( HTTPMessage * ) http_message {

	if( (self = [super init]) ) {
		
		CFHTTPMessageRef request = [http_message request];
		
		_headers = (NSDictionary *)CFHTTPMessageCopyAllHeaderFields( request );
		_url     = (NSURL        *)CFHTTPMessageCopyRequestURL( request );
		_method  = (NSString     *)CFHTTPMessageCopyRequestMethod( request );
		_body    = (NSData       *)CFHTTPMessageCopyBody( request );
	}
	
	return self;
}

- (NSString*) getBodyAsText {
	return [[[NSString alloc] initWithData:_body
                                  encoding:NSUTF8StringEncoding]autorelease];
}// Hmm, that rather assumes UTF8, doesn't it ?


/*
   De-URLEncode an HTTP POST body
   NB that this really doesn't belong here, but is supplied for
   the purposes of demonstration, because there are quite enough
   classes to be going on with.
 */
-( NSDictionary *) urlDecodePostBody {
    

    
    NSMutableDictionary * kvPairs = [[NSMutableDictionary alloc]init];
    
    /* First, translate "+" to " ", then split by &
       using quite a fugly bit of code, sorry.
     */
    NSArray * queryComponents
    = [ [[self getBodyAsText] stringByReplacingOccurrencesOfString:@"+"
                                             withString:@" " ]
         componentsSeparatedByString:@"&"
       ];
    
    
    /*
     We replaced '+' signs above because application/x-www-form-urlencoded
     data (as in the POST body) encodes spaces as '+'
     instead of %20%. Handy, eh ?
     */
    for (NSString * kvPairString in queryComponents) {
        
        NSArray   * keyValuePair = [kvPairString componentsSeparatedByString:@"="];
        
        if( [keyValuePair count] != 2 ) { continue; }
        
        /*
         Similarly, we avoid using the NSString methods here
         because they don't encode or decode properly. Grr!
         */
        NSString * decoded_key
            = [(NSString*)CFURLCreateStringByReplacingPercentEscapes(
                                                                
                    NULL,
                    (CFStringRef)[keyValuePair objectAtIndex:0],
                    CFSTR("")
                )
               autorelease];
        
        
        NSString * decoded_value
            = [(NSString*)CFURLCreateStringByReplacingPercentEscapes(
                                                                    
                    NULL,
                    (CFStringRef)[keyValuePair objectAtIndex:1],
                    CFSTR("")
                )
               autorelease];
        
        
        [kvPairs setValue: decoded_value forKey: decoded_key ];
    }
    
    return [kvPairs autorelease];
}

-( void ) dealloc {

    [ _headers release ];
    [ _url     release ];
    [ _method  release ];
    [ _body    release ];
    [ super    dealloc ];
}

@end
