//
//  DCSRMClient.h
//  SpotifyRemoteMacOS
//
//  Created by Boy van Amstel on 08-08-12.
//  Copyright (c) 2012 Danger Cove. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCSRMHost.h"

@class GCDAsyncSocket;

@interface DCSRMClient : NSObject <NSNetServiceBrowserDelegate> {
    NSNetServiceBrowser *netServiceBrowser;
	NSNetService *serverService;
	NSMutableArray *serverAddresses;
	GCDAsyncSocket *asyncSocket;
}

@property (strong) NSMutableDictionary *services;
@property (strong) NSMutableArray *hosts;

- (void)start;
- (void)stop;

@end
