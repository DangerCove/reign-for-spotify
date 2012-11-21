#import "DCSRSpotifyConnection.h"
#import "HTTPDynamicFileResponse.h"
#import "DCSRHTTPFileResponse.h"
#import "DCSRHTTPDynamicFileResponse.h"
#import "HTTPLogging.h"
#import "HTTPMessage.h"
#import "DCPreferencesManager.h"

#import "NSString+DataURI.h"
#import "NSData+Base64.h"

// Log levels: off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_OFF; // HTTP_LOG_LEVEL_WARN; // | HTTP_LOG_FLAG_TRACE;


@implementation DCSRSpotifyConnection

- (NSAppleEventDescriptor *)runAppleScript:(NSString *)scriptString {
    NSString *fullScript = [NSString stringWithFormat:
    @"tell application \"Spotify\"\n"
        "if it is running then\n"
            "%@\n"
        "end if\n"
    "end tell", scriptString];
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource: fullScript];
    NSAppleEventDescriptor *returnData = [script executeAndReturnError:nil];
    
    return returnData;
}

- (NSString *)retrieveTrackCover:(NSString *)track_id {
    if(track_id) {
        NSString *appCachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *cachePath = [appCachesPath stringByAppendingPathComponent:@"Covers"];
        NSError *createError;
        
        // Create cache folder
        if(![[NSFileManager defaultManager] isWritableFileAtPath:cachePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&createError];
            if(createError) {
                NSLog(@"Error creating cache folder: %@", [createError localizedDescription]);
            }
        }
        
        // Work with cache
        NSString *coverPath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"cover-%@.jpg", track_id]];
        if(![[NSFileManager defaultManager] isReadableFileAtPath:coverPath]) {
            
            // Clear cache
            NSError *clearError;
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachePath error:nil];
            for (NSString *file in files) {
                [[NSFileManager defaultManager] removeItemAtPath:[cachePath stringByAppendingPathComponent:file] error:&clearError];
                if (clearError) {
                    NSLog(@"%@",[clearError localizedDescription]);
                }
            }
            
            // Get image and store
            NSAppleEventDescriptor *returnCover = [self runAppleScript:@"set image_data to artwork of current track"];
            NSData *coverData = [returnCover data];
            if(coverData) {
                NSImage *imgCover = [[NSImage alloc] initWithData:coverData];
                
                NSBitmapImageRep *imgCoverRep = [[imgCover representations] objectAtIndex: 0];
                NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.5] forKey:NSImageCompressionFactor];

                NSData *imgCoverData = [imgCoverRep representationUsingType:NSJPEGFileType properties:imageProps];
                
                [imgCoverData writeToFile:coverPath atomically:YES];
                
                cachedCoverString = [[imgCoverData base64Encoding] jpgDataURIWithContent];
            }
        } else if(!cachedCoverString) {
            // Return cached image
            NSImage *cachedImage = [[NSImage alloc] initWithContentsOfFile:coverPath];
            NSBitmapImageRep *imgCachedCoverRep = [[cachedImage representations] objectAtIndex: 0];
            NSData *imgCachedCoverData = [imgCachedCoverRep representationUsingType:NSJPEGFileType properties:nil];
            cachedCoverString = [[imgCachedCoverData base64Encoding] jpgDataURIWithContent];
        }
    }
    if(!cachedCoverString || !track_id) {
        cachedCoverString = @"not_playing.jpg";
    }
    return cachedCoverString;
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	// Use HTTPConnection's filePathForURI method.
	// This method takes the given path (which comes directly from the HTTP request),
	// and converts it to a full path by combining it with the configured document root.
	// 
	// It also does cool things for us like support for converting "/" to "/index.html",
	// and security restrictions (ensuring we don't serve documents outside configured document root folder).
	
	NSString *filePath = [self filePathForURI:path];
	
	// Convert to relative path
	
	NSString *documentRoot = [config documentRoot];
	
	if (![filePath hasPrefix:documentRoot])
	{
		// Uh oh.
		// HTTPConnection's filePathForURI was supposed to take care of this for us.
		return nil;
	}
	
	NSString *relativePath = [filePath substringFromIndex:[documentRoot length]];

    if ([[relativePath pathExtension] isEqualToString:@"css"]) {
        DCSRHTTPFileResponse *response = [[DCSRHTTPFileResponse alloc] initWithFilePath:[self filePathForURI:path] forConnection:self withContentType:@"text/css"];
        return response;
    }
    if ([[relativePath pathExtension] isEqualToString:@"js"]) {
        DCSRHTTPFileResponse *response = [[DCSRHTTPFileResponse alloc] initWithFilePath:[self filePathForURI:path] forConnection:self withContentType:@"application/x-javascript"];
        return response;
    }
    
    if([[DCPreferencesManager instance].preferences boolForKey:@"allowForcedCommands"]) {
        BOOL commandPath = NO;
        if ([relativePath isEqualToString:@"/next"]) {
            [self runAppleScript:@"next track\n"];
            commandPath = YES;
        }
        if ([relativePath isEqualToString:@"/previous"]) {
            [self runAppleScript:@"previous track"];
            commandPath = YES;
        }
        if ([relativePath isEqualToString:@"/playpause"]) {
            [self runAppleScript:@"playpause track"];
            commandPath = YES;
        }
        if ([relativePath rangeOfString:@"/play-track/"].location != NSNotFound) {
            [self runAppleScript:[NSString stringWithFormat:@"play track \"%@\"\n", [relativePath substringFromIndex:12]]];
            commandPath = YES;
            path = [path substringToIndex:11];
        }
        if(commandPath == YES) {
            DCSRHTTPFileResponse *response = [[DCSRHTTPFileResponse alloc] initWithFilePath:[self filePathForURI:path] forConnection:self withContentType:@"text/plain" andCache:NO];
            return response;
        }
    }

    if ([relativePath isEqualToString:@"/nowplaying"]) {
        NSAppleEventDescriptor *returnArtist = [self runAppleScript:@"artist of current track as string"];
        NSString *artist = [returnArtist stringValue];

        NSAppleEventDescriptor *returnName = [self runAppleScript:@"name of current track as string"];
        NSString *name = [returnName stringValue];

        NSMutableDictionary *replacementDict = [NSMutableDictionary dictionaryWithCapacity:2];
        
        if(artist && name) {
            [replacementDict setObject:[NSString stringWithFormat:@"%@ - %@", artist, name] forKey:@"NOW_PLAYING"];
        } else {
            [replacementDict setObject:[NSString stringWithFormat:NSLocalizedString(@"Spotify is not playing", nil), artist, name] forKey:@"NOW_PLAYING"];
        }
        
        HTTPLogVerbose(@"%@[%p]: replacementDict = \n%@", THIS_FILE, self, replacementDict);
        
        DCSRHTTPDynamicFileResponse *response = [[DCSRHTTPDynamicFileResponse alloc] initWithFilePath:[self filePathForURI:path]
                                                   forConnection:self
                                                       separator:@"%%"
                                           replacementDictionary:replacementDict
                                                 withContentType:@"text/plain"
                                                 andCache:NO];
        return response;
    }

	if ([relativePath isEqualToString:@"/status"]) {
        NSAppleEventDescriptor *returnState = [self runAppleScript:@"player state as string"];
        NSString *state = [returnState stringValue];

        NSString *track_id;
        NSString *artist;
        NSString *name;
        NSString *album;
        NSInteger volume;
        NSInteger position;
        NSInteger duration;
        BOOL starred;
        NSString *url;
        NSString *cover;
        
        if(!state) {
            state = @"off";
            artist = @"";
            name = @"";
            album = @"";
            track_id = @"";
            url = @"";
            cover = [self retrieveTrackCover:nil];
        } else {
            NSAppleEventDescriptor *returnTrackID = [self runAppleScript:@"id of current track as string"];
            track_id = [returnTrackID stringValue];

            NSAppleEventDescriptor *returnArtist = [self runAppleScript:@"artist of current track as string"];
            artist = [returnArtist stringValue];
            
            NSAppleEventDescriptor *returnName = [self runAppleScript:@"name of current track as string"];
            name = [returnName stringValue];

            NSAppleEventDescriptor *returnAlbum = [self runAppleScript:@"album of current track as string"];
            album = [returnAlbum stringValue];
            
            NSAppleEventDescriptor *returnVolume = [self runAppleScript:@"sound volume as integer"];
            volume = [returnVolume int32Value];

            NSAppleEventDescriptor *returnPosition = [self runAppleScript:@"player position as integer"];
            position = [returnPosition int32Value];

            NSAppleEventDescriptor *returnDuration = [self runAppleScript:@"duration of current track as integer"];
            duration = [returnDuration int32Value];

            NSAppleEventDescriptor *returnStarred = [self runAppleScript:@"starred of current track as boolean"];
            starred = [returnStarred booleanValue];

            NSAppleEventDescriptor *returnURL = [self runAppleScript:@"spotify url of current track as string"];
            url = [returnURL stringValue];
            if(!url) url = @"";
            
            cover = [self retrieveTrackCover:track_id];
        }

        NSString *nowPlaying;
        if((!artist && !name) || ([artist isEqualToString:@""] && [name isEqualToString:@""])) {
            nowPlaying = NSLocalizedString(@"Spotify is not playing", nil);
        } else {
            nowPlaying = [NSString stringWithFormat:@"%@ - %@", artist, name];
        }
        
        NSDictionary *stateDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   state, @"state",
                                   track_id, @"track_id",
                                   artist, @"artist",
                                   name, @"name",
                                   album, @"album",
                                   [NSNumber numberWithInteger:volume], @"volume",
                                   [NSNumber numberWithInteger:position], @"position",
                                   [NSNumber numberWithInteger:duration], @"duration",
                                   [NSNumber numberWithBool:starred], @"starred",
                                   url, @"url",
                                   cover, @"cover",
                                   nowPlaying, @"now_playing",
                                   [NSNumber numberWithBool:[[DCPreferencesManager instance].preferences boolForKey:@"allowForcedCommands"]], @"allow_force",
                                   nil];
        
        NSError *error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:stateDict
                                                           options:0 error:&error];
        if(!error) {
            // TODO: Handle error
        }
        
		NSMutableDictionary *replacementDict = [NSMutableDictionary dictionaryWithCapacity:1]; // Increase if needed!
        
        [replacementDict setObject:[[NSString alloc] initWithData:jsonData
                                                         encoding:NSUTF8StringEncoding] forKey:@"PLAYER_STATE"];
		
		HTTPLogVerbose(@"%@[%p]: replacementDict = \n%@", THIS_FILE, self, replacementDict);
		
		DCSRHTTPDynamicFileResponse *response = [[DCSRHTTPDynamicFileResponse alloc] initWithFilePath:[self filePathForURI:path]
                                                   forConnection:self
                                                       separator:@"%%"
                                           replacementDictionary:replacementDict
                                                 withContentType:@"application/json"
                                                 andCache:NO];
        return response;
	}

	if ([relativePath isEqualToString:@"/index.html"])
	{
		HTTPLogVerbose(@"%@[%p]: Serving up dynamic content", THIS_FILE, self);
		
        NSAppleEventDescriptor *returnTrackID = [self runAppleScript:@"id of current track as string"];
        NSString *track_id = [returnTrackID stringValue];
        
        NSAppleEventDescriptor *returnArtist = [self runAppleScript:@"artist of current track as string"];
        NSString *artist = [returnArtist stringValue];
        
        NSAppleEventDescriptor *returnName = [self runAppleScript:@"name of current track as string"];
        NSString *name = [returnName stringValue];
		
        NSAppleEventDescriptor *returnURL = [self runAppleScript:@"spotify url of current track as string"];
        NSString *url = [returnURL stringValue];
        if(!url) url = @"#";

        NSString *cover = [self retrieveTrackCover:track_id];
        
        
		NSMutableDictionary *replacementDict = [NSMutableDictionary dictionaryWithCapacity:5];

        NSString *hostname = [[NSHost currentHost] localizedName];
        NSString *welcomeText = [[[DCPreferencesManager instance].preferences stringForKey:@"serverWelcomeText"] stringByReplacingOccurrencesOfString:@"%%hostname%%" withString:hostname];
        [replacementDict setObject:hostname forKey:@"PAGE_TITLE"];
		[replacementDict setObject:welcomeText forKey:@"WELCOME_TEXT"];
        [replacementDict setObject:cover forKey:@"TRACK_COVER"];
        
        if(artist && name) {
            [replacementDict setObject:[NSString stringWithFormat:@"%@ - %@", artist, name] forKey:@"NOW_PLAYING"];
        } else {
            [replacementDict setObject:NSLocalizedString(@"Spotify is not playing", nil) forKey:@"NOW_PLAYING"];
        }
        [replacementDict setObject:url forKey:@"SPOTIFY_URL"];
		
		HTTPLogVerbose(@"%@[%p]: replacementDict = \n%@", THIS_FILE, self, replacementDict);
		
		DCSRHTTPDynamicFileResponse *response = [[DCSRHTTPDynamicFileResponse alloc] initWithFilePath:[self filePathForURI:path]
		                                            forConnection:self
		                                                separator:@"%%"
		                                    replacementDictionary:replacementDict
                                                 withContentType:@"text/html"];
        return response;
	}
	
	return [super httpResponseForMethod:method URI:path];
}

@end
