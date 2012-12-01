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
#define kDefinitionsUpdatedAtKey            @"DefinitionsUpdatedAt"
#define kBundledUncrustifyBinaryVersionKey  @"BundledUncrustifyBinaryVersion"

@implementation UXDefaultsManager

+ (void)registerDefaults {
    NSDictionary *defaults = @{kBundledUncrustifyBinaryVersionKey: @"0.59 (f91f1aa05b)"};
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
    return [self defaultsObjectForKey:kBundledUncrustifyBinaryVersionKey];
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

+ (NSDate *)definitionsUpdatedAt {
    return [self defaultsObjectForKey:kDefinitionsUpdatedAtKey];
}

+ (void)setDefinitionsUpdatedAt:(NSDate *)date {
    [self setDefaultsObject:date forKey:kDefinitionsUpdatedAtKey];
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
