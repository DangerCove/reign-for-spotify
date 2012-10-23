//
//  PreferencesManager.h
//  TreasureChestAirPlay
//
//  Created by Boy van Amstel on 30-11-11.
//  Copyright (c) 2011 Boy van Amstel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCPreferencesManager : NSObject {
    NSUserDefaults *preferences;
}

+ (DCPreferencesManager *)instance;

- (void)load;
- (void)save;
- (BOOL)isFirstRun;

- (NSURL *)webURL;
- (NSString *)webPath;
- (void)setWebURL:(NSURL *)url;
- (BOOL)hasCustomWebPath;

- (BOOL)copyDefaultThemeTo:(NSString *)path;

@property (strong) NSUserDefaults *preferences;

@end
