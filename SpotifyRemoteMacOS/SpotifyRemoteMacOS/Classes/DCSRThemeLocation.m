//
//  DCSRThemeLocation.m
//  SpotifyRemoteMacOS
//
//  Created by Boy van Amstel on 28-09-12.
//  Copyright (c) 2012 Danger Cove. All rights reserved.
//

#import "DCSRThemeLocation.h"

@implementation DCSRThemeLocation

- (id)initWithName:(NSString *)name andURL:(NSURL *)url andIcon:(NSImage *)icon {
    self = [super init];
    if(self) {
        _typeName = name;
        _url = url;
        _icon = icon;
    }
    return self;
}

- (NSString *)name {
    return [NSString stringWithFormat:@"%@", _typeName];
}

- (NSMenuItem *)menuItem {
    if(!_menuItem) {
        _menuItem = [[NSMenuItem alloc] init];
        [_menuItem setTitle:[self name]];
        [_menuItem setImage:_icon];
    }
    return _menuItem;
}

@end
