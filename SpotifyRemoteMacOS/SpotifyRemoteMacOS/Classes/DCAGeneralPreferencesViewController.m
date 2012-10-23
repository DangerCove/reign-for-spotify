//
//  DCBLPreferencesViewController.m
//  Borg
//
//  Created by Boy van Amstel on 01-08-12.
//  Copyright (c) 2012 Danger Cove. All rights reserved.
//

#import "DCAGeneralPreferencesViewController.h"

#import <ServiceManagement/ServiceManagement.h>
#import "DCPreferencesManager.h"

@interface DCAGeneralPreferencesViewController ()

@end

@implementation DCAGeneralPreferencesViewController

- (id)init
{
#ifdef MAC_APP_STORE
    return [super initWithNibName:@"DCAGeneralPreferencesViewApp" bundle:nil];
#else
    return [super initWithNibName:@"DCAGeneralPreferencesView" bundle:nil];
#endif
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"DCSRMGeneralPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"General", @"Toolbar item name for the General preference pane");
}

#pragma mark -
#pragma mark NSViewController

- (void)viewWillAppear {
    // Startup at login
    _startAtLoginController = [[StartAtLoginController alloc] init];
	[_startAtLoginController setBundle:[NSBundle bundleWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Library/LoginItems/ReignHelper.app"]]];
}

#pragma mark -
#pragma mark Preferences

- (IBAction)toggleStartup:(id)sender {
    bool enableStartup = [[NSUserDefaults standardUserDefaults] boolForKey:@"enableStartup"];
    [_startAtLoginController setStartAtLogin:enableStartup];
}

@end
