//
//  UXCategory.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 11/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "_UXCategory.h"
#import "UXDisplayable.h"

@interface UXCategory : _UXCategory <UXDisplayable>

/**
 * Singleton
 */
+ (UXCategory *)otherCategory;

@end
