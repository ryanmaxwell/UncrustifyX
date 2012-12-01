//
//  UXTaskRunner.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 14/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXTaskRunner.h"
#import "UXFileUtils.h"
#import "UXConfigOption.h"
#import "UXOption.h"

@interface UXTaskRunner ()

/**
 * One Option per line, newline on end of file
 */
+ (NSString *)stringFromConfigOptions:(NSArray *)configOptions;

@end

@implementation UXTaskRunner

+ (NSString *)uncrustifyCodeFragment:(NSString *)string withConfigOptions:(NSArray *)configOptions arguments:(NSArray *)arguments {
    NSString *tempPath = [UXFileUtils writeStringToTempFile:string];
    
    NSArray *defaultArgs = @[@"--frag", @"--no-backup"];
    
    NSMutableArray *args = [NSMutableArray arrayWithArray:arguments];
    if (arguments) {
        [args addObjectsFromArray:defaultArgs];
    }
    
    [self uncrustifyFilesAtPaths:@[tempPath] withConfigOptions:configOptions arguments:args];
    
    NSError *error = nil;
    NSString *result = [NSString stringWithContentsOfFile:tempPath encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        DErr(@"%@", error);
        return nil;
    } else {
        DLog(@"%@", result);
        return result;
    }
}

+ (void)uncrustifyFilesAtPaths:(NSArray *)filePaths withConfigOptions:(NSArray *)configOptions arguments:(NSArray *)arguments {
    NSString *configString = [self stringFromConfigOptions:configOptions];
    NSString *configPath = [UXFileUtils writeStringToTempFile:configString];
    NSString *executablePath = UXDefaultsManager.uncrustifyBinaryPath;
    
    for (NSString *filePath in filePaths) {
        if (![NSFileManager.defaultManager fileExistsAtPath:filePath]) {
            [NSException raise:@"UXTaskRunnerException"
                        format:@"Source file not found at path %@", filePath];
            return;
        }
        
        if (![NSFileManager.defaultManager fileExistsAtPath:configPath]) {
            [NSException raise:@"UXTaskRunnerException"
                        format:@"Config file not found at path %@", configPath];
            return;
        }
        
        if (![NSFileManager.defaultManager fileExistsAtPath:executablePath]) {
            NSString *errorDescription = [NSString stringWithFormat:@"Uncrustify binary not found at path '%@'", executablePath];
            
            NSError *error = [NSError errorWithDomain:@"UXError"
                                                 code:0
                                             userInfo:@{
                            NSLocalizedDescriptionKey: errorDescription,
                NSLocalizedRecoverySuggestionErrorKey: @"Check the path specified in the preferences",
                   NSLocalizedRecoveryOptionsErrorKey: @[@"Use Bundled Binary", @"View Preferences…"]
                              }];
            
            DErr(@"%@", error);
            
            NSAlert *alert = [NSAlert alertWithError:error];
            NSInteger result = [alert runModal];
            
            if (result == NSAlertFirstButtonReturn) {
                NSLog(@"Use Bundled");
                UXDefaultsManager.useCustomBinary = NO;
                executablePath = UXDefaultsManager.uncrustifyBinaryPath;
            } else if (result == NSAlertSecondButtonReturn) {
                NSLog(@"View Preferences");
                
                UXAppDelegate *appDelegate = NSApplication.sharedApplication.delegate;
                [appDelegate showPreferences:self];
                return;
            }
        }
        
        NSMutableArray *args = NSMutableArray.array;
        [args addObjectsFromArray:arguments];
        [args addObjectsFromArray:@[@"-c", configPath, filePath]]; // TODO: Quote path?
        
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = executablePath;
        task.arguments = args;
        [task launch];
        [task waitUntilExit];
    }
}

+ (NSString *)stringFromConfigOptions:(NSArray *)configOptions {
    NSMutableString *configString = NSMutableString.string;
    
    for (id<UXConfigOption> configOption in configOptions) {
        if (configOption.configString) {
            [configString appendFormat:@"%@\n", configOption.configString];
        }
    }
    
    return configString;
}

@end
