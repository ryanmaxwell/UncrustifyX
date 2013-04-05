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

NSString * const UXErrorDomain                                      = @"UXError";

static NSString * const BBUncrustifyPluginLaunchArgument            = @"-bbuncrustifyplugin";
static NSString * const BBUncrustifyPluginSourceCodePasteboardName  = @"BBUncrustifyPlugin-source-code";

typedef NS_ENUM(NSInteger, UXViewTag) {
    UXViewTagFiles = 1,
    UXViewTagDirectInput,
    UXViewTagDocumentation,
    UXViewTagConsole
};

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
    [self updateDocumentationMenuItem:nil];
    [self updateConsoleMenuItem:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(updateConsoleMenuItem:)
                                               name:NSWindowWillCloseNotification
                                             object:UXCONSOLE.window];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(updateDocumentationMenuItem:)
                                               name:NSWindowWillCloseNotification
                                             object:self.mainWindowController.documentationPanelController.window];
    
    NSArray *launchArgs = NSProcessInfo.processInfo.arguments;
    
    if ([launchArgs containsObject:BBUncrustifyPluginLaunchArgument]) {
        DLog(@"UX Launched from BBUncrustifyPlugin-Xcode");
        
        NSUInteger configPathArgumentIndex = [launchArgs indexOfObject:@"-configpath"];
        
        if (configPathArgumentIndex != NSNotFound && launchArgs.count > configPathArgumentIndex + 1) {
            NSString *configPath = launchArgs[configPathArgumentIndex + 1];
            
            DLog(@"Config Path: %@", configPath);
            
            if ([configPath hasPrefix:@"~"]) {
                configPath = [configPath stringByExpandingTildeInPath];
            }
            
            NSURL *configPathURL = [NSURL fileURLWithPath:configPath];
            [self.mainWindowController importConfigurationAtURL:configPathURL];
            
            NSPasteboard *sourceCodePB = [NSPasteboard pasteboardWithName:BBUncrustifyPluginSourceCodePasteboardName];
            NSArray *objects = [sourceCodePB readObjectsForClasses:@[NSString.class] options:nil];
            
            if (objects.count) {
                DLog(@"Source Code: \n%@", objects);
                self.mainWindowController.directInputText = objects[0];
                [self showViewWithTag:UXViewTagDirectInput];
            }
        }
    }
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    
    [NSManagedObjectContext.defaultContext saveToPersistentStoreAndWait];
    [MagicalRecord cleanUp];
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
    if ([NSProcessInfo.processInfo.arguments containsObject:BBUncrustifyPluginLaunchArgument]) return;
    
    for (NSString *filePath in filenames) {
        if ([filePath.pathExtension isEqualToString:@"cfg"]) {
            /* parse config */
            
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            [self.mainWindowController importConfigurationAtURL:fileURL];
            
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
    [self.mainWindowController removeItems:sender];
}

- (IBAction)showView:(id)sender {
    NSMenuItem *menuItem = (NSMenuItem *)sender;
    [self showViewWithTag:menuItem.tag];
}

- (void)showViewWithTag:(UXViewTag)viewTag {
    switch (viewTag) {
        case UXViewTagFiles: {
            self.mainWindowController.toolbar.selectedItemIdentifier = self.mainWindowController.fileInputToolbarItem.itemIdentifier;
            [self.mainWindowController showView:self.mainWindowController.fileInputToolbarItem];
        }
            break;
            
        case UXViewTagDirectInput: {
            self.mainWindowController.toolbar.selectedItemIdentifier = self.mainWindowController.directInputToolbarItem.itemIdentifier;
            [self.mainWindowController showView:self.mainWindowController.directInputToolbarItem];
        }
            break;
            
        case UXViewTagDocumentation: {
            [self.mainWindowController toggleDocumentationPanel:self];
        }
            break;
            
        case UXViewTagConsole: {
            [self.mainWindowController toggleConsole:self];
        }
            break;
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

- (void)updateDocumentationMenuItem:(NSNotification *)notification  {
    if (!self.mainWindowController.isDocumentationVisible
        || (notification && [notification.name isEqualToString:NSWindowWillCloseNotification])) {
        self.documentationMenuItem.title = @"Show Documentation";
    } else {
        self.documentationMenuItem.title = @"Hide Documentation";
    }
}

- (void)updateConsoleMenuItem:(NSNotification *)notification {
    if (!UXCONSOLE.window.isVisible
        || (notification && [notification.name isEqualToString:NSWindowWillCloseNotification])) {
        self.consoleMenuItem.title = @"Show Console";
    } else {
        self.consoleMenuItem.title = @"Hide Console";
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
