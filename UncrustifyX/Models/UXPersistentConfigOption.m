//
//  UXPersistentConfigOption.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 11/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXPersistentConfigOption.h"
#import "UXOption.h"

@implementation UXPersistentConfigOption

- (NSString *)configString {
    if (self.option && self.value.length) {
        return [NSString stringWithFormat:@"%@ = %@", self.option.code, self.value];
    }
    return nil;
}

@end
