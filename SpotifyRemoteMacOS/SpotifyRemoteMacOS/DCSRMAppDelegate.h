//
//  DCSRMAppDelegate.h
//  SpotifyRemoteMacOS
//
//  Created by Boy van Amstel on 08-08-12.
//  Copyright (c) 2012 Danger Cove. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DCSRMServer.h"
#import "DCSRMClient.h"

static io_connect_t rootPort;
void PowerCallback (void *lRootPort, io_service_t y,
                    natural_t msgType, void *msgArgument);

@interface DCSRMAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate> {
    // HTTP Server
    DCSRMServer *_server;
    
    // Client
    DCSRMClient *_client;
    
    // Menu bar
    IBOutlet NSMenu *_statusMenu;
    NSStatusItem *_statusItem;
    NSImage *_statusImage;
    NSImage *_statusActiveImage;
    
    IBOutlet NSMenuItem *_serverStatusItem;
    IBOutlet NSMenu *_serverStatusMenu;
    IBOutlet NSMenuItem *_toggleServerItem;
    
    // General preferences
    NSWindowController *_preferencesWindowController;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)startServer:(id)sender;
- (IBAction)stopServer:(id)sender;
- (IBAction)toggleServer:(id)sender;

- (IBAction)showPreferencesWindow:(id)sender;
- (IBAction)showAboutWindow:(id)sender;
- (IBAction)copyServerToClipboard:(id)sender;
- (IBAction)sendServerViaEmail:(id)sender;

@end
