//
//  UXDefaultsManager.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 6/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UXDefaultsManager : NSObject

+ (instancetype)sharedDefaultsManager;

- (void)registerDefaults;

@property (nonatomic, readonly) NSString *uncrustifyBinaryPath;
@property (nonatomic) NSString *customBinaryPath;
@property (nonatomic) BOOL useCustomBinary;
@property (nonatomic, readonly) NSString *bundledUncrustifyBinaryVersion;
@property (nonatomic) NSDate *definitionsUpdatedAt;
@property (nonatomic) NSString *selectedPreviewLanguageInDocumentation;
@property (nonatomic) NSString *selectedPreviewLanguageInMainWindow;
@property (nonatomic) BOOL overwriteFiles;

/**
 * @return an array of NSStrings of the language code
 */
@property (nonatomic, readonly) NSArray *languagesIncludedInDocumentationPanel;
- (void)addLanguageIncludedInDocumentation:(NSString *)languageCode;
- (void)removeLanguageIncludedInDocumentation:(NSString *)languageCode;

@end
