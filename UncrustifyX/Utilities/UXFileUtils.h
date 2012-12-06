//
//  UXFileUtils.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 13/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UXFileUtils : NSObject

/**
 * Writes a string to a temp file using UTF-8 encoding
 *  @return the path to the resulting temp file
 */
+ (NSString *)writeStringToTempFile:(NSString *)contents;

+ (BOOL)  writeConfigOptions:(NSArray *)configOptions
                toFileAtPath:(NSString *)filePath
         includeBlankOptions:(BOOL)includeBlankOptions
    documentationForCategory:(BOOL)categoryDocumentation
                 subcategory:(BOOL)subcategoryDocumentation
                  optionName:(BOOL)optionNameDocumentation
                 optionValue:(BOOL)optionValueDocumentation;

@end
