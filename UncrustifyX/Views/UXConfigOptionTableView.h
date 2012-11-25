//
//  UXConfigOptionTableView.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 14/11/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol UXConfigOptionTableViewDelegate;

@interface UXConfigOptionTableView : NSTableView

@property (assign, nonatomic) IBOutlet id<UXConfigOptionTableViewDelegate> viewDelegate;

@end

@protocol UXConfigOptionTableViewDelegate <NSObject>
@optional
- (void)tableView:(UXConfigOptionTableView *)tableView didUpdateFrame:(NSSize)newSize;
@end