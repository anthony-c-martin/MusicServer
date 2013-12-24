#import "HttpService.h"
#import "TCPSocket.h"
#import "HTTPRequest.h"
#import "HTTPResponse.h"
#import "HTTPMessage.h"

@implementation HttpService {
    TCPSocket * _sock;
}
@synthesize responder = _responder;


-( void ) doResponse:( HTTPRequest  * ) request
            onSocket:( NSFileHandle * ) socket
{
 
    /*
        Here, we're going to check for a matching method signature
        along the lines of :
        
     - ( HTTPResponse * ) POST:( HTTPRequest * ) request
     
       (Or, GET ... or whatever other HTTP request methods 
       you want to support)
     
       On the responder class. If it exists we'll call it with the 
       relevant parameters, if not, we'll send a '405, huh ?' message.
     
     */
     HTTPResponse * response = nil;
    
    NSString * method_signature
        = [NSString stringWithFormat:@"%@:",request.method];
    
    SEL selector = NSSelectorFromString( method_signature );
    
    if( [_responder respondsToSelector:selector] ) {
        
        response = [_responder performSelector:selector
                                    withObject:request];
    }
    else {
        /*
         If we get a request we don't understand, we should at
         least tip our hat towards the standards and send a
         'not supported' response
         */
        response = [[[HTTPResponse alloc] initWithResponseCode:405]
                    autorelease];
        
        [response setBodyText:[NSString stringWithFormat:@"%@ method not supported",
                               request.method]];
    }
    
    [socket writeData:[response serialize]];
    
}
/*
- ( void ) sendResponse:( HTTPResponse * ) response
               onSocket:( NSFileHandle * ) socket
{
        [socket writeData:[response serialize]];
}
*/

/*  Now for the meat in this sandwich!
    When we set our TCP socket to listen for incoming
    connections, we will set a block to execute the
    following method, passing its instance here
    so that we can call accept ...
 
 */
- ( void ) gotConnectionOnSocket:(TCPSocket*) sock {
    
    /* 
      ... which gives us a live, connected socket that
      we can talk to ...
    */
    TCPSocket * live = [sock accept];
    
    /*
       ... which we set up as another dispatch source ...
     */
    dispatch_source_t source = dispatch_source_create(
                                                      
                                   DISPATCH_SOURCE_TYPE_READ,
                                   live.socket,
                                   0,
                                   dispatch_get_global_queue(0, 0)
                               );
    
    
    
    __block HTTPMessage * http_message = [[HTTPMessage alloc]init] ;
    
    __block NSFileHandle * sock_handle
                = [[NSFileHandle alloc] initWithFileDescriptor:live.socket];
    
    
    /* every time our socket gets some data, run a block to
       process it. When the request transmission is complete, 
       we dispatch another block to handle responding.
    */
    dispatch_source_set_event_handler( source, ^{
        
        if( [http_message isRequestComplete: [sock_handle availableData]] ) {
            
            dispatch_source_cancel( source );
            dispatch_release( source );
                
            HTTPRequest * http_request
                = [[HTTPRequest alloc] initWithHTTPMessage:http_message];
        
            
            [http_message  release];
            
            dispatch_async( dispatch_get_global_queue( 0, 0 ), ^{

                [self doResponse:http_request onSocket:sock_handle];
                
                [http_request  release];
                [sock_handle closeFile];
                [sock_handle   release];
                
            });
            
        } // if( [http_message ...
        
    } ); // dispatch_source ...
    
    dispatch_resume( source );
}


/*
    And so now, starting our weeny web server is as easy
    as calling this method with a port number.
    Erm, probably should have built in a mechanism to stop.
 */
- ( void ) startServiceOnPort:(NSUInteger) port {
    
    _sock = [[TCPSocket alloc] initWithPort:port];
    
    [_sock listen:^{ [self gotConnectionOnSocket:_sock];}];
}

- ( void ) stopService {
    [_sock stopDispatch];
}

@end

