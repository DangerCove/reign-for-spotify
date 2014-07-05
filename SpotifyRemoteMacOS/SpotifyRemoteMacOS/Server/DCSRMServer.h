//
//  DCSRMServer.h
//  SpotifyRemoteMacOS
//
//  Created by Boy van Amstel on 08-08-12.
//  Copyright (c) 2012 Danger Cove. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTTPServer;

@interface DCSRMServer : NSObject {
    HTTPServer *httpServer;
    NSNetService *netService;
}

- (BOOL)start;
- (void)stop;

- (BOOL)isRunning;

- (uint16)port;
- (NSString *)name;

@end
