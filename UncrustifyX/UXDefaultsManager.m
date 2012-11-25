//
//  UXDefaultsManager.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 6/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXDefaultsManager.h"

#define kOverwriteFilesKey                  @"OverwriteFiles"
#define kUseCustomBinaryKey                 @"UseCustomBinary"
#define kCustomBinaryPathKey                @"CustomBinaryPath"
#define kDocumentationPreviewExpandedKey    @"DocumentationPreviewExpanded"
#define kDocumentationPanelVisibleKey       @"DocumentationPanelVisible"
#define kDefinitionsVersionKey              @"DefinitionsVersion"

@implementation UXDefaultsManager

+ (NSString *)uncrustifyBinaryPath {
    if (self.useCustomBinary && self.customBinaryPath.length) {
        return self.customBinaryPath;
    } else {
        return [NSBundle.mainBundle pathForResource:@"uncrustify" ofType:nil];
    }
}

+ (BOOL)useCustomBinary {
    return [[self defaultsObjectForKey:kUseCustomBinaryKey] boolValue];
}

+ (BOOL)overwriteFiles {
    return [[self defaultsObjectForKey:kOverwriteFilesKey] boolValue];
}

+ (NSString *)customBinaryPath {
    return [self defaultsObjectForKey:kCustomBinaryPathKey];
}

+ (NSUInteger)definitionsVersion {
    return [[self defaultsObjectForKey:kDefinitionsVersionKey] unsignedIntegerValue];
}

+ (void)setDefinitionsVersion:(NSUInteger)version {
    [self setDefaultsObject:@(version) forKey:kDefinitionsVersionKey];
}

+ (BOOL)documentationPreviewExpanded {
    return [[self defaultsObjectForKey:kDocumentationPreviewExpandedKey] boolValue];
}

+ (void)setDocumentationPreviewExpanded:(BOOL)expanded {
    [self setDefaultsObject:@(expanded) forKey:kDocumentationPreviewExpandedKey];
}

+ (BOOL)documentationPanelVisible {
    return [[self defaultsObjectForKey:kDocumentationPanelVisibleKey] boolValue];
}

+ (void)setDocumentationPanelVisible:(BOOL)visible {
    [self setDefaultsObject:@(visible) forKey:kDocumentationPanelVisibleKey];
}

#pragma mark -

+ (void)setDefaultsObject:(id)object forKey:(id)key {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults setObject:object forKey:key];
    [defaults synchronize];
}

+ (id)defaultsObjectForKey:(id)key {
    return [NSUserDefaults.standardUserDefaults objectForKey:key];
}

@end
