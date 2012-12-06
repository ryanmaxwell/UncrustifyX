//
//  UXDefaultsManager.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 6/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UXDefaultsManager : NSObject

+ (void)registerDefaults;

+ (NSString *)uncrustifyBinaryPath;
+ (NSString *)bundledUncrustifyBinaryVersion;

+ (BOOL)useCustomBinary;
+ (void)setUseCustomBinary:(BOOL)useCustomBinary;

+ (NSString *)customBinaryPath;
+ (void)setCustomBinaryPath:(NSString *)path;

+ (NSDate *)definitionsUpdatedAt;
+ (void)setDefinitionsUpdatedAt:(NSDate *)date;

/**
 * @return an array of NSStrings of the language code
 */
+ (NSArray *)languagesIncludedInDocumentationPanel;
+ (void)addLanguageIncludedInDocumentation:(NSString *)languageCode;
+ (void)removeLanguageIncludedInDocumentation:(NSString *)languageCode;

+ (BOOL)overwriteFiles;

@end
