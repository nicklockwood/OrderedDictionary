//
//  UnitTests.m
//
//  Created by Nick Lockwood on 12/01/2012.
//  Copyright (c) 2012 Charcoal Design. All rights reserved.
//


#import <XCTest/XCTest.h>
#import "OrderedDictionary.h"


#pragma GCC diagnostic ignored "-Wdirect-ivar-access"


@interface UnitTests : XCTestCase

@end


@implementation UnitTests
{
    MutableOrderedDictionary *d;
}

- (void)setUp
{
    d = [MutableOrderedDictionary dictionary];
    d[@"0"] = @1;
    d[@"2"] = @3;
    d[@"1"] = @2;
    d[@"3"] = @4;
    d[@"1"] = @7;
    [d removeObjectForKey:@"3"];
}

- (void)testAssumptions
{
    NSMutableDictionary *d2 = [NSMutableDictionary dictionary];
    d2[@"0"] = @1;
    d2[@"2"] = @3;
    d2[@"1"] = @2;
    d2[@"3"] = @4;
    d2[@"1"] = @7;
    [d2 removeObjectForKey:@"3"];
    
    XCTAssertNotEqualObjects([d2 allKeys], (@[@"0",@"2",@"1"]));
    XCTAssertEqualObjects(d[@"0"], @1);
    XCTAssertEqualObjects(d[@"1"], @7);
    XCTAssertEqualObjects(d[@"2"], @3);
}

- (void)testOrderPreserved
{
    XCTAssertEqualObjects([d allKeys], (@[@"0",@"2",@"1"]));
    XCTAssertEqualObjects(d[0], @1);
    XCTAssertEqualObjects(d[1], @3);
    XCTAssertEqualObjects(d[2], @7);
}

- (void)testIndexOfKey
{
    XCTAssertEqual([d indexOfKey:@"2"], 1);
    XCTAssertEqual([d indexOfKey:@"1"], 2);
}

- (void)testNSCoding
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:d];
    MutableOrderedDictionary *d2 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    XCTAssertEqualObjects([d class], [d2 class]);
    XCTAssertEqualObjects(d, d2);
    XCTAssertEqualObjects(d[0], @1);
    XCTAssertEqualObjects(d[1], @3);
    XCTAssertEqualObjects(d[2], @7);
}

- (void)testEmptyDictIsASingleton
{
    OrderedDictionary *d1 = [[OrderedDictionary alloc] init];
    OrderedDictionary *d2 = [[OrderedDictionary alloc] init];
    XCTAssertEqual(d1, d2);
}

- (void)testEmptyDictBehavesCorrectly
{
    OrderedDictionary *d1 = [[OrderedDictionary alloc] init];
    XCTAssertEqualObjects([d1 allKeys], [[[NSDictionary alloc] init] allKeys]);
    XCTAssertEqualObjects([d1 allValues], [[[NSDictionary alloc] init] allValues]);
    XCTAssertEqual([d1 keyEnumerator] != nil, [[[NSDictionary alloc] init] keyEnumerator] != nil);
    XCTAssertEqual([d1 objectEnumerator] != nil, [[[NSDictionary alloc] init] objectEnumerator] != nil);
    
    MutableOrderedDictionary *d2 = [d1 mutableCopy];
    d2[@"foo"] = @"bar";
    
    XCTAssertEqualObjects([d2 class], [MutableOrderedDictionary class]);
    XCTAssertEqualObjects(d2[@"foo"], @"bar");
}

static NSString *samplePlist()
{
    return @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n"
    "<plist version=\"1.0\">\n"
    "<dict>\n"
    "\t<key>0</key>\n"
    "\t<integer>1</integer>\n"
    "\t<key>2</key>\n"
    "\t<integer>3</integer>\n"
    "\t<key>1</key>\n"
    "\t<integer>7</integer>\n"
    "</dict>\n"
    "</plist>\n";
}

- (void)testWriting
{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"OrderedDictionary.plist"];
    XCTAssertTrue([d writeToFile:path atomically:YES]);
    NSError *error = nil;
    NSString *plist = [NSString stringWithContentsOfFile:path usedEncoding:NULL error:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(plist, samplePlist());
}

- (void)testReading
{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"OrderedDictionary.plist"];
    NSError *error = nil;
    XCTAssertTrue([samplePlist() writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error]);
    XCTAssertNil(error);
    
    MutableOrderedDictionary *d2 = [MutableOrderedDictionary dictionaryWithContentsOfFile:path];
    XCTAssertEqualObjects([d2 class], [MutableOrderedDictionary class]);
    XCTAssertEqualObjects([d2 allKeys], (@[@"0",@"2",@"1"]));
    XCTAssertEqualObjects(d, d2);
    
    d2 = [[MutableOrderedDictionary alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
    XCTAssertEqualObjects([d2 class], [MutableOrderedDictionary class]);
    XCTAssertEqualObjects([d2 allKeys], (@[@"0",@"2",@"1"]));
    XCTAssertEqualObjects(d, d2);
}

- (void)testDescription
{
    OrderedDictionary *d1 = [OrderedDictionary dictionaryWithObject:@{
        @"hello": [NSDate new],
        @"world": @[@1, @3.5],
        @"goodbye": @NO,
    } forKey:@"foo"];
    NSDictionary *d2 = [NSDictionary dictionaryWithDictionary:d1];
    XCTAssertEqualObjects([d1 description], [d2 description]);
    XCTAssertEqualObjects([d1 descriptionWithLocale:[NSLocale currentLocale]], [d2 descriptionWithLocale:[NSLocale currentLocale]]);
    XCTAssertEqualObjects([d1 descriptionWithLocale:[NSLocale currentLocale] indent:1], [d2 descriptionWithLocale:[NSLocale currentLocale] indent:1]);
}

@end
