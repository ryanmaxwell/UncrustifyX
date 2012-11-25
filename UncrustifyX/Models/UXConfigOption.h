//
//  UXConfigOption.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 11/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UXOption;

@interface UXConfigOption : NSObject

@property (strong, nonatomic) UXOption *option;

@property (strong, nonatomic) NSString *value;

/**
 * @return the config string "code = value" or nil
 */
@property (nonatomic, readonly) NSString *configString;

@end
