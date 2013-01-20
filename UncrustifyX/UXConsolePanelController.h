//
//  UXConsolePanelController.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 19/01/13.
//  Copyright (c) 2013 Ryan Maxwell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface UXConsolePanelController : NSWindowController

+ (instancetype)sharedConsole;

@property (strong, nonatomic) IBOutlet NSTextView *textView;

- (void)logString:(NSString *)message;
- (void)clear;

@end
