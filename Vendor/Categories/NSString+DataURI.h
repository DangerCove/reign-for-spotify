// Source: http://stackoverflow.com/questions/5329648/display-local-uiimage-on-uiwebview

#import <Foundation/Foundation.h>

@interface NSString(DataURI)
- (NSString *) pngDataURIWithContent;
- (NSString *) jpgDataURIWithContent;
@end