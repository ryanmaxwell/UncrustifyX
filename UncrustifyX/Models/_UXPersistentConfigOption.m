// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UXPersistentConfigOption.m instead.

#import "_UXPersistentConfigOption.h"

const struct UXPersistentConfigOptionAttributes UXPersistentConfigOptionAttributes = {
	.createdAt = @"createdAt",
	.updatedAt = @"updatedAt",
	.value = @"value",
};

const struct UXPersistentConfigOptionRelationships UXPersistentConfigOptionRelationships = {
	.option = @"option",
};

@implementation UXPersistentConfigOptionID
@end

@implementation _UXPersistentConfigOption

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UXPersistentConfigOption" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UXPersistentConfigOption";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UXPersistentConfigOption" inManagedObjectContext:moc_];
}

- (UXPersistentConfigOptionID*)objectID {
	return (UXPersistentConfigOptionID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic createdAt;

@dynamic updatedAt;

@dynamic value;

@dynamic option;

@end

