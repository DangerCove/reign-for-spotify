#import <Foundation/Foundation.h>
#import "HTTPConnection.h"


@interface DCSRSpotifyConnection : HTTPConnection {
    NSString *cachedCoverString;
}

@end
