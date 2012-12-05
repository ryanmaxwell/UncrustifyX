// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UXSubcategory.m instead.

#import "_UXSubcategory.h"

const struct UXSubcategoryAttributes UXSubcategoryAttributes = {
};

const struct UXSubcategoryRelationships UXSubcategoryRelationships = {
	.options = @"options",
	.parentCategories = @"parentCategories",
};

const struct UXSubcategoryFetchedProperties UXSubcategoryFetchedProperties = {
};

@implementation UXSubcategoryID
@end

@implementation _UXSubcategory

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UXSubcategory" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UXSubcategory";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UXSubcategory" inManagedObjectContext:moc_];
}

- (UXSubcategoryID*)objectID {
	return (UXSubcategoryID*)[super objectID];
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
	

@dynamic parentCategories;

	
- (NSMutableSet*)parentCategoriesSet {
	[self willAccessValueForKey:@"parentCategories"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"parentCategories"];
  
	[self didAccessValueForKey:@"parentCategories"];
	return result;
}
	






@end
