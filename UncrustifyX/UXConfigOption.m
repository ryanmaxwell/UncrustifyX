//
//  UXConfigOption.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 28/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXConfigOption.h"

@implementation UXConfigOptionSharedImplementation

+ (NSString *)configStringForOption:(UXOption *)option value:(NSString *)value {
    if (option && value.length) {
        return [NSString stringWithFormat:@"%@ = %@", option.code, value];
    }
    return nil;
}

@end