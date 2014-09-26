//
//  OrderedDictionary.m
//
//  Version 1.1.1
//
//  Created by Nick Lockwood on 21/09/2010.
//  Copyright 2010 Charcoal Design
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/OrderedDictionary
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "OrderedDictionary.h"


#pragma GCC diagnostic ignored "-Wobjc-missing-property-synthesis"
#pragma GCC diagnostic ignored "-Wgnu"


#import <Availability.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif


@interface OrderedDictionaryReverseObjectEnumerator : NSEnumerator

@property (nonatomic, copy) NSOrderedSet *keys;
@property (nonatomic, copy) NSDictionary *values;
@property (nonatomic, assign) NSInteger index;

+ (id)enumeratorWithKeys:(NSOrderedSet *)keys values:(NSDictionary *)values;
- (id)initWithKeys:(NSOrderedSet *)keys values:(NSDictionary *)values;

@end


@implementation OrderedDictionaryReverseObjectEnumerator

+ (id)enumeratorWithKeys:(NSOrderedSet *)keys values:(NSDictionary *)values
{
    return [[self alloc] initWithKeys:keys values:values];
}

- (id)initWithKeys:(NSOrderedSet *)keys values:(NSDictionary *)values
{
    if ((self = [super init]))
    {
        _keys = [keys copy];
        _values = [values copy];
        _index = (NSInteger)[keys count] - 1;
    }
    return self;
}

- (id)nextObject
{
    return (self.index < 0)? nil: self.values[self.keys[(NSUInteger)self.index--]];
}

@end


@interface OrderedDictionary ()

@property (nonatomic, strong) NSDictionary *values;
@property (nonatomic, strong) NSOrderedSet *keys;

@end


@implementation OrderedDictionary

- (Class)classForKeyedArchiver {
    return [OrderedDictionary class];
}

- (Class)classForCoder {
    return [OrderedDictionary class];
}

- (instancetype)initWithContentsOfFile:(NSString *)path {
    self = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    return self;
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile {
    return [NSKeyedArchiver archiveRootObject:self toFile:path];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.values forKey:@"values"];
    [aCoder encodeObject:self.keys forKey:@"keys"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        _values = [aDecoder decodeObjectForKey:@"values"];
        _keys = [aDecoder decodeObjectForKey:@"keys"];
    }
    
    return self;
}

- (instancetype)initWithObjects:(const __unsafe_unretained id [])objects forKeys:(const __unsafe_unretained id <NSCopying> [])keys count:(NSUInteger)count
{
    if ((self = [super init]))
    {
        NSMutableDictionary *values_ = [[NSMutableDictionary alloc] initWithCapacity:count];
        NSMutableOrderedSet *keys_ = [[NSMutableOrderedSet alloc] initWithCapacity:count];
        
        for (NSUInteger i = 0; i < count; i++)
        {
            if (!values_[keys[i]])
            {
                [keys_ addObject:keys[i]];
            }
            values_[keys[i]] = objects[i];
        }
        
        self.keys = keys_.copy;
        self.values = values_.copy;
    }
    return self;
}

- (id)copyWithZone:(__unused NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [[MutableOrderedDictionary allocWithZone:zone] initWithDictionary:self];
}

- (NSArray *)allKeys {
    return self.keys.array;
}

- (NSArray *)allValues {
    return self.values.allValues;
}

- (NSUInteger)count
{
    return [self.keys count];
}

- (id)objectForKey:(id)key
{
    return self.values[key];
}

- (id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}

- (NSEnumerator *)keyEnumerator
{
    return [self.keys objectEnumerator];
}

- (NSEnumerator *)reverseKeyEnumerator
{
    return [self.keys reverseObjectEnumerator];
}

- (NSEnumerator *)reverseObjectEnumerator
{
    return [OrderedDictionaryReverseObjectEnumerator enumeratorWithKeys:self.keys values:self.values];
}

- (void)enumerateKeysAndObjectsWithIndexUsingBlock:(void (^)(id key, id obj, NSUInteger idx, BOOL *stop))block
{
    [self.keys enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
        block(key, self.values[key], idx, stop);
    }];
}

- (id)keyAtIndex:(NSUInteger)index
{
    return self.keys[index];
}

- (NSUInteger)indexOfKey:(id)key {
    return [self.keys indexOfObject:key];
}

- (id)objectAtIndex:(NSUInteger)index
{
    return self.values[self.keys[index]];
}

- (NSString *)descriptionForObject:(id)object locale:(id)locale indent:(NSUInteger)indent
{
    if ([object respondsToSelector:@selector(descriptionWithLocale:indent:)])
    {
        return [object descriptionWithLocale:locale indent:indent];
    }
    else if ([object respondsToSelector:@selector(descriptionWithLocale:)])
    {
        return [object descriptionWithLocale:locale];
    }
    else
    {
        return [object description];
    }
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)indent
{
    NSMutableString *padding = [NSMutableString string];
    for (NSUInteger i = 0; i < indent; i++)
    {
        [padding appendString:@"    "];
    }
    
    NSMutableString *description = [NSMutableString string];
    [description appendFormat:@"%@{\n", padding];
    for (NSObject *key in self.keys)
    {
        [description appendFormat:@"%@    %@ = %@;\n", padding,
         [self descriptionForObject:key locale:locale indent:indent],
         [self descriptionForObject:self[key] locale:locale indent:indent]];
    }
    [description appendFormat:@"%@}\n", padding];
    return description;
}

@end


@interface MutableOrderedDictionary ()

@property (nonatomic, strong) NSMutableDictionary *values;
@property (nonatomic, strong) NSMutableOrderedSet *keys;

@end

@implementation MutableOrderedDictionary

- (Class)classForKeyedArchiver {
    return [MutableOrderedDictionary class];
}

- (Class)classForCoder {
    return [MutableOrderedDictionary class];
}

+ (id)dictionaryWithCapacity:(NSUInteger)count
{
    return [[self alloc] initWithCapacity:count];
}

- (instancetype)initWithObjects:(const __unsafe_unretained id [])objects forKeys:(const __unsafe_unretained id <NSCopying> [])keys count:(NSUInteger)count
{
    if ((self = [super init]))
    {
        NSMutableDictionary *values_ = [[NSMutableDictionary alloc] initWithCapacity:count];
        NSMutableOrderedSet *keys_ = [[NSMutableOrderedSet alloc] initWithCapacity:count];
        
        for (NSUInteger i = 0; i < count; i++)
        {
            if (!values_[keys[i]])
            {
                [keys_ addObject:keys[i]];
            }
            values_[keys[i]] = objects[i];
        }
        
        self.keys = keys_;
        self.values = values_;
    }
    return self;
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    if ((self = [super init]))
    {
        self.values = [NSMutableDictionary dictionaryWithCapacity:capacity];
        self.keys = [NSMutableOrderedSet orderedSetWithCapacity:capacity];
    }
    return self;
}

- (id)init
{
    return [self initWithCapacity:0];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[OrderedDictionary allocWithZone:zone] initWithDictionary:self];
}

- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary
{
    for (id key in otherDictionary)
    {
        [self setObject:otherDictionary[key] forKey:key];
    }
}

- (void)insertObject:(id)object forKey:(id)key atIndex:(NSUInteger)index
{
    if (self.values[key])
    {
        if ([self.keys[index] isEqual:key])
        {
            self.values[key] = object;
            return;
        }
        [self removeObjectForKey:key];
    }
    [self.keys insertObject:key atIndex:index];
    self.values[key] = object;
}

- (void)removeAllObjects
{
    [self removeObjectsForKeys:[self allKeys]];
}

- (void)removeObjectsAtIndices:(NSIndexSet *)indexSet {
    __block NSUInteger deleted = 0;
    
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self removeObjectAtIndex:idx-deleted];
        deleted++;
    }];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [self removeObjectForKey:[self keyAtIndex:index]];
}

- (void)removeObjectForKey:(id)key
{
    [self.values removeObjectForKey:key];
    [self.keys removeObject:key];
}

- (void)removeObjectsForKeys:(NSArray *)keyArray
{
    for (id key in [keyArray copy])
    {
        [self removeObjectForKey:key];
    }
}

- (void)setDictionary:(NSDictionary *)otherDictionary
{
    [self removeAllObjects];
    [self addEntriesFromDictionary:otherDictionary];
}

- (void)setObject:(id)object forKey:(id)key
{
    if (!self.values[key])
    {
        [self.keys addObject:key];
    }
    self.values[key] = object;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if (value)
    {
        [self setObject:value forKey:key];
    }
    else
    {
        [self removeObjectForKey:key];
    }
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key
{
    [self setValue:object forKey:key];
}

@end
