#import "HTTPFileResponse.h"

@class HTTPConnection;

// 
// This class is a UnitTest for the delayResponseHeaders capability of HTTPConnection
// 

@interface DCSRHTTPFileResponse : HTTPFileResponse {
    NSDictionary *_headers;
}

- (id)initWithFilePath:(NSString *)theFilePath forConnection:(HTTPConnection *)theConnection withContentType:(NSString *)theContentType andCache:(BOOL)theCache;

- (id)initWithFilePath:(NSString *)theFilePath forConnection:(HTTPConnection *)theConnection withContentType:(NSString *)theContentType;

@end
