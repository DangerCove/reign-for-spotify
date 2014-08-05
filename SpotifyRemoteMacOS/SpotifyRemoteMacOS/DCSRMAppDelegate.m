//
//  DCSRMAppDelegate.m
//  SpotifyRemoteMacOS
//
//  Created by Boy van Amstel on 08-08-12.
//  Copyright (c) 2012 Danger Cove. All rights reserved.
//

#import "DCSRMAppDelegate.h"

#import "DDLog.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"

#import "DCSRMHost.h"

#include <IOKit/pwr_mgt/IOPM.h>
#include <IOKit/pwr_mgt/IOPMLib.h>

#import "DCPreferencesManager.h"
#import "DCAGeneralPreferencesViewController.h"
#import "DCSRMThemePreferencesViewController.h"
#import "DCSRMServerPreferencesViewController.h"
#import "MASPreferencesWindowController.h"

@implementation DCSRMAppDelegate

- (void)wake {
    // Start service again
    if([[DCPreferencesManager instance].preferences boolForKey:@"autostartServer"]) {
        [self startServer:nil];
    }
//    [_client start];
}
- (void)gotoSleep {
    // Stop service browser
    [self stopServer:nil];
//    [_client stop];
}

/* perform actions on receipt of power notifications */
void PowerCallback (void *lRootPort, io_service_t y,
                    natural_t msgType, void *msgArgument)
{
    switch (msgType)
    {
        case kIOMessageSystemWillSleep: {
            /* perform sleep actions */
            DCSRMAppDelegate *app = (DCSRMAppDelegate *)[[NSApplication sharedApplication] delegate];
            [app gotoSleep];
            break;
        }
        case kIOMessageSystemHasPoweredOn: {
            /* perform wakeup actions */
            DCSRMAppDelegate *app = (DCSRMAppDelegate *)[[NSApplication sharedApplication] delegate];
            [app wake];
            break;
        }
        case kIOMessageSystemWillRestart:
            /* perform restart actions */
            break;
            
        case kIOMessageSystemWillPowerOff:
            /* perform shutdown actions */
            break;
    }
    IOAllowPowerChange( rootPort, (long)msgArgument );
}

- (void)updateStatusMenu:(NSNotification *)notification {
    for(NSMenuItem *menuItem in [_statusMenu itemArray]) {
        if([menuItem tag] == HOST_MENUITEM_TAG) {
            [_statusMenu removeItem:menuItem];
        }
    }
    for(DCSRMHost *host in _client.hosts) {
        if([host isAvailable]) {
            [_statusMenu insertItem:host.menuItem atIndex:HOST_MENUITEM_INDEX];
        }
    }
    [_statusMenu update];
}

- (NSString *)externalAddress {
    for(NSString *address in [[NSHost currentHost] addresses]) {
        NSString *ipRegEx =
        @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
        NSPredicate *ipTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", ipRegEx];
        if(![address hasPrefix:@"127"] &&[ipTest evaluateWithObject:address]) {
            return address;
        }
    }
    return [[NSHost currentHost] name];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    // Tap into system sleep and wake
    IONotificationPortRef notificationPort;
    io_object_t notifier;
    
    rootPort = IORegisterForSystemPower(NULL, &notificationPort,
                                        PowerCallback, &notifier);
    if (!rootPort)
        exit (1);
    
    CFRunLoopAddSource (CFRunLoopGetCurrent(),
                        IONotificationPortGetRunLoopSource(notificationPort),
                        kCFRunLoopDefaultMode);
    
    // Configure logging framework
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    // Setup defaults and show preferences if this is the first time we run the app
    if([[DCPreferencesManager instance] isFirstRun]) {
        // Show the preferences window
        [self showPreferencesWindow:nil];
    }

    // Status bar menu
    [_statusMenu setDelegate:self];
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    _statusImage = [NSImage imageNamed:@"icon_status"];
    [_statusImage setTemplate:YES];
    
    _statusActiveImage = [NSImage imageNamed:@"icon_status-active"];
    [_statusActiveImage setTemplate:YES];
    
    [_statusItem setImage:_statusImage];
    [_statusItem setMenu:_statusMenu];
    [_statusItem setToolTip:NSLocalizedString(@"Menu bar icon mouse over", nil)];
    [_statusItem setHighlightMode:YES];

    // Setup HTTP Server
    _server = [[DCSRMServer alloc] init];
    if([[DCPreferencesManager instance].preferences boolForKey:@"autostartServer"]) {
        [self startServer:nil];
    }
    
    // Setup Client
    _client = [[DCSRMClient alloc] init];
    [_client start];
    
    // Listen for hosts
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateStatusMenu:)
                                                 name:@"HostAvailable"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateStatusMenu:)
                                                 name:@"HostVanished"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applyServerChange)
                                                 name:@"ServerPortChanged"
                                               object:nil];
    
    
}

- (void)applyServerChange {
    if([_server isRunning]) {
        [self stopServer:nil];
        [self performSelector:@selector(startServer:) withObject:nil afterDelay:1.0];
    }
}
- (IBAction)startServer:(id)sender {
    if([_server start]) {
        [_statusItem setImage:_statusActiveImage];
    } else {
        // Server failed to start
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert setMessageText:NSLocalizedString(@"SERVER_FAILED_TO_START_TITLE", nil)];
        [alert setInformativeText:NSLocalizedString(@"SERVER_FAILED_TO_START_MESSAGE", nil)];
        [alert runModal];
    }
}
- (IBAction)stopServer:(id)sender {
    // TODO: Check if server actually stops
    [_server stop];
    [_statusItem setImage:_statusImage];
}
- (IBAction)toggleServer:(id)sender {
    if([_server isRunning]) {
        [self stopServer:nil];
    } else {
        [self startServer:nil];
    }
}
- (IBAction)copyServerToClipboard:(id)sender {
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard clearContents];
    [pasteBoard writeObjects:[NSArray arrayWithObject:[NSString stringWithFormat:@"%@:%i", [self externalAddress], _server.port]]];
}
- (IBAction)sendServerViaEmail:(id)sender {
    NSString *mailString = [NSString stringWithFormat:@"mailto:?&subject=%@&body=%@",
                            [NSLocalizedString(@"EMAIL_TITLE", nil) stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                            [[NSString stringWithFormat:NSLocalizedString(@"EMAIL_BODY", nil), [self externalAddress], _server.port] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:mailString]];
}

- (IBAction)openHelpCenter:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://reignalot.com/support"]];
}

- (void)menuWillOpen:(NSMenu *)menu {
    for(DCSRMHost *host in _client.hosts) {
        if([host isAvailable]) {
            [host update];
        }
    }
    
    if([_server isRunning]) {
        [_serverStatusItem setState:NSOnState];
        [_serverStatusItem setEnabled:YES];
        [_toggleServerItem setTitle:NSLocalizedString(@"Stop Server", nil)];
        [_serverStatusItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Running at %@:%i", nil), [self externalAddress], _server.port]];
    } else {
        [_serverStatusItem setState:NSOffState];
        [_serverStatusItem setEnabled:NO];
        [_toggleServerItem setTitle:NSLocalizedString(@"Start Server", nil)];
        [_serverStatusItem setTitle:NSLocalizedString(@"Server is offline", nil)];
    }
}

#pragma mark -
#pragma mark MASPreferences

- (NSWindowController *)preferencesWindowController {
    if (_preferencesWindowController == nil)
    {
        NSViewController *generalViewController = [[DCAGeneralPreferencesViewController alloc] init];
        NSViewController *serverViewController = [[DCSRMServerPreferencesViewController alloc] init];
        NSViewController *themeViewController = [[DCSRMThemePreferencesViewController alloc] init];
        NSArray *controllers = [[NSArray alloc] initWithObjects:generalViewController, serverViewController, themeViewController, nil];
        
        // To add a flexible space between General and Advanced preference panes insert [NSNull null]:
        //     NSArray *controllers = [[NSArray alloc] initWithObjects:generalViewController, [NSNull null], advancedViewController, nil];
        
        NSString *title = NSLocalizedString(@"Preferences", @"Common title for Preferences window");
        _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers title:title];
    }
    return _preferencesWindowController;
}

- (IBAction)showPreferencesWindow:(id)sender {
    [self.preferencesWindowController showWindow:nil];
    [NSApp activateIgnoringOtherApps:YES]; // Actively ignore other apps
}

- (IBAction)showAboutWindow:(id)sender {
    NSDictionary *options = [NSDictionary
                           dictionaryWithObjectsAndKeys:@"Credits", @"Credits.rtf",
                           nil];
    
    [[NSApplication sharedApplication] orderFrontStandardAboutPanelWithOptions:options];
    [NSApp activateIgnoringOtherApps:YES];
}


// Just to be sure
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
