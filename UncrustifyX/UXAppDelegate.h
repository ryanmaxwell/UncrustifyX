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

@interface UXAppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) UXMainWindowController *mainWindowController;
@property (strong, nonatomic) UXPreferencesWindowController *preferencesWindowController;

- (IBAction)showPreferences:(id)sender;
- (IBAction)deletePressed:(id)sender;

@end
