//
//  UXConfigOptionTableView.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 14/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXConfigOptionTableView.h"

@implementation UXConfigOptionTableView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    if ([self.viewDelegate respondsToSelector:@selector(tableView:didUpdateFrame:)]) {
        [self.viewDelegate tableView:self
                      didUpdateFrame:newSize];
    }
}

@end
