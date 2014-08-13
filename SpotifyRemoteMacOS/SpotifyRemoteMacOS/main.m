//
//  main.m
//  SpotifyRemoteMacOS
//
//  Created by Boy van Amstel on 08-08-12.
//  Copyright (c) 2012 Danger Cove. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#ifndef DEBUG
    // Receigen automatically defines DEBUG, so removes those lines from receipt.h!!
    #include "receipt.h"
#endif

int main(int argc, char *argv[])
{
#ifndef DEBUG
    return CheckReceiptAndRun(argc, (const char **)argv);
#endif
    NSLog(@"Running in debug mode");    
    return NSApplicationMain(argc, (const char **)argv);
}