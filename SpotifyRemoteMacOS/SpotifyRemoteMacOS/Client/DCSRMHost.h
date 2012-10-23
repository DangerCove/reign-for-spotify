//
//  DCSRMHost.h
//  SpotifyRemoteMacOS
//
//  Created by Boy van Amstel on 08-08-12.
//  Copyright (c) 2012 Danger Cove. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HOST_MENUITEM_TAG 666
#define HOST_MENUITEM_INDEX 4

@class GCDAsyncSocket;

@interface DCSRMHost : NSObject <NSNetServiceDelegate, NSURLConnectionDataDelegate> {
    NSNetService *_netService;
    
//    GCDAsyncSocket *_asyncSocket;

    NSMutableArray *_hostAddresses;
    NSMutableArray *_ipv4addresses;
    NSMutableArray *_ipv6addresses;
    
    BOOL _available;
    BOOL _ipv4;

    NSURLConnection *_infoConnection;
    NSMutableData *_infoData;
}

@property (nonatomic, strong, readonly) NSString *host;
@property (nonatomic, strong, readonly) NSString *host6;
@property (nonatomic, assign, readonly) UInt16 port;
@property (nonatomic, strong, readonly) NSMenuItem *menuItem;

- (id)initWithNetService:(NSNetService *)theNetService;
- (void)makeAvailable;
- (BOOL)isAvailable;
- (void)update;

- (NSString *)baseUrlString;

@end
