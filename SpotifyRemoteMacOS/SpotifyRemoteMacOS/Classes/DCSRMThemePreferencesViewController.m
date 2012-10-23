//
//  DCSRMServerPreferencesViewController.m
//  SpotifyRemoteMacOS
//
//  Created by Boy van Amstel on 09-08-12.
//  Copyright (c) 2012 Danger Cove. All rights reserved.
//

#import "DCSRMThemePreferencesViewController.h"

#import "DCPreferencesManager.h"
#import "NSView+DisableSubviews.h"

#import "DCSRThemeLocation.h"

@interface DCSRMThemePreferencesViewController ()

@end

@implementation DCSRMThemePreferencesViewController

- (id)init
{
    return [super initWithNibName:@"DCSRMThemePreferencesView" bundle:nil];
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"DCSRMThemePreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameColorPanel];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Theme", @"Toolbar item name for the Theme preference pane");
}

- (void)updateBackgroundImage {
    NSImage *background;
    if([[DCPreferencesManager instance] hasCustomWebPath]) {
        NSString *webPath = [[DCPreferencesManager instance] webPath];
        NSString *imgPath = [webPath stringByAppendingPathComponent:@"bg.png"];
        background = [[NSImage alloc] initWithContentsOfFile:imgPath];
    } else {
        background = [NSImage imageNamed:@"bg.png"];
    }
    [_imgBackground setImage:background];
}

- (void)enableAdvancedTheming {
    [_boxAdvanced disableSubviews:NO];
    [_boxAdvanced setTitle:NSLocalizedString(@"Advanced Theming Box Enabled", nil)];
    [[DCPreferencesManager instance].preferences setBool:YES forKey:@"enableAdvancedServerTheming"];
    [[DCPreferencesManager instance] save];
    [self updateBackgroundImage];
}

- (void)disableAdvancedTheming {
    [_boxAdvanced disableSubviews:YES];
    [_boxAdvanced setTitle:NSLocalizedString(@"Advanced Theming Box Disabled", nil)];    
    [[DCPreferencesManager instance].preferences setBool:NO forKey:@"enableAdvancedServerTheming"];
    [[DCPreferencesManager instance] save];
    [self updateBackgroundImage];
}

- (void)insertThemeLocation:(DCSRThemeLocation *)newLocation {
    BOOL exists = NO;
    for(DCSRThemeLocation *location in _themeLocations) {
        if([[[location url] path] isEqualToString:[[newLocation url] path]]) {
            exists = YES;
        }
    }
    if(exists == NO) {
        [_btnThemeLocation.menu insertItem:[newLocation menuItem] atIndex:0];
        [_themeLocations insertObject:newLocation atIndex:0];
        [_btnThemeLocation selectItemAtIndex:0];
        [self updateBackgroundImage];
    }
}

#pragma mark -
#pragma mark NSViewController

- (void)viewWillAppear {
    if(!_themeLocations) {
        _themeLocations = [[NSMutableArray alloc] initWithCapacity:2]; // Should be enough
        
        NSString *appPath = [[NSBundle mainBundle] bundlePath];
        DCSRThemeLocation *appLocation = [[DCSRThemeLocation alloc] initWithName:[NSString stringWithFormat:NSLocalizedString(@"%@ (default)", nil), [[appPath lastPathComponent] stringByDeletingPathExtension]]
                                                                         andURL:nil
                                                                         andIcon:[[NSWorkspace sharedWorkspace] iconForFile:appPath]];
        [self insertThemeLocation:appLocation];
        
        if([[DCPreferencesManager instance] hasCustomWebPath]) {
            NSURL *webURL = [[DCPreferencesManager instance] webURL];
            DCSRThemeLocation *customLocation = [[DCSRThemeLocation alloc] initWithName:[[[webURL path] lastPathComponent] stringByDeletingPathExtension]
                                                                                andURL:webURL
                                                                                andIcon:[[NSWorkspace sharedWorkspace] iconForFile:[webURL path]]];
            
            [self insertThemeLocation:customLocation];
        }
    }
    
    _txtWelcome.stringValue = [[DCPreferencesManager instance].preferences stringForKey:@"serverWelcomeText"];
    
    [self updateBackgroundImage];
    
    if([[DCPreferencesManager instance] hasCustomWebPath]) {
        [self enableAdvancedTheming];
    } else {
        [self disableAdvancedTheming];
    }
}

- (IBAction)themeLocationDidChange:(id)sender {
    if(sender != _itmSelectThemeLocation) {
        float index = [sender indexOfSelectedItem];
        DCSRThemeLocation *themeLocation = [_themeLocations objectAtIndex:index];
        [[DCPreferencesManager instance] setWebURL:[themeLocation url]];
        
        if([[DCPreferencesManager instance] hasCustomWebPath]) {
            [self enableAdvancedTheming];
        } else {
            [self disableAdvancedTheming];
        }
    }
}

- (IBAction)selectThemeLocation:(id)sender {
    [_btnThemeLocation selectItemAtIndex:0]; // Reset menu
    
    _themePathPanel = [NSOpenPanel openPanel];
    [_themePathPanel setCanChooseDirectories:YES];
    [_themePathPanel setCanChooseFiles:NO];
    [_themePathPanel setCanCreateDirectories:YES];
    [_themePathPanel setPrompt:NSLocalizedString(@"Select theme path", nil)];
    
    [_themePathPanel beginSheetModalForWindow:[self.view window] completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSArray *files = [_themePathPanel URLs];
            _newThemeURL = [files objectAtIndex:0];

            // Hide file picker
            [_themePathPanel orderOut:_themePathPanel];

            // Check folder for index.html
            if([[NSFileManager defaultManager] fileExistsAtPath:[[_newThemeURL path] stringByAppendingPathComponent:@"index.html"] isDirectory:NO]) {
                // Theme exists
//                _existingThemeFolderAlert = [[NSAlert alloc] init];
//                [_existingThemeFolderAlert setAlertStyle:NSWarningAlertStyle];
//                [_existingThemeFolderAlert setMessageText:NSLocalizedString(@"EXISTING_THEME_FOLDER_TITLE", nil)];
//                [_existingThemeFolderAlert setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"EXISTING_THEME_FOLDER_MESSAGE", nil), [_newThemeURL path]]];
//                [_existingThemeFolderAlert addButtonWithTitle:NSLocalizedString(@"CONFIRM", nil)];
//                [_existingThemeFolderAlert addButtonWithTitle:NSLocalizedString(@"OPEN_IN_FINDER", nil)];
//                [_existingThemeFolderAlert addButtonWithTitle:NSLocalizedString(@"CANCEL", nil)];
//                
//                [_existingThemeFolderAlert beginSheetModalForWindow:self.view.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
                
                // Just select the folder
                [self saveSelectedURL:_newThemeURL];
            } else {
                // Show alert to copy folder
                _newThemeFolderAlert = [[NSAlert alloc] init];
                [_newThemeFolderAlert setAlertStyle:NSWarningAlertStyle];
                [_newThemeFolderAlert setMessageText:NSLocalizedString(@"NEW_THEME_FOLDER_TITLE", nil)];
                [_newThemeFolderAlert setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"NEW_THEME_FOLDER_MESSAGE", nil), [_newThemeURL path]]];
                [_newThemeFolderAlert addButtonWithTitle:NSLocalizedString(@"COPY_FILES", nil)];
                [_newThemeFolderAlert addButtonWithTitle:NSLocalizedString(@"CANCEL", nil)];
                
                [_newThemeFolderAlert beginSheetModalForWindow:self.view.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
            }
        }
    }];
}

- (IBAction)selectBackground:(id)sender {
    _backgroundPathPanel = [NSOpenPanel openPanel];
    [_backgroundPathPanel setCanChooseDirectories:NO];
    [_backgroundPathPanel setCanChooseFiles:YES];
    [_backgroundPathPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"png", @"tiff", @"jpg", @"gif", @"jpeg", nil]];
    
    [_backgroundPathPanel beginSheetModalForWindow:[self.view window] completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSArray *files = [_backgroundPathPanel URLs];
            NSURL *bgURL = [files objectAtIndex:0];
            
            // copy file
            if ([[NSFileManager defaultManager] isReadableFileAtPath:[bgURL path]]) {
                NSString *webPath = [[DCPreferencesManager instance] webPath];
                NSString *imgPath = [webPath stringByAppendingPathComponent:@"bg.png"];
                
                NSImage *background = [[NSImage alloc] initWithContentsOfURL:bgURL];
                NSData *data = [[[background representations] objectAtIndex:0] representationUsingType: NSPNGFileType properties:nil];
                [data writeToFile:imgPath atomically:NO];
                
                [_imgBackground setImage:background];
            }
        }
    }];
}

#pragma mark -
#pragma mark NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)obj {
    if (obj.object == _txtWelcome) {
        if ([_txtWelcome.stringValue length] > 3) {
            [[DCPreferencesManager instance].preferences setObject:_txtWelcome.stringValue forKey:@"serverWelcomeText"];
            [[DCPreferencesManager instance] save];
        }
    }
}

#pragma mark -
#pragma mark NSAlerts

- (void)saveSelectedURL:(NSURL *)url {
    [[DCPreferencesManager instance] setWebURL:url];
    
    DCSRThemeLocation *newLocation = [[DCSRThemeLocation alloc] initWithName:[[[url path] lastPathComponent] stringByDeletingPathExtension]
                                                                      andURL:url
                                                                     andIcon:[[NSWorkspace sharedWorkspace] iconForFile:[url path]]];
    [self insertThemeLocation:newLocation];
    
    if([[DCPreferencesManager instance] hasCustomWebPath]) {
        [self enableAdvancedTheming];
    } else {
        [self disableAdvancedTheming];
    }
}

- (void)sheetDidEnd:(NSAlert *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    
    // New theme folder
    if(sheet == _newThemeFolderAlert) {
        if(returnCode == NSAlertFirstButtonReturn) {
            // Start copying files
            if([[DCPreferencesManager instance] copyDefaultThemeTo:[_newThemeURL path]]) {
                [self saveSelectedURL:_newThemeURL];
            } else {
                // TODO: Display error
            }
        }
    }
    
    // Existing theme folder
    if(sheet == _existingThemeFolderAlert) {
        if(returnCode == NSAlertFirstButtonReturn) {
            [self saveSelectedURL:_newThemeURL];
        } else if (returnCode == NSAlertSecondButtonReturn) {
            // Open in Finder
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:[NSArray arrayWithObject:_newThemeURL]];
        }
    }

    // Update interface
    if([[DCPreferencesManager instance] hasCustomWebPath]) {
        [self enableAdvancedTheming];
    } else {
        [self disableAdvancedTheming];
    }
}


@end
