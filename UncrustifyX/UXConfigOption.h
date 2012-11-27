//
//  UXConfigOption.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 27/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UXOption;

@protocol UXConfigOption <NSObject>

@property (readwrite) UXOption *option;
@property (readwrite) NSString *value;

/**
 * @return the config string "code = value" or nil
 */
@property (readonly) NSString *configString;

@end
