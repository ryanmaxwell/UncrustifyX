//
//  UXAppDelegate.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 6/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXAppDelegate.h"
#import "UXDataImporter.h"
#import "UXMainWindowController.h"
#import "UXPreferencesWindowController.h"

@implementation UXAppDelegate

#pragma mark - NSApplicationDelegate

+ (void)initialize {
    [super initialize];
    
    [UXDefaultsManager registerDefaults];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [MagicalRecord setupAutoMigratingCoreDataStack];
    [UXDataImporter importDefinitions];
    
    _mainWindowController = [[UXMainWindowController alloc] initWithWindowNibName:@"UXMainWindowController"];
    _mainWindowController.window.isVisible = YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [NSManagedObjectContext.defaultContext save];
    [MagicalRecord cleanUp];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
    [self.mainWindowController addFilePaths:filenames];
    [sender replyToOpenOrPrint:NSApplicationDelegateReplySuccess];
}

- (NSWindowController *)preferencesWindowController {
    if (!_preferencesWindowController) {
        _preferencesWindowController = [[UXPreferencesWindowController alloc] initWithWindowNibName:@"UXPreferencesWindowController"];
    }
    return _preferencesWindowController;
}

- (IBAction)showPreferences:(id)sender {
    self.preferencesWindowController.window.isVisible = YES;
    self.preferencesWindowController.window.level = 3; /* Documentation Panel Level */
    [self.preferencesWindowController.window makeKeyAndOrderFront:self];
}

- (IBAction)deletePressed:(id)sender {
    [self.mainWindowController deletePressed:sender];
}

- (void)NSLogger {
#if TEST_CONSOLE_LOGGING
	LoggerSetOptions(NULL, kLoggerOption_LogToConsole);
#else
#if TEST_FILE_BUFFERING
	LoggerSetBufferFile(NULL, CFSTR("/tmp/NSLoggerTempData_MacOSX.rawnsloggerdata"));
#endif
#if TEST_DIRECT_CONNECTION
	LoggerSetViewerHost(NULL, LOGGING_HOST, LOGGING_PORT);
#endif
#endif
#if TEST_BONJOUR_SETUP
	// test restricting bonjour lookup for a specific machine
	LoggerSetupBonjour(NULL, NULL, CFSTR("Awesome"));
#endif
}

@end
