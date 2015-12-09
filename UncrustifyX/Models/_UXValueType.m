// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UXValueType.m instead.

#import "_UXValueType.h"

const struct UXValueTypeAttributes UXValueTypeAttributes = {
	.createdAt = @"createdAt",
	.type = @"type",
	.updatedAt = @"updatedAt",
};

const struct UXValueTypeRelationships UXValueTypeRelationships = {
	.options = @"options",
	.values = @"values",
};

@implementation UXValueTypeID
@end

@implementation _UXValueType

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UXValueType" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UXValueType";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UXValueType" inManagedObjectContext:moc_];
}

- (UXValueTypeID*)objectID {
	return (UXValueTypeID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic createdAt;

@dynamic type;

@dynamic updatedAt;

@dynamic options;

- (NSMutableSet*)optionsSet {
	[self willAccessValueForKey:@"options"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"options"];

	[self didAccessValueForKey:@"options"];
	return result;
}

@dynamic values;

- (NSMutableSet*)valuesSet {
	[self willAccessValueForKey:@"values"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"values"];

	[self didAccessValueForKey:@"values"];
	return result;
}

@end

