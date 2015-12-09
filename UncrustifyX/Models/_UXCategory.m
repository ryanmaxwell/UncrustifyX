// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UXCategory.m instead.

#import "_UXCategory.h"

const struct UXCategoryRelationships UXCategoryRelationships = {
	.options = @"options",
	.subcategories = @"subcategories",
};

@implementation UXCategoryID
@end

@implementation _UXCategory

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UXCategory" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UXCategory";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UXCategory" inManagedObjectContext:moc_];
}

- (UXCategoryID*)objectID {
	return (UXCategoryID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic options;

- (NSMutableSet*)optionsSet {
	[self willAccessValueForKey:@"options"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"options"];

	[self didAccessValueForKey:@"options"];
	return result;
}

@dynamic subcategories;

- (NSMutableSet*)subcategoriesSet {
	[self willAccessValueForKey:@"subcategories"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"subcategories"];

	[self didAccessValueForKey:@"subcategories"];
	return result;
}

@end

