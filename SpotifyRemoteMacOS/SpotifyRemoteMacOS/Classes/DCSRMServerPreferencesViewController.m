//
//  DCSRMServerPreferencesViewController.m
//  SpotifyRemoteMacOS
//
//  Created by Boy van Amstel on 09-08-12.
//  Copyright (c) 2012 Danger Cove. All rights reserved.
//

#import "DCSRMServerPreferencesViewController.h"

#import "DCPreferencesManager.h"

@interface DCSRMServerPreferencesViewController ()

@end

@implementation DCSRMServerPreferencesViewController

- (id)init
{
    return [super initWithNibName:@"DCSRMServerPreferencesView" bundle:nil];
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"DCSRMServerPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameNetwork];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Server", @"Toolbar item name for the Server preference pane");
}

#pragma mark -
#pragma mark NSViewController

- (IBAction)saveDynamicServerPort:(id)sender {
//    if([[DCPreferencesManager instance].preferences boolForKey:@"dynamicServerPort"]) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"ServerPortChanged" object:nil];
//    } else {
//    }
}
    
- (void)viewWillAppear {
    [_txtStaticPort setStringValue:[NSString stringWithFormat:@"%li", [[DCPreferencesManager instance].preferences integerForKey:@"staticServerPort"]]];
}

- (IBAction)saveStaticServerPort:(id)sender {
//    if([_txtStaticPort.stringValue length] > 3 && [_txtStaticPort.stringValue integerValue] > 1024 && [_txtStaticPort.stringValue integerValue] < 65535) {
        [[DCPreferencesManager instance].preferences setInteger:[_txtStaticPort.stringValue integerValue] forKey:@"staticServerPort"];
        [[DCPreferencesManager instance] save];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"ServerPortChanged" object:nil];
//    }
//    else {
//        [_txtStaticPort setStringValue:[NSString stringWithFormat:@"%li", [[DCPreferencesManager instance].preferences integerForKey:@"staticServerPort"]]];
//    }
}

#pragma mark -
#pragma mark NSTextField

// Make sure the user has typed a valid number so far.
- (void)controlTextDidBeginEditing:(NSNotification *)obj {
    if (obj.object == _txtStaticPort) {
        _lastStaticPort = _txtStaticPort.stringValue;
    }
}
- (void)controlTextDidChange:(NSNotification *)obj {
    if (obj.object == _txtStaticPort) {
        if ([_txtStaticPort.stringValue length] > 0) {
            if([[NSNumberFormatter alloc] numberFromString:_txtStaticPort.stringValue] > 0) {
                _lastStaticPort = _txtStaticPort.stringValue;
                [self saveStaticServerPort:nil];
            } else {
                _txtStaticPort.stringValue = _lastStaticPort;
            }
        }
    }
}

@end
