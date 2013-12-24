#import "TCPSocket.h"

@implementation TCPSocket {
    
    int               _sock_ref;
    NSUInteger        _port;
    dispatch_source_t _source;
}

@synthesize port   = _port;
@synthesize socket = _sock_ref;


/*
 Use the standard low level TCP sockets API to create 
 and bind a TCP socket
 */
- ( id ) initWithPort:( uint16_t ) port {
    
    if( (self = [super init]) ) {
        
        _sock_ref = socket( PF_INET, SOCK_STREAM, IPPROTO_TCP );
        
        struct sockaddr_in addr = {
            
                   sizeof(addr),
                   AF_INET,
                   htons(port),
                   { INADDR_ANY },
                   { 0 }
              };
        
        int yes = 1;
        
        setsockopt(
                     _sock_ref,
                     SOL_SOCKET,
                     SO_REUSEADDR,
                     (void *)&yes,
                     sizeof(yes)
                   
                   );
        
        bind( _sock_ref, (void *)&addr, sizeof(addr) );
        
        _port = port; // NB that if port == 0, this will be true until listen()
                      // is called, at which point the actual port number is set.
    }
    
    return self;
    
}

/*
  Call the TCP sockets 'listen' to make the socket, er, listen,
  on a port. So far so standard. But after that we set it as a
  GCD dispatch source ...
 
  Returns the number of the port.
 
 */
- ( NSUInteger ) listen:( dispatch_block_t ) block {
    
    listen( _sock_ref, 2 );
    
    struct sockaddr_in addr;
    
    unsigned int addrlen = sizeof( addr );
    
    getsockname( _sock_ref, (struct sockaddr*)&addr, &addrlen );
    
    _port = ntohs(addr.sin_port);    
    
    /*
      ... set the listening socket to be a GCD dispatch source,
     so that when it recieves data it will dispatch it using
     the block we passed as a parameter.
     */
    _source = dispatch_source_create(
                                   
                                   DISPATCH_SOURCE_TYPE_READ,
                                   _sock_ref,
                                   0,
                                   dispatch_get_global_queue(0, 0)
                               );
    
    dispatch_source_set_event_handler( _source, block );
    dispatch_resume( _source );
    
    return _port;
}


/* 
  Wrap a native socket reference in a TCPSocket class
*/
- ( id ) initWithNativeSocket:(int)         socket
                fromTCPSocket:(TCPSocket *) tcp_sock
{
    
    if( (self = [super init]) ) {
        
        _sock_ref = socket;
        _port     = tcp_sock.port;
    }
    
    return self;
}


/*
 
 Called by client if it wishes to accept a connection
 indicated by a dispatch from this object.
 
 Returns a listening socket instance that can read and written.
 
*/
- ( TCPSocket * ) accept  {
    
    struct sockaddr addr;
    socklen_t       addrlen        = sizeof(addr);
    int             listening_sock = accept(_sock_ref, &addr, &addrlen);
    
    TCPSocket * listening_tcp_sock
        = [[TCPSocket alloc] initWithNativeSocket:listening_sock
                                    fromTCPSocket:self];
    
    return [listening_tcp_sock autorelease];
}

- ( void ) stopDispatch {
    dispatch_source_cancel( _source );
    dispatch_release( _source );
    close( _sock_ref );
}

@end