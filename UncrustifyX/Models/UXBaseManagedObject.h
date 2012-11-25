//
//  UXBaseManagedObject.h
//  UncrustifyX
//
//  Created by Ryan Maxwell on 11/10/12.
//  Copyright (c) 2012 Ryan Maxwell. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface UXBaseManagedObject : NSManagedObject

@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSDate *updatedAt;

@end
