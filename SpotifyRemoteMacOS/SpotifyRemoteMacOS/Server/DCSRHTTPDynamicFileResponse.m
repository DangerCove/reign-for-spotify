//
//  DCSRHTTPDynamicFileResponse.m
//  SpotifyRemoteMacOS
//
//  Created by Boy van Amstel on 16-08-12.
//  Copyright (c) 2012 Danger Cove. All rights reserved.
//

#import "DCSRHTTPDynamicFileResponse.h"

@implementation DCSRHTTPDynamicFileResponse

- (id)initWithFilePath:(NSString *)theFilePath forConnection:(HTTPConnection *)theConnection separator:(NSString *)theSeparatorStr replacementDictionary:(NSDictionary *)theDictionary withContentType:(NSString *)theContentType andCache:(BOOL)theCache {
    
    self = [super initWithFilePath:theFilePath forConnection:theConnection separator:theSeparatorStr replacementDictionary:theDictionary];
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

- (id)initWithFilePath:(NSString *)theFilePath forConnection:(HTTPConnection *)theConnection separator:(NSString *)theSeparatorStr replacementDictionary:(NSDictionary *)theDictionary withContentType:(NSString *)theContentType {
    
    return [self initWithFilePath:theFilePath forConnection:theConnection separator:theSeparatorStr replacementDictionary:theDictionary withContentType:theContentType andCache:YES];
}

- (NSDictionary *)httpHeaders {
    return _headers;
}

@end
