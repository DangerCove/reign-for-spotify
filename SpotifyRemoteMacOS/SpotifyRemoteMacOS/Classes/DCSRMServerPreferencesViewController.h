//
//  DCSRMServerPreferencesViewController.h
//  SpotifyRemoteMacOS
//
//  Created by Boy van Amstel on 09-08-12.
//  Copyright (c) 2012 Danger Cove. All rights reserved.
//

#import "MASPreferencesViewController.h"

@interface DCSRMServerPreferencesViewController : NSViewController <MASPreferencesViewController, NSControlTextEditingDelegate> {
    NSString *_lastStaticPort;
    IBOutlet NSTextField *_txtStaticPort;
}

@end
