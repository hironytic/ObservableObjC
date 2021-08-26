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

@end
