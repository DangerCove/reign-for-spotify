#import "NSString+DataURI.h"

@implementation NSString(DataURI)

- (NSString *) pngDataURIWithContent;
{
    NSString * result = [NSString stringWithFormat: @"data:image/png;base64,%@", self];
    return result;
}

- (NSString *) jpgDataURIWithContent;
{
    NSString * result = [NSString stringWithFormat: @"data:image/jpg;base64,%@", self];
    return result;
}

@end