//
//  UXPersistentConfigOption.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 11/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXPersistentConfigOption.h"

@implementation UXPersistentConfigOption

- (NSString *)configString {
    return [UXConfigOptionSharedImplementation configStringForOption:self.option value:self.value];
}

@end
