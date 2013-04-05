//
//  UXDefaultsManager.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 6/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXDefaultsManager.h"

static NSString *const UXOverwriteFilesKey                          = @"UXOverwriteFiles";
static NSString *const UXUseCustomBinaryKey                         = @"UXUseCustomBinary";
static NSString *const UXCustomBinaryPathKey                        = @"UXCustomBinaryPath";
static NSString *const UXDefinitionsUpdatedAtKey                    = @"UXDefinitionsUpdatedAt";
static NSString *const UXBundledUncrustifyBinaryVersionKey          = @"UXBundledUncrustifyBinaryVersion";
static NSString *const UXExportDocumentationKey                     = @"UXExportDocumentation";
static NSString *const UXExportCategoryDocumentationKey             = @"UXExportCategoryDocumentation";
static NSString *const UXExportSubcategoryDocumentationKey          = @"UXExportSubcategoryDocumentation";
static NSString *const UXExportOptionNameDocumentationKey           = @"UXExportOptionNameDocumentation";
static NSString *const UXExportOptionValueDocumentationKey          = @"UXExportOptionValueDocumentation";
static NSString *const UXExportBlankOptionsKey                      = @"UXExportBlankOptions";
static NSString *const UXLanguagesIncludedInDocumentationKey        = @"UXLanguagesIncludedInDocumentation";
static NSString *const UXSelectedPreviewLanguageInDocumentationKey  = @"UXSelectedPreviewLanguageInDocumentation";
static NSString *const UXSelectedPreviewLanguageInMainWindowKey     = @"UXSelectedPreviewLanguageInMainWindow";

@implementation UXDefaultsManager

+ (instancetype)sharedDefaultsManager {
    static UXDefaultsManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UXDefaultsManager alloc] init];
    });
    return instance;
}

- (void)registerDefaults {
    NSDictionary *defaults = @{
        UXBundledUncrustifyBinaryVersionKey: @"0.60 (20a311344b)",
        UXExportDocumentationKey: @YES,
        UXExportCategoryDocumentationKey: @YES,
        UXExportSubcategoryDocumentationKey: @YES,
        UXExportOptionNameDocumentationKey: @YES,
        UXExportOptionValueDocumentationKey: @YES,
        UXSelectedPreviewLanguageInDocumentationKey: @"OC",
        UXSelectedPreviewLanguageInMainWindowKey: @"OC"
    };
    [NSUserDefaults.standardUserDefaults registerDefaults:defaults];
}

- (NSString *)uncrustifyBinaryPath {
    if (self.useCustomBinary && self.customBinaryPath.length) {
        return self.customBinaryPath;
    } else {
        return [NSBundle.mainBundle pathForResource:@"uncrustify" ofType:nil];
    }
}

- (NSString *)bundledUncrustifyBinaryVersion {
    return [self defaultsObjectForKey:UXBundledUncrustifyBinaryVersionKey];
}

- (BOOL)useCustomBinary {
    return [[self defaultsObjectForKey:UXUseCustomBinaryKey] boolValue];
}

- (void)setUseCustomBinary:(BOOL)useCustomBinary {
    [self setDefaultsObject:@(useCustomBinary) forKey:UXUseCustomBinaryKey];
}

- (BOOL)overwriteFiles {
    return [[self defaultsObjectForKey:UXOverwriteFilesKey] boolValue];
}

- (void)setOverwriteFiles:(BOOL)overwriteFiles {
    [self setDefaultsObject:@(overwriteFiles) forKey:UXOverwriteFilesKey];
}

- (NSString *)customBinaryPath {
    return [self defaultsObjectForKey:UXCustomBinaryPathKey];
}

- (void)setCustomBinaryPath:(NSString *)path {
    [self setDefaultsObject:path forKey:UXCustomBinaryPathKey];
}

- (NSDate *)definitionsUpdatedAt {
    return [self defaultsObjectForKey:UXDefinitionsUpdatedAtKey];
}

- (void)setDefinitionsUpdatedAt:(NSDate *)date {
    [self setDefaultsObject:date forKey:UXDefinitionsUpdatedAtKey];
}

- (NSArray *)languagesIncludedInDocumentationPanel {
    return [self defaultsObjectForKey:UXLanguagesIncludedInDocumentationKey];
}

- (void)addLanguageIncludedInDocumentation:(NSString *)languageCode {
    if (languageCode != nil) {
        NSArray *currentLanguages = [self languagesIncludedInDocumentationPanel];
        if (![currentLanguages containsObject:languageCode]) {
            NSMutableArray *newLangauges = [NSMutableArray arrayWithArray:currentLanguages];
            [newLangauges addObject:languageCode];
            [self setDefaultsObject:newLangauges forKey:UXLanguagesIncludedInDocumentationKey];
        }
    }
}

- (void)removeLanguageIncludedInDocumentation:(NSString *)languageCode {
    if (languageCode != nil) {
        NSArray *currentLanguages = [self languagesIncludedInDocumentationPanel];
        if ([currentLanguages containsObject:languageCode]) {
            NSMutableArray *newLanguages = [NSMutableArray arrayWithArray:currentLanguages];
            [newLanguages removeObject:languageCode];
            [self setDefaultsObject:newLanguages forKey:UXLanguagesIncludedInDocumentationKey];
        }
    }
}

- (NSString *)selectedPreviewLanguageInDocumentation {
    return [self defaultsObjectForKey:UXSelectedPreviewLanguageInDocumentationKey];
}

- (void)setSelectedPreviewLanguageInDocumentation:(NSString *)languageCode {
    [self setDefaultsObject:languageCode forKey:UXSelectedPreviewLanguageInDocumentationKey];
}

- (NSString *)selectedPreviewLanguageInMainWindow {
    return [self defaultsObjectForKey:UXSelectedPreviewLanguageInMainWindowKey];
}

- (void)setSelectedPreviewLanguageInMainWindow:(NSString *)languageCode {
    [self setDefaultsObject:languageCode forKey:UXSelectedPreviewLanguageInMainWindowKey];
}

#pragma mark -

- (void)setDefaultsObject:(id)object forKey:(id)key {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults setObject:object forKey:key];
    [defaults synchronize];
}

- (id)defaultsObjectForKey:(id)key {
    return [NSUserDefaults.standardUserDefaults objectForKey:key];
}

@end
