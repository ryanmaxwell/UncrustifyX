//
//  UXPreferencesWindow.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 2/12/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXPreferencesWindow.h"

@implementation UXPreferencesWindow

#pragma mark - NSResponder

- (void)keyDown:(NSEvent *)theEvent {
    if (theEvent.keyCode == 53) {
        [self close];
    } else {
        [super keyDown:theEvent];
    }
}

@end
