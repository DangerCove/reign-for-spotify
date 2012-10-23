//
//  NSView+DisableSubviews.m
//  DisableSubviews
//
//  Created by Ahmet Ardal on 5/6/12.
//  Copyright (c) 2012 SpinningSphere Labs. All rights reserved.
//

#import "NSView+DisableSubviews.h"

@implementation NSView(DisableSubviews)

- (void) disableSubviews:(BOOL)disable
                  filter:(BOOL (^)(NSView *v))filter
{
    if (!filter) {
        filter = ^BOOL (NSView *v) { return YES; };
    }

    for (NSView *v in self.subviews) {
        [v disableSubviews:disable filter:filter];
        if (filter(v) && [v respondsToSelector:@selector(setEnabled:)]) {
            ((NSControl *) v).enabled = !disable;
        }
    }
}

- (void) disableSubviews:(BOOL)disable
                  ofType:(Class)type
{
    [self disableSubviews:disable
                   filter:^BOOL (NSView *v) {
                       return [v isKindOfClass:type];
                   }];
}

- (void) disableSubviews:(BOOL)disable
              inTagRange:(NSRange)range
{
    [self disableSubviews:disable
                   filter:^BOOL (NSView *v) {
                       return NSLocationInRange(v.tag, range);
                   }];
}

- (void) disableSubviews:(BOOL)disable
                startTag:(NSInteger)start
                  endTag:(NSInteger)end
{
    [self disableSubviews:disable
               inTagRange:NSMakeRange(start, (end - start + 1))];
}

- (void) disableSubviews:(BOOL)disable
                withTags:(NSArray *)tags
{
    [self disableSubviews:disable
                   filter:^BOOL (NSView *v) {
                       return [tags containsObject:[NSNumber numberWithInteger:v.tag]];
                   }];
}

- (void) disableSubviews:(BOOL)disable
                  ofType:(Class)type
              inTagRange:(NSRange)range
{
    [self disableSubviews:disable
                   filter:^BOOL (NSView *v) {
                       return [v isKindOfClass:type] && NSLocationInRange(v.tag, range);
                   }];
}

- (void) disableSubviews:(BOOL)disable
                  ofType:(Class)type
                withTags:(NSArray *)tags
{
    [self disableSubviews:disable
                   filter:^BOOL (NSView *v) {
                       return [v isKindOfClass:type] &&
                              [tags containsObject:[NSNumber numberWithInteger:v.tag]];
                   }];
}

- (void) disableSubviews:(BOOL)disable
{
    [self disableSubviews:disable filter:nil];
}

@end
