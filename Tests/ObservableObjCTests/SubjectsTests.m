//
// SubjectsTests.m
// 
//
// Copyright (c) 2021 Hironori Ichimiya <hiron@hironytic.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <XCTest/XCTest.h>
@import ObservableObjC;

@interface SubjectsTests : XCTestCase

@end

@implementation SubjectsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testPublishSubject {
    NSMutableArray *values = [NSMutableArray new];
    OOCPublishSubject *subject = [OOCPublishSubject new];
    OOCCancellable cancellable = subject.observable(^(id value) {
        [values addObject:value];
    });
    
    subject.send(@10);
    subject.send(@"foo");
    
    NSArray *expected1 = @[@10, @"foo"];
    XCTAssertEqualObjects(values, expected1);
    
    subject.send(@"bar");

    NSArray *expected2 = @[@10, @"foo", @"bar"];
    XCTAssertEqualObjects(values, expected2);

    cancellable();
    
    subject.send(@20);
    XCTAssertEqualObjects(values, expected2);
}

- (void)testBehaviorSubject {
    NSMutableArray *values1 = [NSMutableArray new];
    NSMutableArray *values2 = [NSMutableArray new];
    
    OOCBehaviorSubject *subject = [[OOCBehaviorSubject alloc] initWithInitialValue:@20];
    
    OOCCancellable cancellable1 = subject.observable(^(id value) {
        [values1 addObject:value];
    });

    NSArray *expected1 = @[@20];
    XCTAssertEqualObjects(values1, expected1);
    
    subject.value = @40;

    NSArray *expected2 = @[@20, @40];
    XCTAssertEqualObjects(values1, expected2);

    OOCCancellable cancellable2 = subject.observable(^(id value) {
        [values2 addObject:value];
    });

    NSArray *expected3 = @[@40];
    XCTAssertEqualObjects(values2, expected3);

    subject.send(@60);
    
    NSArray *expected4 = @[@20, @40, @60];
    XCTAssertEqualObjects(values1, expected4);
    NSArray *expected5 = @[@40, @60];
    XCTAssertEqualObjects(values2, expected5);

    cancellable1();
    
    subject.value = @80;
    
    XCTAssertEqualObjects(values1, expected4);
    NSArray *expected6 = @[@40, @60, @80];
    XCTAssertEqualObjects(values2, expected6);

    XCTAssertEqualObjects(subject.value, @80);

    cancellable2();
}

@end
