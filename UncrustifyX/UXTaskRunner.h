//
//  UXTaskRunner.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 14/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UXTaskRunner : NSObject

+ (NSString *)uncrustifyCodeFragment:(NSString *)string withConfigOptions:(NSArray *)configOptions arguments:(NSArray *)arguments;

/**
 * @param filePaths an array of the paths to the files to be uncrustified
 * @param configOptions an array of UXConfigOption objects
 * @param arguments additional command-line arguments to pass to uncrustify
 */
+ (void)uncrustifyFilesAtPaths:(NSArray *)filePaths withConfigOptions:(NSArray *)configOptions arguments:(NSArray *)arguments;

@end
