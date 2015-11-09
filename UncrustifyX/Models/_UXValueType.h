// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UXValueType.h instead.

#import <CoreData/CoreData.h>
#import "UXBaseManagedObject.h"

extern const struct UXValueTypeAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *type;
	__unsafe_unretained NSString *updatedAt;
} UXValueTypeAttributes;

extern const struct UXValueTypeRelationships {
	__unsafe_unretained NSString *options;
	__unsafe_unretained NSString *values;
} UXValueTypeRelationships;

@class UXOption;
@class UXValue;

@interface UXValueTypeID : NSManagedObjectID {}
@end

@interface _UXValueType : UXBaseManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) UXValueTypeID* objectID;

@property (nonatomic, strong) NSDate* createdAt;

//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* type;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updatedAt;

//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *options;

- (NSMutableSet*)optionsSet;

@property (nonatomic, strong) NSSet *values;

- (NSMutableSet*)valuesSet;

@end

@interface _UXValueType (OptionsCoreDataGeneratedAccessors)
- (void)addOptions:(NSSet*)value_;
- (void)removeOptions:(NSSet*)value_;
- (void)addOptionsObject:(UXOption*)value_;
- (void)removeOptionsObject:(UXOption*)value_;

@end

@interface _UXValueType (ValuesCoreDataGeneratedAccessors)
- (void)addValues:(NSSet*)value_;
- (void)removeValues:(NSSet*)value_;
- (void)addValuesObject:(UXValue*)value_;
- (void)removeValuesObject:(UXValue*)value_;

@end

@interface _UXValueType (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;

- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;

- (NSMutableSet*)primitiveOptions;
- (void)setPrimitiveOptions:(NSMutableSet*)value;

- (NSMutableSet*)primitiveValues;
- (void)setPrimitiveValues:(NSMutableSet*)value;

@end
