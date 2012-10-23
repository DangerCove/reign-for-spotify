#import "DCSRHTTPFileResponse.h"
#import "HTTPConnection.h"
#import "HTTPLogging.h"

// Log levels: off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_OFF; // | HTTP_LOG_FLAG_TRACE;

// 
// This class is a UnitTest for the delayResponseHeaders capability of HTTPConnection
// 

@implementation DCSRHTTPFileResponse

- (id)initWithFilePath:(NSString *)theFilePath forConnection:(HTTPConnection *)theConnection withContentType:(NSString *)theContentType andCache:(BOOL)theCache {
    
    self = [super initWithFilePath:theFilePath forConnection:theConnection];
    if(self) {
        if(theCache == YES) {
            _headers = [NSDictionary dictionaryWithObject:theContentType forKey:@"Content-Type"];
        } else {
            _headers = [NSDictionary dictionaryWithObjectsAndKeys:
                        theContentType, @"Content-Type",
                        @"no-store, no-cache, must-revalidate, max-age=0", @"Cache-Control",
                        @"no-cache", @"Pragma",
                        nil];
        }
    }
    return self;
}


- (id)initWithFilePath:(NSString *)theFilePath forConnection:(HTTPConnection *)theConnection withContentType:(NSString *)theContentType {
    
    return [self initWithFilePath:theFilePath forConnection:theConnection withContentType:theContentType andCache:YES];
}

- (NSDictionary *)httpHeaders {
    return _headers;
}

@end
