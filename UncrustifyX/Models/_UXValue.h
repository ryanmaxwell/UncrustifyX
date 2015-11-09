// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UXValue.h instead.

#import <CoreData/CoreData.h>
#import "UXBaseManagedObject.h"

extern const struct UXValueAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *value;
} UXValueAttributes;

extern const struct UXValueRelationships {
	__unsafe_unretained NSString *valueType;
} UXValueRelationships;

@class UXValueType;

@interface UXValueID : NSManagedObjectID {}
@end

@interface _UXValue : UXBaseManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) UXValueID* objectID;

@property (nonatomic, strong) NSDate* createdAt;

//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updatedAt;

//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* value;

//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) UXValueType *valueType;

//- (BOOL)validateValueType:(id*)value_ error:(NSError**)error_;

@end

@interface _UXValue (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;

- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;

- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;

- (UXValueType*)primitiveValueType;
- (void)setPrimitiveValueType:(UXValueType*)value;

@end
