//
//  UXTransientConfigOption.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 27/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXTransientConfigOption.h"

@implementation UXTransientConfigOption

- (NSString *)configString {
    return [UXConfigOptionSharedImplementation configStringForOption:self.option value:self.value];
}

@end
