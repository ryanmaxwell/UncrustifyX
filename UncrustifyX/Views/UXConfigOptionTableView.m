//
//  UXConfigOptionTableView.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 14/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXConfigOptionTableView.h"

@implementation UXConfigOptionTableView

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    if ([self.viewDelegate respondsToSelector:@selector(tableView:didUpdateFrame:)]) {
        [self.viewDelegate tableView:self
                      didUpdateFrame:newSize];
    }
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent {
    NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSInteger row = [self rowAtPoint:mousePoint];
    
    return (row != -1 && ![self.delegate tableView:self isGroupRow:row]) ? [super menuForEvent:theEvent] : nil;
}

- (BOOL)validateProposedFirstResponder:(NSResponder *)responder forEvent:(NSEvent *)event {
    if ([responder isKindOfClass:[NSTextField class]]) {
        return YES;
    }
    return [super validateProposedFirstResponder:responder forEvent:event];
}

@end
