//
//  FastCoderTests.m
//
//  Created by Nick Lockwood on 12/01/2012.
//  Copyright (c) 2012 Charcoal Design. All rights reserved.
//


#import <XCTest/XCTest.h>
#import "OrderedDictionary.h"


@interface UnitTests : XCTestCase

@end


@implementation UnitTests

- (void)testOrderPreserved
{
  MutableOrderedDictionary *d = [MutableOrderedDictionary dictionary];
  d[@0] = @1;
  d[@1] = @2;
  d[@2] = @3;
  d[@1] = @7;
  
  XCTAssertEqualObjects(d[0], @1);
  XCTAssertEqualObjects(d[1], @7);
  XCTAssertEqualObjects(d[2], @3);
}

@end
