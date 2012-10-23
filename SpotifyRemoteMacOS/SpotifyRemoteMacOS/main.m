//
//  main.m
//  SpotifyRemoteMacOS
//
//  Created by Boy van Amstel on 08-08-12.
//  Copyright (c) 2012 Danger Cove. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#ifdef MAC_APP_STORE
#import "receipt.h"
#endif

int main(int argc, char *argv[])
{
#ifdef MAC_APP_STORE
    #ifdef DEBUG
        return NSApplicationMain(argc, (const char **)argv);
    #else
        return CheckReceiptAndRun(argc, (const char **)argv);
    #endif
#else
    return NSApplicationMain(argc, (const char **)argv);
#endif
}
