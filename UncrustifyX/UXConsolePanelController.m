//
//  UXConsolePanelController.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 19/01/13.
//  Copyright (c) 2013 Ryan Maxwell. All rights reserved.
//

#import "UXConsolePanelController.h"

@interface UXConsolePanelController ()
@property (strong, nonatomic) NSString *storedString;
@end

@implementation UXConsolePanelController

+ (instancetype)sharedConsole {
    static UXConsolePanelController *sharedConsole;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConsole = [[UXConsolePanelController alloc] initWithWindowNibName:@"UXConsolePanelController"];
    });
    
    return sharedConsole;
}

- (id)initWithWindowNibName:(NSString *)windowNibName {
    self = [super initWithWindowNibName:windowNibName];
    
    if (self) {
        _storedString = @"";
    }
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.textView.backgroundColor = NSColor.blackColor;
    self.textView.string = self.storedString;
    [self resetTextViewFont];
}

- (void)resetTextViewFont {
    self.textView.textStorage.font = [NSFont fontWithName:@"Menlo" size:11];
    self.textView.textColor = NSColor.greenColor;
}

- (void)logString:(NSString *)string {
    if (self.textView) {
        self.textView.string = [NSString stringWithFormat:@"%@%@", self.textView.string, string];
        [self resetTextViewFont];
    } else {
        /* store string for when view loaded */
        self.storedString = [NSString stringWithFormat:@"%@%@", self.storedString, string];
    }
}

- (void)clear {
    self.textView.string = @"";
    self.storedString = @"";
}

@end
