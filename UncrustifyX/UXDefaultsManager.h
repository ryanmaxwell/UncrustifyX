//
//  UXDefaultsManager.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 6/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UXDefaultsManager : NSObject

+ (NSString *)uncrustifyBinaryPath;
+ (NSString *)bundledUncrustifyBinaryVersion;

+ (BOOL)overwriteFiles;
+ (BOOL)useCustomBinary;

+ (NSDate *)definitionsUpdatedAt;
+ (void)setDefinitionsUpdatedAt:(NSDate *)date;

+ (BOOL)documentationPreviewExpanded;
+ (void)setDocumentationPreviewExpanded:(BOOL)expanded;

+ (BOOL)documentationPanelVisible;
+ (void)setDocumentationPanelVisible:(BOOL)visible;

+ (void)registerDefaults;

@end
