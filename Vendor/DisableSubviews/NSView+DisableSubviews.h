//
//  NSView+DisableSubviews.h
//  DisableSubviews
//
//  Created by Ahmet Ardal on 5/6/12.
//  Copyright (c) 2012 SpinningSphere Labs. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSView(DisableSubviews)

- (void) disableSubviews:(BOOL)disable
                  filter:(BOOL (^)(NSView *v))filter;

- (void) disableSubviews:(BOOL)disable
                  ofType:(Class)type;

- (void) disableSubviews:(BOOL)disable
              inTagRange:(NSRange)range;

- (void) disableSubviews:(BOOL)disable
                startTag:(NSInteger)start
                  endTag:(NSInteger)end;

- (void) disableSubviews:(BOOL)disable
                withTags:(NSArray *)tags;

- (void) disableSubviews:(BOOL)disable
                  ofType:(Class)type
              inTagRange:(NSRange)range;

- (void) disableSubviews:(BOOL)disable
                  ofType:(Class)type
                withTags:(NSArray *)tags;

- (void) disableSubviews:(BOOL)disable;

@end
