//
//  UXPreferencesWindowController.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 20/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXPreferencesWindowController.h"

@interface UXPreferencesWindowController () <NSOpenSavePanelDelegate>

@end

@implementation UXPreferencesWindowController

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    
    if (self) {
    }
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (IBAction)choosePressed:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    NSURL *initialDirectoryURL = nil;
    BOOL isDir;
    
    if ([NSFileManager.defaultManager fileExistsAtPath:@"/usr/local/bin" isDirectory:&isDir] && isDir) {
        initialDirectoryURL = [NSURL fileURLWithPath:@"/usr/local/bin"
                                         isDirectory:YES];
    } else {
        initialDirectoryURL = [NSURL fileURLWithPath:@"/usr/bin"
                                         isDirectory:YES];
    }
    
    openPanel.directoryURL = initialDirectoryURL;
    NSInteger result = [openPanel runModal];
    
    if (result == NSFileHandlingPanelOKButton) {
        NSURL *chosenFileURL = openPanel.URL;
        
        UXDEFAULTS.useCustomBinary = YES;
        UXDEFAULTS.customBinaryPath = chosenFileURL.path;
    }
}

@end
