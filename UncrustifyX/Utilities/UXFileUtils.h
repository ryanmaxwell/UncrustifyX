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

+ (BOOL)writeConfigOptions:(NSArray *)configOptions toFileAtPath:(NSString *)filePath withDocumentation:(BOOL)documentation;

@end
