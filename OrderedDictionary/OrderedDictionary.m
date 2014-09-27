//
//  OrderedDictionary.m
//
//  Version 1.2 beta
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
#pragma GCC diagnostic ignored "-Wdirect-ivar-access"
#pragma GCC diagnostic ignored "-Wgnu"


#import <Availability.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif


@implementation OrderedDictionary
{
@protected
    NSArray *_values;
    NSOrderedSet *_keys;
}

- (Class)classForKeyedArchiver {
    return [OrderedDictionary class];
}

- (Class)classForCoder {
    return [OrderedDictionary class];
}

- (instancetype)initWithContentsOfOrderedFile:(NSString *)path {
    self = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    return self;
}

- (BOOL)writeToOrderedFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile {
    return [NSKeyedArchiver archiveRootObject:self toFile:path];
}

- (instancetype)initWithContentsOfFile:(NSString *)path {
    self = [super init];
    
    if (self) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        _keys = [NSOrderedSet orderedSetWithArray:dictionary.allKeys];
        NSMutableArray *values = [NSMutableArray arrayWithCapacity:_keys.count];
        
        for (id key in _keys) {
            [values addObject:dictionary[key]];
        }
        
        _values = values.copy;
    }
    
    return self;
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile {
    return [[NSDictionary dictionaryWithObjects:_values forKeys:_keys.array] writeToFile:path atomically:useAuxiliaryFile];
}

- (instancetype)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    self = [super init];
    
    if (self) {
        _keys = [NSOrderedSet orderedSetWithArray:keys];
        _values = objects.copy;
    }
    
    return self;
}

- (instancetype)initWithObjects:(const __unsafe_unretained id [])objects forKeys:(const __unsafe_unretained id <NSCopying> [])keys count:(NSUInteger)count
{
    if ((self = [super init]))
    {
        _values = [[NSArray alloc] initWithObjects:objects count:count];
        _keys = [[NSOrderedSet alloc] initWithObjects:keys count:count];
        
        NSAssert(_values.count == _keys.count, @"Invalid Keys");
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init]))
    {
        _values = [decoder decodeObjectOfClass:[NSArray class] forKey:@"values"];
        _keys = [decoder decodeObjectOfClass:[NSOrderedSet class] forKey:@"keys"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_values forKey:@"values"];
    [coder encodeObject:_keys forKey:@"values"];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    __typeof(self) copy = [[OrderedDictionary allocWithZone:zone] init];
    
    copy->_values = _values.copy;
    copy->_keys = _keys.copy;
    
    return copy;
}

- (instancetype)mutableCopyWithZone:(NSZone *)zone
{
    return [[MutableOrderedDictionary allocWithZone:zone] initWithDictionary:self];
}

- (NSArray *)allKeys {
    return _keys.array;
}

- (NSArray *)allValues {
    return _values.copy;
}

- (NSUInteger)count
{
    return [_keys count];
}

- (NSUInteger)indexOfKey:(id)key {
    return [_keys indexOfObject:key];
}

- (id)objectForKey:(id)key
{
    return _values[[_keys indexOfObject:key]];
}

- (NSEnumerator *)keyEnumerator
{
    return [_keys objectEnumerator];
}

- (NSEnumerator *)reverseKeyEnumerator
{
    return [_keys reverseObjectEnumerator];
}

- (NSEnumerator *)objectEnumerator
{
    return [_values objectEnumerator];
}

- (NSEnumerator *)reverseObjectEnumerator
{
    return [_values reverseObjectEnumerator];
}

- (void)enumerateKeysAndObjectsWithIndexUsingBlock:(void (^)(id key, id obj, NSUInteger idx, BOOL *stop))block
{
    [_keys enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
        block(key, self->_values[idx], idx, stop);
    }];
}

- (id)keyAtIndex:(NSUInteger)index
{
    return _keys[index];
}

- (id)objectAtIndex:(NSUInteger)index
{
    return _values[index];
}

- (id)objectAtIndexedSubscript:(NSUInteger)index
{
  return _values[index];
}

NS_INLINE NSString *descriptionForObject(id object, id locale, NSUInteger indent)
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
  
    NSUInteger index = 0;
    for (NSObject *key in _keys)
    {
        [description appendFormat:@"%@    %@ = %@;\n", padding,
         descriptionForObject(key, locale, indent),
         descriptionForObject(_values[index ++], locale, indent)];
    }
    [description appendFormat:@"%@}\n", padding];
    return description;
}

@end


@implementation MutableOrderedDictionary

- (instancetype)initWithContentsOfFile:(NSString *)path {
    self = [super init];
    
    if (self) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        _keys = (NSOrderedSet *)[NSMutableOrderedSet orderedSetWithArray:dictionary.allKeys];
        NSMutableArray *values = [NSMutableArray arrayWithCapacity:_keys.count];
        
        for (id key in _keys) {
            [values addObject:dictionary[key]];
        }
        
        _values = (NSArray *)values;
    }
    
    return self;
}

+ (instancetype)dictionaryWithCapacity:(NSUInteger)count
{
    return [(MutableOrderedDictionary *)[self alloc] initWithCapacity:count];
}

- (instancetype)initWithObjects:(const __unsafe_unretained id [])objects forKeys:(const __unsafe_unretained id <NSCopying> [])keys count:(NSUInteger)count
{
    if ((self = [super init]))
    {
        self->_values = [[NSMutableArray alloc] initWithObjects:objects count:count];
        self->_keys = [[NSMutableOrderedSet alloc] initWithObjects:keys count:count];
    }
    return self;
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    if ((self = [super init]))
    {
        _values = [[NSMutableArray alloc] initWithCapacity:capacity];
        _keys = [[NSMutableOrderedSet alloc] initWithCapacity:capacity];
    }
    return self;
}

- (id)init
{
    return [self initWithCapacity:0];
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init]))
    {
        _values = [decoder decodeObjectOfClass:[NSMutableArray class] forKey:@"values"];
        _keys = [decoder decodeObjectOfClass:[NSMutableOrderedSet class] forKey:@"keys"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[OrderedDictionary allocWithZone:zone] initWithDictionary:self];
}

- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary
{
    [otherDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, __unused BOOL *stop) {
        [self setObject:obj forKey:key];
    }];
}

- (void)insertObject:(id)object forKey:(id)key atIndex:(NSUInteger)index
{
    [self removeObjectForKey:key];
    [(NSMutableOrderedSet *)_keys insertObject:key atIndex:index];
    [(NSMutableArray *)_values insertObject:object atIndex:index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)object
{
    ((NSMutableArray *)_values)[index] = object;
}

- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)index
{
    ((NSMutableArray *)_values)[index] = object;
}

- (void)removeAllObjects
{
    [(NSMutableOrderedSet *)_keys removeAllObjects];
    [(NSMutableArray *)_values removeAllObjects];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [(NSMutableOrderedSet *)_keys removeObjectAtIndex:index];
    [(NSMutableArray *)_values removeObjectAtIndex:index];
}

- (void)removeObjectForKey:(id)key
{
    NSUInteger index = [self->_keys indexOfObject:key];
    if (index != NSNotFound)
    {
        [self removeObjectAtIndex:index];
    }
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
    [(NSMutableOrderedSet *)_keys removeAllObjects];
    [(NSMutableOrderedSet *)_keys addObjectsFromArray:[otherDictionary allKeys]];
    [(NSMutableArray *)_values setArray:[otherDictionary allValues]];
}

- (void)setObject:(id)object forKey:(id)key
{
    NSUInteger index = [_keys indexOfObject:key];
    if (index != NSNotFound)
    {
        ((NSMutableArray *)_values)[index] = object;
    }
    else
    {
        [(NSMutableOrderedSet *)_keys addObject:key];
        [(NSMutableArray *)_values addObject:object];
    }
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

- (void)setObject:(id)object forKeyedSubscript:(id <NSCopying>)key
{
    [self setObject:object forKey:key];
}

@end
