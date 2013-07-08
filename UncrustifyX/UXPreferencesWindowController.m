//
//  UXPreferencesWindowController.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 20/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import "UXPreferencesWindowController.h"
#import "NSAttributedString+Hyperlink.h"

static NSString * const UncrustifyPluginResourceName = @"UncrustifyPlugin";
static NSString * const UncrustifyPluginResourceType = @"xcplugin";

@interface UXPreferencesWindowController () <NSOpenSavePanelDelegate>

@end

@implementation UXPreferencesWindowController

#pragma mark - Class Methods

+ (NSString *)uncrustifyPluginPath {
    return [[self.xcodePluginsPath stringByAppendingPathComponent:UncrustifyPluginResourceName] stringByAppendingPathExtension:UncrustifyPluginResourceType];
}

+ (NSString *)xcodePluginsPath {
    return [@"~/Library/Application Support/Developer/Shared/Xcode/Plug-ins" stringByExpandingTildeInPath];
}

+ (NSString *)versionOfPluginAtPath:(NSString *)path {
    NSString *pluginInfoPath = [path stringByAppendingPathComponent:@"Contents/Info.plist"];
    NSDictionary *pluginInfo = [NSDictionary dictionaryWithContentsOfFile:pluginInfoPath];
    return pluginInfo ? pluginInfo[@"CFBundleVersion"] : @"";
}

+ (NSString *)installedPluginVersion {
    NSString *installedPluginPath = self.uncrustifyPluginPath;
    if ([NSFileManager.defaultManager fileExistsAtPath:installedPluginPath]) {
        return [self versionOfPluginAtPath:installedPluginPath];
    } else {
        return nil;
    }
}
    
+ (NSString *)bundledPluginVersion {
    NSString *sourcePluginPath = [NSBundle.mainBundle pathForResource:UncrustifyPluginResourceName
                                                               ofType:UncrustifyPluginResourceType];
    
    return [self versionOfPluginAtPath:sourcePluginPath];
}


#pragma mark - Instance Methods

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    
    if (self) {
    }
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self updatePluginButtonLabel];
    [self updatePluginInfoLabel];
    [self updatePluginVersionLabel];
}

- (void)updatePluginButtonLabel {
    NSString *labelText = [NSString stringWithFormat:@"Install Xcode Plugin %@", [[self class] bundledPluginVersion]];
    self.installPluginButton.title = labelText;
}

- (void)updatePluginInfoLabel {
    NSMutableAttributedString *labelValue = [[NSMutableAttributedString alloc] initWithString:@"Xcode Plugin is powered by "];
    
    NSURL *pluginURL = [NSURL URLWithString:@"https://github.com/benoitsan/BBUncrustifyPlugin-Xcode"];
    NSAttributedString *hyperlink = [NSAttributedString ux_hyperlinkFromString:@"BBUncrustifyPlugin-Xcode"
                                                                 withURL:pluginURL];
    
    [labelValue appendAttributedString:hyperlink];
    
    [labelValue addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:11.0]
                       range:NSMakeRange(0, labelValue.mutableString.length - 1)];
    
    [self.uncrustifyPluginInfoLabel setAttributedStringValue:labelValue];
}

- (void)updatePluginVersionLabel {
    NSString *installedPluginVersion = [[self class] installedPluginVersion];
    
    if (installedPluginVersion) {
        self.uncrustifyPluginVersionLabel.stringValue = [NSString stringWithFormat:@"Plugin version %@ is installed", installedPluginVersion];
    } else {
        self.uncrustifyPluginVersionLabel.stringValue = @"Plugin is not installed";
    }
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

- (IBAction)installXcodePluginPressed:(id)sender {
    
    NSFileManager *fileManager = NSFileManager.defaultManager;
    
    NSString *pluginsPath = [[self class] xcodePluginsPath];
    
    if(![fileManager fileExistsAtPath:pluginsPath]) {
        NSError *creationError = nil;
        
        [fileManager createDirectoryAtPath:pluginsPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&creationError];
        
        if (creationError) DErr(@"Create plugins folder failed: %@", creationError);
    }
    
    NSString *sourcePluginPath = [NSBundle.mainBundle pathForResource:UncrustifyPluginResourceName
                                                               ofType:UncrustifyPluginResourceType];
    NSString *uncrustifyPluginPath = [[self class] uncrustifyPluginPath];
    
    if (![fileManager fileExistsAtPath:uncrustifyPluginPath]) {
        NSError *copyError = nil;
        [fileManager copyItemAtPath:sourcePluginPath toPath:uncrustifyPluginPath error:&copyError];
        if (copyError) DErr(@"%@", copyError);
        
        [self updatePluginVersionLabel];
    } else {
        
        NSAlert *alert = [NSAlert alertWithMessageText:@"Plugin Already Installed"
                                         defaultButton:@"Don’t Overwrite"
                                       alternateButton:@"Overwrite"
                                           otherButton:nil
                             informativeTextWithFormat:@"Uncrustify Plugin %@ is already installed. Do you wish to overwrite it?", [[self class] installedPluginVersion]];
        
        NSInteger returnValue = [alert runModal];

        if (returnValue == NSAlertAlternateReturn) {
            /* Overwrite */
            
            NSError *removeError = nil;
            [fileManager removeItemAtPath:uncrustifyPluginPath error:&removeError];
            if (removeError) DErr(@"%@", removeError);
            
            NSError *copyError = nil;
            [fileManager copyItemAtPath:sourcePluginPath toPath:uncrustifyPluginPath error:&copyError];
            if (copyError) DErr(@"%@", copyError);
            
            [self updatePluginVersionLabel];
        }
    }
}

@end
