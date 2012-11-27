//
//  UXTransientConfigOption.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 27/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UXConfigOption.h"

@interface UXTransientConfigOption : NSObject <UXConfigOption>

@property (strong, readwrite) UXOption *option;
@property (strong, readwrite) NSString *value;

@end
