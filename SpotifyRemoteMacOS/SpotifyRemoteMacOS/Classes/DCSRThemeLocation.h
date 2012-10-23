//
//  DCSRThemeLocation.h
//  SpotifyRemoteMacOS
//
//  Created by Boy van Amstel on 28-09-12.
//  Copyright (c) 2012 Danger Cove. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCSRThemeLocation : NSObject {
    NSString *_typeName;
    NSMenuItem *_menuItem;
}

@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSURL *url;
@property(nonatomic, readonly) NSImage *icon;

- (NSMenuItem *)menuItem;

- (id)initWithName:(NSString *)name andURL:(NSURL *)path andIcon:(NSImage *)icon;

@end
