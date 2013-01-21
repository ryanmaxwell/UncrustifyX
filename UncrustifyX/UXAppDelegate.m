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
#import "UXDocumentationPanelController.h"

NSString *const UXErrorDomain                               = @"UXError";

@interface UXAppDelegate () <NSMenuDelegate>

@end

@implementation UXAppDelegate

#pragma mark - NSApplicationDelegate

+ (void)initialize {
    [super initialize];
    
    [UXDEFAULTS registerDefaults];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [MagicalRecord setupAutoMigratingCoreDataStack];
    [UXDataImporter importDefinitions];
    
    _mainWindowController = [[UXMainWindowController alloc] initWithWindowNibName:@"UXMainWindowController"];
    _mainWindowController.window.isVisible = YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {    
    [self updateDocumentationMenuItem];
    [self updateConsoleMenuItem];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [NSManagedObjectContext.defaultContext saveToPersistentStoreAndWait];
    [MagicalRecord cleanUp];
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
    for (NSString *filePath in filenames) {
        if ([filePath.pathExtension
             isEqualToString:@"cfg"]) {
            /* parse config */
            
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            [self.mainWindowController
             importConfigurationAtURL:fileURL];
            
            [sender replyToOpenOrPrint:NSApplicationDelegateReplySuccess];
            return;
        }
    }
    
    [self.mainWindowController addFilePaths:filenames];
    [sender replyToOpenOrPrint:NSApplicationDelegateReplySuccess];
}

- (NSWindowController *)preferencesWindowController {
    if (!_preferencesWindowController) {
        _preferencesWindowController = [[UXPreferencesWindowController alloc] initWithWindowNibName:@"UXPreferencesWindowController"];
    }
    
    return _preferencesWindowController;
}

#pragma mark - IBAction

- (IBAction)openFiles:(id)sender {
    [self.mainWindowController addFilesPressed:sender];
}

- (IBAction)importConfiguration:(id)sender {
    [self.mainWindowController importConfigurationPressed:sender];
}

- (IBAction)exportConfiguration:(id)sender {
    [self.mainWindowController exportConfigurationPressed:sender];
}

- (IBAction)run:(id)sender {
    [self.mainWindowController runButtonPressed:sender];
}

- (IBAction)showPreferences:(id)sender {
    self.preferencesWindowController.window.isVisible = YES;
    self.preferencesWindowController.window.level = 3; /* Documentation Panel Level */
    [self.preferencesWindowController.window makeKeyAndOrderFront:self];
}

- (IBAction)deletePressed:(id)sender {
    [self.mainWindowController deletePressed:sender];
}

- (IBAction)showView:(id)sender {
    NSMenuItem *menuItem = (NSMenuItem *)sender;
    
    switch (menuItem.tag) {
        case 1: {
            /* Files View */
            self.mainWindowController.toolbar.selectedItemIdentifier = self.mainWindowController.fileInputToolbarItem.itemIdentifier;
            [self.mainWindowController showView:self.mainWindowController.fileInputToolbarItem];
            break;
        }
            
        case 2: {
            /* Direct Input View */
            self.mainWindowController.toolbar.selectedItemIdentifier = self.mainWindowController.directInputToolbarItem.itemIdentifier;
            [self.mainWindowController showView:self.mainWindowController.directInputToolbarItem];
            break;
        }
            
        case 3: {
            /* Documentation */
            [self.mainWindowController toggleDocumentationPanel:self];
            
            break;
        }
        case 4: {
            /* Console */
            
            [self.mainWindowController toggleConsole:self];
            
            break;
        }
    }
}

- (IBAction)clearConsole:(id)sender {
    [UXCONSOLE clear];
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

- (void)updateDocumentationMenuItem {
    if (self.mainWindowController.isDocumentationVisible) {
        self.documentationMenuItem.title = @"Hide Documentation";
    } else {
        self.documentationMenuItem.title = @"Show Documentation";
    }
}

- (void)updateConsoleMenuItem {
    if (UXCONSOLE.window.isVisible) {
        self.consoleMenuItem.title = @"Hide Console";
    } else {
        self.consoleMenuItem.title = @"Show Console";
    }
}

#pragma mark - NSMenuValidation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    switch (menuItem.tag) {
        case 11:
            /* Export Configuration */
            return self.mainWindowController.isExportEnabled;
            
        case 12:
            /* Run */
            return self.mainWindowController.isRunEnabled;
            
        default:
            return YES;
    }
}

@end
