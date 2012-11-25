// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UXAbstractCategory.m instead.

#import "_UXAbstractCategory.h"

const struct UXAbstractCategoryAttributes UXAbstractCategoryAttributes = {
	.createdAt = @"createdAt",
	.name = @"name",
	.updatedAt = @"updatedAt",
};

const struct UXAbstractCategoryRelationships UXAbstractCategoryRelationships = {
};

const struct UXAbstractCategoryFetchedProperties UXAbstractCategoryFetchedProperties = {
};

@implementation UXAbstractCategoryID
@end

@implementation _UXAbstractCategory

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UXAbstractCategory" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UXAbstractCategory";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UXAbstractCategory" inManagedObjectContext:moc_];
}

- (UXAbstractCategoryID*)objectID {
	return (UXAbstractCategoryID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic createdAt;






@dynamic name;






@dynamic updatedAt;











@end
