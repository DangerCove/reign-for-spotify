//
//  DCSRMHost.m
//  SpotifyRemoteMacOS
//
//  Created by Boy van Amstel on 08-08-12.
//  Copyright (c) 2012 Danger Cove. All rights reserved.
//

#import "DCSRMHost.h"
#import "DDLog.h"
#import "GCDAsyncSocket.h"

#include <arpa/inet.h>

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_ERROR;

@implementation DCSRMHost

- (id)initWithNetService:(NSNetService *)theNetService {
    self = [super self];
    if(self) {
        _ipv4addresses = [[NSMutableArray alloc] init];
        _ipv6addresses = [[NSMutableArray alloc] init];

        _netService = theNetService;
        [_netService setDelegate:self];
        [_netService resolveWithTimeout:5.0];
        
        _available = NO;
        _ipv4 = NO;
    }
    return self;
}

- (NSString *)baseUrlString {
    NSString *urlString;
    if(_ipv4) {
        urlString = [NSString stringWithFormat:@"http://%@:%i", _host, _port];
    } else {
        urlString = [NSString stringWithFormat:@"http://[%@]:%i", _host6, _port];
    }
    return urlString;
}

- (void)update {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[[self baseUrlString] stringByAppendingString:@"/nowplaying"]]];
    
    _infoData = [[NSMutableData alloc] init];
    _infoConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(connection == _infoConnection) {
        NSString *responsestring = [[[NSString alloc] initWithData:_infoData encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:
                                    [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if([responsestring isNotEqualTo:@""]) {
            [_menuItem setTitle:[NSString stringWithFormat:@"%@ (%@)", [_netService name], responsestring]];
        } else {
            [_menuItem setTitle:[NSString stringWithFormat:@"%@", [_netService name]]];
        }
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_infoData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    DDLogInfo(@"DidFailWithError");
    if(_ipv4) {
        _ipv4 = NO;
        [self update];
    }
}

- (void)makeAvailable {
    _available = YES;
    
    _menuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@", [_netService name]] action:@selector(openController:) keyEquivalent:@""];
    [_menuItem setTarget:self];
    [_menuItem setTag:HOST_MENUITEM_TAG];
    [self update];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HostAvailable" object:nil];
}
- (BOOL)isAvailable {
    return _available;
}

- (IBAction)openController:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[self baseUrlString]]];
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
	DDLogInfo(@"DidNotResolve");
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
	DDLogInfo(@"DidResolve: %@", [sender addresses]);
    
    // Discover addresses
    for(NSData *data in [sender addresses]) {
        struct sockaddr_in* socketAddress = (struct sockaddr_in*) [data bytes];
        int sockFamily = socketAddress->sin_family;
        
        // Only add ipv4 and ipv6 addresses
        if (sockFamily == AF_INET || sockFamily == AF_INET6) {
            switch(sockFamily) {
                case AF_INET: {
                    [_ipv4addresses addObject:data];
                    break;
                }
                case AF_INET6: {
                    [_ipv6addresses addObject:data];
                    break;
                }
            }
        }
    }
    
    // Set default IPv6 address
    if([_ipv6addresses count] > 0) {
        NSData *address6 = [_ipv6addresses objectAtIndex:0];

        struct sockaddr_in6 addr6;

        if ([address6 length] == sizeof(addr6)) {
            [address6 getBytes:&addr6 length:sizeof(addr6)];
            
            char str6[INET6_ADDRSTRLEN];
            inet_ntop(AF_INET6, &(addr6.sin6_addr), str6, INET6_ADDRSTRLEN);
            
            _host6 = [NSString stringWithUTF8String:str6];
            _port = ntohs(addr6.sin6_port);
        }
    }

    // Set default IPv4 address
    if([_ipv4addresses count] > 0) {
        NSData *address = [_ipv4addresses objectAtIndex:0];
    
        struct sockaddr_in addr4;

        if ([address length] == sizeof(addr4)) {
            [address getBytes:&addr4 length:sizeof(addr4)];
            
            char str[INET_ADDRSTRLEN];
            inet_ntop(AF_INET, &(addr4.sin_addr), str, INET_ADDRSTRLEN);
            
            _host = [NSString stringWithUTF8String:str];
            _port = ntohs(addr4.sin_port);
            _ipv4 = YES;
        }
    }
        
    // All done
    [self makeAvailable];
}

@end
