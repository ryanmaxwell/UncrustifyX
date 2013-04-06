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
    
    [self updatePluginInfoLabel];
    [self updatePluginVersionLabel];
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
    NSString *installedPluginPath = self.uncrustifyPluginPath;
    if ([NSFileManager.defaultManager fileExistsAtPath:installedPluginPath]) {
        NSString *pluginInfoPath = [installedPluginPath stringByAppendingPathComponent:@"Contents/Info.plist"];
        
        NSDictionary *pluginInfo = [NSDictionary dictionaryWithContentsOfFile:pluginInfoPath];
        
        self.uncrustifyPluginVersionLabel.stringValue = [NSString stringWithFormat:@"Plugin version %@ (%@) is installed", pluginInfo[@"CFBundleShortVersionString"], pluginInfo[@"CFBundleVersion"]];
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
    NSString *pluginPath = [NSBundle.mainBundle pathForResource:UncrustifyPluginResourceName
                                                         ofType:UncrustifyPluginResourceType];
    NSError *copyError = nil;
    [NSFileManager.defaultManager copyItemAtPath:pluginPath toPath:self.uncrustifyPluginPath error:&copyError];
    if (copyError) DErr(@"%@", copyError);
    
    [self updatePluginVersionLabel];
}

- (NSString *)uncrustifyPluginPath {
    return [[[@"~/Library/Application Support/Developer/Shared/Xcode/Plug-ins" stringByExpandingTildeInPath]
             stringByAppendingPathComponent:UncrustifyPluginResourceName]
            stringByAppendingPathExtension:UncrustifyPluginResourceType];
}

@end
