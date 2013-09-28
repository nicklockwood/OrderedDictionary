//
//  OrderedDictionary.h
//
//  Version 1.1
//
//  Created by Nick Lockwood on 21/09/2010.
//  Copyright 2010 Charcoal Design. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Ordered subclass of NSDictionary.
 * Supports all the same methods as NSDictionary, plus a few
 * new methods for operating on entities by index rather than key.
 */
@interface OrderedDictionary : NSDictionary

/** Returns the nth key in the dictionary. */
- (id)keyAtIndex:(NSUInteger)index;
/** Returns the nth object in the dictionary. */
- (id)objectAtIndex:(NSUInteger)index;
/** Returns an enumerator for backwards traversal of the dictionary keys. */
- (NSEnumerator *)reverseKeyEnumerator;
/** Returns an enumerator for backwards traversal of the dictionary objects. */
- (NSEnumerator *)reverseObjectEnumerator;

@end


/**
 * Mutable subclass of OrderedDictionary.
 * Supports all the same methods as NSMutableDictionary, plus a few
 * new methods for operating on entities by index rather than key.
 * Note that although it has the same interface, MutableOrderedDictionary
 * is not a subclass of NSMutableDictionary, and cannot be used as one
 * without generating compiler warnings. Use OrderedMutableDictionary instead
 * if you need this functionality.
 */
@interface MutableOrderedDictionary : OrderedDictionary

+ (id)dictionaryWithCapacity:(NSUInteger)count;
- (id)initWithCapacity:(NSUInteger)count;

- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary;
- (void)removeAllObjects;
- (void)removeObjectForKey:(id)key;
- (void)removeObjectsForKeys:(NSArray *)keyArray;
- (void)setDictionary:(NSDictionary *)otherDictionary;
- (void)setObject:(id)object forKey:(id)key;
- (void)setValue:(id)value forKey:(NSString *)key;

/** Inserts an object at a specific index in the dictionary. */
- (void)insertObject:(id)object forKey:(id)key atIndex:(NSUInteger)index;
/** Removes the nth object in the dictionary. */
- (void)removeObjectAtIndex:(NSUInteger)index;

@end
