//
//  UXSubcategory.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 10/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "_UXSubcategory.h"
#import "UXDisplayable.h"

@interface UXSubcategory : _UXSubcategory <UXDisplayable>

/**
 * Singleton
 */
+ (UXSubcategory *)otherSubcategory;

@end
