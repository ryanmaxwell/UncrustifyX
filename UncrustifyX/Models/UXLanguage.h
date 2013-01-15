//
//  UXLanguage.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 11/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "_UXLanguage.h"
#import "UXDisplayable.h"

extern NSString *const UXLanguageExtensionDelimiter;

@interface UXLanguage : _UXLanguage <UXDisplayable>

/*
 * @return an array of NSStrings
 */
@property (nonatomic, readonly) NSArray *fileExtensions;

@property (nonatomic, getter = isIncludedInDocumentation) BOOL includedInDocumentation;

@end
