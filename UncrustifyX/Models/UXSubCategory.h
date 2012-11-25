//
//  UXSubCategory.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 10/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "_UXSubCategory.h"
#import "UXDisplayable.h"

@interface UXSubCategory : _UXSubCategory <UXDisplayable>

/**
 * Singleton
 */
+ (UXSubCategory *)otherSubCategory;

@end
