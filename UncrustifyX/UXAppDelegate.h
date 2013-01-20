//
//  UXAppDelegate.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 6/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class UXMainWindowController;
@class UXPreferencesWindowController;

extern NSString *const UXErrorDomain;

@interface UXAppDelegate : NSObject <NSApplicationDelegate>

@property (weak, nonatomic) IBOutlet NSMenuItem *documentationMenuItem;
@property (weak, nonatomic) IBOutlet NSMenuItem *consoleMenuItem;

@property (strong, nonatomic) UXMainWindowController *mainWindowController;
@property (strong, nonatomic) UXPreferencesWindowController *preferencesWindowController;

- (IBAction)showPreferences:(id)sender;
- (IBAction)openFiles:(id)sender;
- (IBAction)importConfiguration:(id)sender;
- (IBAction)exportConfiguration:(id)sender;
- (IBAction)run:(id)sender;
- (IBAction)deletePressed:(id)sender;
- (IBAction)showView:(id)sender;
- (IBAction)clearConsole:(id)sender;

- (void)updateDocumentationMenuItem;
- (void)updateConsoleMenuItem;

@end
