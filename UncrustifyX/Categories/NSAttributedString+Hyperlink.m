//
//  NSAttributedString+Hyperlink.m
//  UncrustifyX
//
//  Created by Ryan Maxwell on 6/04/13.
//  Copyright (c) 2013 Ryan Maxwell. All rights reserved.
//

#import "NSAttributedString+Hyperlink.h"

@implementation NSAttributedString (Hyperlink)

+ (id)ux_hyperlinkFromString:(NSString *)string withURL:(NSURL *)url {
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange range = NSMakeRange(0, [attrString length]);
    
    [attrString beginEditing];
    [attrString addAttribute:NSLinkAttributeName value:url.absoluteString range:range];
    
    // make the text appear in blue
    [attrString addAttribute:NSForegroundColorAttributeName value:NSColor.blueColor range:range];
    
    // next make the text appear with an underline
    [attrString addAttribute:
     NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:range];
    
    [attrString endEditing];
    
    return attrString;
}

@end
