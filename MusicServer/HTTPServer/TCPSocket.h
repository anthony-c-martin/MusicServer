#import <Foundation/Foundation.h>

#import <sys/socket.h>
#import <netinet/in.h>

@interface TCPSocket : NSObject 

@property (readonly) NSUInteger port;
@property (readonly) int socket;

- ( NSUInteger  ) listen:(dispatch_block_t) block;
- ( id          ) initWithPort:( uint16_t ) port;
- ( TCPSocket * ) accept;
- ( void        ) stopDispatch;
@end
