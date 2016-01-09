// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UXValue.m instead.

#import "_UXValue.h"

const struct UXValueAttributes UXValueAttributes = {
	.createdAt = @"createdAt",
	.updatedAt = @"updatedAt",
	.value = @"value",
};

const struct UXValueRelationships UXValueRelationships = {
	.valueType = @"valueType",
};

@implementation UXValueID
@end

@implementation _UXValue

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UXValue" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UXValue";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UXValue" inManagedObjectContext:moc_];
}

- (UXValueID*)objectID {
	return (UXValueID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic createdAt;

@dynamic updatedAt;

@dynamic value;

@dynamic valueType;

@end

