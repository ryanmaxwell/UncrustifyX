//
//  UXTransientConfigOption.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 27/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXTransientConfigOption.h"
#import "UXOption.h"

@implementation UXTransientConfigOption

- (NSString *)configString {
    if (self.option && self.value.length) {
        return [NSString stringWithFormat:@"%@ = %@", self.option.code, self.value];
    }
    return nil;
}

@end
