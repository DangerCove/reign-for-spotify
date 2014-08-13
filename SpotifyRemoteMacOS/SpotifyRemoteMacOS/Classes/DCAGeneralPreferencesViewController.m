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
    return [super initWithNibName:@"DCAGeneralPreferencesViewApp" bundle:nil];
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
}

@end
