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

#import <XCTest/XCTest.h>
#import "OrderedDictionary.h"

@interface OrderedDictionaryTests : XCTestCase

@property (nonatomic, strong) MutableOrderedDictionary *d;


@end

@implementation OrderedDictionaryTests

- (void)setUp {
    [super setUp];
    
    self.d = [MutableOrderedDictionary dictionary];
    
    self.d[@"0"] = @1;
    self.d[@"1"] = @2;
    self.d[@"3"] = @4;
    self.d[@"2"] = @3;
    self.d[@"1"] = @7;
    [self.d removeObjectForKey:@"3"];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAssumptions
{
    NSMutableDictionary *d2 = [NSMutableDictionary dictionary];
    d2[@"0"] = @1;
    d2[@"1"] = @2;
    d2[@"3"] = @4;
    d2[@"2"] = @3;
    d2[@"1"] = @7;
    [d2 removeObjectForKey:@"3"];
    
    XCTAssertNotEqualObjects([d2 allKeys], (@[@"0",@"1",@"2"]));
    XCTAssertEqualObjects(self.d[@"0"], @1);
    XCTAssertEqualObjects(self.d[@"1"], @7);
    XCTAssertEqualObjects(self.d[@"2"], @3);
}

- (void)testOrderPreserved
{
    XCTAssertEqualObjects([self.d allKeys], (@[@"0",@"1",@"2"]));
    XCTAssertEqualObjects(self.d[0], @1);
    XCTAssertEqualObjects(self.d[1], @7);
    XCTAssertEqualObjects(self.d[2], @3);
}

- (void)testIndexOfKey
{
    XCTAssertEqual([self.d indexOfKey:@"2"], 2);
    XCTAssertEqual([self.d indexOfKey:@"1"], 1);
}

- (void)testNSCoding
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.d];
    MutableOrderedDictionary *d2 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    XCTAssertEqualObjects([self.d class], [d2 class]);
    XCTAssertEqualObjects(self.d, d2);
    XCTAssertEqualObjects(self.d[0], @1);
    XCTAssertEqualObjects(self.d[1], @7);
    XCTAssertEqualObjects(self.d[2], @3);
}

static NSString *samplePlist()
{
    return @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n"
    "<plist version=\"1.0\">\n"
    "<dict>\n"
    "\t<key>0</key>\n"
    "\t<integer>1</integer>\n"
    "\t<key>1</key>\n"
    "\t<integer>7</integer>\n"
    "\t<key>2</key>\n"
    "\t<integer>3</integer>\n"
    "</dict>\n"
    "</plist>\n";
}

- (void)testWriting
{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"OrderedDictionary.plist"];
    XCTAssertTrue([self.d writeToFile:path atomically:YES]);
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
    XCTAssertEqualObjects([d2 allKeys], (@[@"0",@"1",@"2"]));
    XCTAssertEqualObjects(self.d, d2);
    
    d2 = [[MutableOrderedDictionary alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
    XCTAssertEqualObjects([d2 class], [MutableOrderedDictionary class]);
    XCTAssertEqualObjects([d2 allKeys], (@[@"0",@"1",@"2"]));
    XCTAssertEqualObjects(self.d, d2);
}

- (void)testDescription
{
    NSDictionary *d2 = [NSDictionary dictionaryWithDictionary:self.d];
    XCTAssertEqualObjects([self.d description], [d2 description]);
    XCTAssertEqualObjects([self.d descriptionWithLocale:[NSLocale currentLocale]], [d2 descriptionWithLocale:[NSLocale currentLocale]]);
    XCTAssertEqualObjects([self.d descriptionWithLocale:[NSLocale currentLocale] indent:1], [self.d descriptionWithLocale:[NSLocale currentLocale] indent:1]);
}

@end
