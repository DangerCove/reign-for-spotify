//
//  DCSRMClient.m
//  SpotifyRemoteMacOS
//
//  Created by Boy van Amstel on 08-08-12.
//  Copyright (c) 2012 Danger Cove. All rights reserved.
//

#import "DCSRMClient.h"
#import "GCDAsyncSocket.h"
#import "DDLog.h"
#import "DCSRMHost.h"

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_ERROR;

@implementation DCSRMClient

- (id)init {
    self = [super init];
    if(self) {
        // Setup browsing for bonjour services
        netServiceBrowser = [[NSNetServiceBrowser alloc] init];
        [netServiceBrowser setDelegate:self];
        //[self startScanning];
    }
    return self;
}

- (void)start {
    _services = [[NSMutableDictionary alloc] init];
    _hosts = [[NSMutableArray alloc] init];
	[netServiceBrowser searchForServicesOfType:@"_reign._tcp." inDomain:@"local."];
}
- (void)stop {
    [netServiceBrowser stop];
    [_services removeAllObjects];
    [_hosts removeAllObjects];
    _services = nil;
    _hosts = nil;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)sender didNotSearch:(NSDictionary *)errorInfo
{
	DDLogError(@"DidNotSearch: %@", errorInfo);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)sender
           didFindService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
{
	DDLogVerbose(@"DidFindService: %@", [netService name]);
    DCSRMHost *host = [[DCSRMHost alloc] initWithNetService:netService];
    [_hosts addObject:host];
    [_services setObject:host forKey:[NSString stringWithFormat:@"%li", netService.hash]];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)sender
         didRemoveService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
{
	DDLogVerbose(@"DidRemoveService: %@\n%li", [netService name], [netService hash]);
    NSString *key = [NSString stringWithFormat:@"%li", netService.hash];
    DCSRMHost *host = [_services objectForKey:key];
    if(host) {
        [_hosts removeObject:host];
    }
    [_services removeObjectForKey:key];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HostVanished" object:nil];
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)sender
{
	DDLogInfo(@"DidStopSearch");
}

@end
