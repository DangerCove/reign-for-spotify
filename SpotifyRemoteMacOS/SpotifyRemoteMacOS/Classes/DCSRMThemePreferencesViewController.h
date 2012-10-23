//
//  DCSRMServerPreferencesViewController.h
//  SpotifyRemoteMacOS
//
//  Created by Boy van Amstel on 09-08-12.
//  Copyright (c) 2012 Danger Cove. All rights reserved.
//

#import "MASPreferencesViewController.h"

@interface DCSRMThemePreferencesViewController : NSViewController <MASPreferencesViewController, NSControlTextEditingDelegate> {
    IBOutlet NSTextField *_txtWelcome;
    IBOutlet NSButton *_imgBackground;
    IBOutlet NSBox *_boxAdvanced;
    
    IBOutlet NSPopUpButton *_btnThemeLocation;
    IBOutlet NSMenuItem *_itmSelectThemeLocation;
    
    NSOpenPanel *_backgroundPathPanel;
    NSOpenPanel *_themePathPanel;
    
    NSMutableArray *_themeLocations;
    
    NSAlert *_newThemeFolderAlert;
    NSAlert *_existingThemeFolderAlert;
    
    NSURL *_newThemeURL;
}

@end
