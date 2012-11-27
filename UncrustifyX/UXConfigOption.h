//
//  UXConfigOption.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 27/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UXOption.h"

@protocol UXConfigOption <NSObject>

@property (readonly) NSString *configString;
@property (readwrite) UXOption *option;
@property (readwrite) NSString *value;

@end

@interface UXConfigOptionSharedImplementation : NSObject

/**
 * @return the config string "code = value" or nil
 */
+ (NSString *)configStringForOption:(UXOption *)option value:(NSString *)value;

@end