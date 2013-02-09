//
//  UXMainWindow.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 9/02/13.
//  Copyright (c) 2013 Ryan Maxwell. All rights reserved.
//

#import "UXMainWindow.h"

@implementation UXMainWindow

#pragma mark - NSResponder

- (void)keyDown:(NSEvent *)theEvent {
    NSLog(@"%d", theEvent.keyCode);
    
    if (theEvent.keyCode == 117) {
        /* DEL Key */
        [UXAPPDELEGATE deletePressed:self];
    } else {
        [super keyDown:theEvent];
    }
}

@end
