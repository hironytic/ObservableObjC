//
// ObservablesTests.m
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

@interface ObservablesTests : XCTestCase
@end

@implementation ObservablesTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testPipe {
    NSMutableArray *values = [NSMutableArray new];
    id <OOCObservable> observable = [OOCObservables justWithValue:@100];
    id <OOCObservable> piped = [observable pipe:^(OOCPipeBuilder *it) {
        [it map:^(id value) { return @([value intValue] * 2); }];
        [it map:^(id value) { return @([value intValue] + 3); }];
        [it map:^(id value) { return @([value intValue] * 5); }];
    }];
    
    id <OOCCancellable> cancellable = [piped subscribe:^(id value) {
        [values addObject:value];
    }];
    [cancellable cancel];
    
    NSArray *expected = @[
        @1015,
        [OOCCompleted sharedCompleted]
    ];
    XCTAssertEqualObjects(values, expected);
}

- (void)testJust {
    NSMutableArray *values = [NSMutableArray new];
    id <OOCObservable> observable = [OOCObservables justWithValue:@100];
    id <OOCCancellable> cancellable = [observable subscribe:^(id value) {
        [values addObject:value];
    }];
    [cancellable cancel];

    NSArray *expected = @[
        @100,
        [OOCCompleted sharedCompleted]
    ];
    XCTAssertEqualObjects(values, expected);
}

- (void)testFrom {
    NSMutableArray *values = [NSMutableArray new];
    id <OOCObservable> observable = [OOCObservables fromValues:@[@1, @2, @3]];
    id <OOCCancellable> cancellable = [observable subscribe:^(id value) {
        [values addObject:value];
    }];
    [cancellable cancel];

    NSArray *expected = @[
        @1,
        @2,
        @3,
        [OOCCompleted sharedCompleted]
    ];
    XCTAssertEqualObjects(values, expected);
}

@end
