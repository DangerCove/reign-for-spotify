//
//  DCSRMServer.m
//  SpotifyRemoteMacOS
//
//  Created by Boy van Amstel on 08-08-12.
//  Copyright (c) 2012 Danger Cove. All rights reserved.
//

#import "DCSRMServer.h"

#import "HTTPServer.h"
#import "DCSRSpotifyConnection.h"
#import "DDLog.h"

#import "DCPreferencesManager.h"

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_OFF;

@implementation DCSRMServer

- (id)init {
    self = [super init];
    if(self) {
        // Initalize our http server
        httpServer = [[HTTPServer alloc] init];
        
        // Tell server to use our custom MyHTTPConnection class.
        [httpServer setConnectionClass:[DCSRSpotifyConnection class]];
    }
    return self;
}

- (BOOL)start {
    // Tell the server to broadcast its presence via Bonjour.
    if([[DCPreferencesManager instance].preferences boolForKey:@"broadcastServer"]) {
        [httpServer setType:@"_reign._tcp."];
    } else {
        [httpServer setType:nil];
    }
    
    // Serve files from Music/Reign/Themes/Default our embedded Web folder
    NSString *webPath = [[DCPreferencesManager instance] webPath];
    DDLogVerbose(@"Setting document root: %@", webPath);
    [httpServer setDocumentRoot:webPath];
    
    // Launch on specific port
    if(![[DCPreferencesManager instance].preferences boolForKey:@"dynamicServerPort"]) {
        [httpServer setPort:[[DCPreferencesManager instance].preferences integerForKey:@"staticServerPort"]];
    } else {
        [httpServer setPort:0];
    }
    
    NSError *error;
    BOOL success = [httpServer start:&error];
    
    if(!success)
    {
        DDLogError(@"Error starting HTTP Server: %@", error);
    } else {
        
        // Broadcast on standard http bonjour service as well
        if([[DCPreferencesManager instance].preferences boolForKey:@"broadcastServer"]) {
            NSString *httpName = [[NSString alloc] initWithFormat:NSLocalizedString(@"Reign on %@", @"Displayed in the http Bonjour service name"), (__bridge NSString*)CSCopyMachineName()];
            netService = [[NSNetService alloc] initWithDomain:@"local." type:@"_http._tcp." name:httpName port:httpServer.port];
            [netService publish];
        }
    }
    return success;
}
- (void)stop {
    [httpServer stop];
    
    [netService stop];
    netService = nil;
}

- (BOOL)isRunning {
    return [httpServer isRunning];
}

- (uint16)port {
    return [httpServer listeningPort];
}
- (NSString *)name {
        return [httpServer name];
}


@end
