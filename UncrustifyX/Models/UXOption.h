//
//  UXOption.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 11/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "_UXOption.h"
#import "UXDisplayable.h"

@interface UXOption : _UXOption <UXDisplayable>

@property (nonatomic, readwrite) NSString *subCategoryName;
@property (nonatomic, readwrite) NSString *displayName;

/**
 * Takes the code e.g. "align_assign_span" and returns it as "align assign span",
 * for better search query matches
 */
@property (nonatomic, readonly) NSString *explodedCode;

@end
