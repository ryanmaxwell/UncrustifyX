//
//  NSAttributedString+Hyperlink.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 6/04/13.
//  Copyright (c) 2013 Ryan Maxwell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Hyperlink)

+ (id)ux_hyperlinkFromString:(NSString *)string withURL:(NSURL *)url;

@end
