//
//  DCSRHTTPDynamicFileResponse.h
//  SpotifyRemoteMacOS
//
//  Created by Boy van Amstel on 16-08-12.
//  Copyright (c) 2012 Danger Cove. All rights reserved.
//

#import "HTTPDynamicFileResponse.h"

@interface DCSRHTTPDynamicFileResponse : HTTPDynamicFileResponse {
    NSDictionary *_headers;
}

- (id)initWithFilePath:(NSString *)theFilePath forConnection:(HTTPConnection *)theConnection separator:(NSString *)theSeparatorStr replacementDictionary:(NSDictionary *)theDictionary withContentType:(NSString *)contentType andCache:(BOOL)theCache;

- (id)initWithFilePath:(NSString *)theFilePath forConnection:(HTTPConnection *)theConnection separator:(NSString *)theSeparatorStr replacementDictionary:(NSDictionary *)theDictionary withContentType:(NSString *)contentType;

@end
