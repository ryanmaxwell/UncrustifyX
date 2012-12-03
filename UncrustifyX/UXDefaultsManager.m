//
//  UXDefaultsManager.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 6/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXDefaultsManager.h"

static NSString *const UXOverwriteFilesKey                  = @"UXOverwriteFiles";
static NSString *const UXUseCustomBinaryKey                 = @"UXUseCustomBinary";
static NSString *const UXCustomBinaryPathKey                = @"UXCustomBinaryPath";
static NSString *const UXDefinitionsUpdatedAtKey            = @"UXDefinitionsUpdatedAt";
static NSString *const UXBundledUncrustifyBinaryVersionKey  = @"UXBundledUncrustifyBinaryVersion";

@implementation UXDefaultsManager

+ (void)registerDefaults {
    NSDictionary *defaults = @{UXBundledUncrustifyBinaryVersionKey: @"0.59"};
    [NSUserDefaults.standardUserDefaults registerDefaults:defaults];
}

+ (NSString *)uncrustifyBinaryPath {
    if (self.useCustomBinary && self.customBinaryPath.length) {
        return self.customBinaryPath;
    } else {
        return [NSBundle.mainBundle pathForResource:@"uncrustify" ofType:nil];
    }
}

+ (NSString *)bundledUncrustifyBinaryVersion {
    return [self defaultsObjectForKey:UXBundledUncrustifyBinaryVersionKey];
}

+ (BOOL)useCustomBinary {
    return [[self defaultsObjectForKey:UXUseCustomBinaryKey] boolValue];
}

+ (void)setUseCustomBinary:(BOOL)useCustomBinary {
    [self setDefaultsObject:@(useCustomBinary) forKey:UXUseCustomBinaryKey];
}

+ (BOOL)overwriteFiles {
    return [[self defaultsObjectForKey:UXOverwriteFilesKey] boolValue];
}

+ (NSString *)customBinaryPath {
    return [self defaultsObjectForKey:UXCustomBinaryPathKey];
}

+ (void)setCustomBinaryPath:(NSString *)path {
    [self setDefaultsObject:path forKey:UXCustomBinaryPathKey];
}

+ (NSDate *)definitionsUpdatedAt {
    return [self defaultsObjectForKey:UXDefinitionsUpdatedAtKey];
}

+ (void)setDefinitionsUpdatedAt:(NSDate *)date {
    [self setDefaultsObject:date forKey:UXDefinitionsUpdatedAtKey];
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
