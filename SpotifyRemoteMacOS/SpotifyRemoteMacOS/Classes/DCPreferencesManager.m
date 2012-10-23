//
//  PreferencesManager.m
//  TreasureChestAirPlay
//
//  Created by Boy van Amstel on 30-11-11.
//  Copyright (c) 2011 Boy van Amstel. All rights reserved.
//

#import "DCPreferencesManager.h"

@implementation DCPreferencesManager

@synthesize preferences;

static DCPreferencesManager *gInstance;

+ (DCPreferencesManager *)instance {
    @synchronized(self) {
        if (gInstance == NULL) {
            gInstance = [[self alloc] init];
        }
    }
    
    return(gInstance);
}

# pragma mark -
# pragma mark Singleton methods

- (id)init {
    if(self = [super init]) {
        preferences = [NSUserDefaults standardUserDefaults];
        [self load];
    }
    return self;
}

- (void)load {
    NSString *file = [[NSBundle mainBundle] 
                      pathForResource:@"Defaults" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:file];
    [preferences registerDefaults:dict];        
}
- (void)save {
    [preferences synchronize];
}

- (BOOL)isFirstRun {
    // Setup defaults and show preferences if this is the first time we run the app
    if(![preferences boolForKey:@"setupDone"]) {
        
        // No longer first run
        [preferences setBool:YES forKey:@"setupDone"];
        [self save];
        
        return YES;
    }
    return NO;
}

- (NSURL *)webURL {
    NSData *bookmarkedURL = [self.preferences dataForKey:@"themePath"];
    
    if(bookmarkedURL != nil) {
        BOOL bookmarkDataIsStale;
        NSError *error = nil;
        
        NSURL *webUrl = [NSURL URLByResolvingBookmarkData:bookmarkedURL
                                                  options:NSURLBookmarkResolutionWithSecurityScope
                                            relativeToURL:nil
                                      bookmarkDataIsStale:&bookmarkDataIsStale
                                                    error:&error];

        if(error) {
            NSLog(@"Failed to load theme path: %@", [error localizedDescription]);
        }
        [webUrl startAccessingSecurityScopedResource];

        return webUrl;
    }
    return nil;
}

- (NSString *)webPath {
    NSURL *webUrl = [self webURL];
    
    if(!webUrl || ![[NSFileManager defaultManager] fileExistsAtPath:[[webUrl path] stringByAppendingPathComponent:@"index.html"] isDirectory:NO]) {
        return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
    } else {
        return [webUrl path];
    }
}

- (void)setWebURL:(NSURL *)url {
    // Changing paths so stop using the previous one
    NSURL *pastURL = [self webURL];
    if(pastURL) {
        [pastURL stopAccessingSecurityScopedResource];
    }
    
    if(url == nil) {
        [[DCPreferencesManager instance].preferences setValue:nil forKey:@"themePath"];
    } else {
        NSData *bookmarkData = nil;
        NSError *error = nil;

        bookmarkData = [url
                        bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope
                        includingResourceValuesForKeys:nil
                        relativeToURL:nil
                        error:&error];
        
        if(error) {
            NSLog(@"Failed to set theme path: %@", [error localizedDescription]);
        } else {
            [[DCPreferencesManager instance].preferences setValue:bookmarkData forKey:@"themePath"];
        }
    }
    [[DCPreferencesManager instance] save];
}

- (BOOL)hasCustomWebPath {
    return !([[self webPath] isEqualToString:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"]] || [self webPath] == nil);
}

- (BOOL)copyDefaultThemeTo:(NSString *)path {
    if(path) {
        NSString *bundleWebPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
        NSError *copyError;

        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundleWebPath error:nil];
        for (NSString *file in files) {
            [[NSFileManager defaultManager] copyItemAtPath:[bundleWebPath stringByAppendingPathComponent:file] toPath:[path stringByAppendingPathComponent:file] error:&copyError];

            if (copyError) {
                NSLog(@"%@",[copyError localizedDescription]);
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

@end
