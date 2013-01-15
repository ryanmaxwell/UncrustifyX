//
//  UXSearchGradientView.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 27/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXSearchGradientView.h"

@interface UXSearchGradientView ()
@property (strong, nonatomic) NSImage *searchGradient;

@end

@implementation UXSearchGradientView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _searchGradient = [NSBundle.mainBundle imageForResource:@"SearchGradient.png"];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    NSDrawThreePartImage(self.bounds, nil, self.searchGradient, nil, NO, NSCompositeSourceOver, 1.0, NO);
}

@end
