//
// OOCPipeBuilder.m
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

#import "OOCPipeBuilder.h"
#import "OOCObservables.h"

// MARK: - OOCMap

@interface OOCMap : NSObject <OOCOperator>
@property(nonatomic, copy) id (^proc)(id value);
@end

@implementation OOCMap

- (id <OOCObservable>)transformFrom:(id <OOCObservable>)observable {
    return [OOCObservables create:^(id <OOCObserver> observer) {
        return [observable subscribe:^(id value) {
            if ([value ooc_isTerminator]) {
                [observer onValue:value];
            } else {
                [observer onValue:self.proc(value)];
            }
        }];
    }];
}

@end

// MARK: - OOCFilter

@interface OOCFilter : NSObject <OOCOperator>
@property(nonatomic, copy) BOOL (^proc)(id value);
@end

@implementation OOCFilter

- (id <OOCObservable>)transformFrom:(id <OOCObservable>)observable {
    return [OOCObservables create:^(id <OOCObserver> observer) {
        return [observable subscribe:^(id value) {
            if ([value ooc_isTerminator] || self.proc(value)) {
                [observer onValue:value];
            }
        }];
    }];
}

@end

// MARK: - OOCOperators

@interface OOCPipeBuilder ()
@property(nonatomic, strong) NSMutableArray<id <OOCOperator>> *operators;
@end

@implementation OOCPipeBuilder

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _operators = [NSMutableArray new];
    }
    return self;
}

- (NSArray<id<OOCOperator>> *)build {
    return self.operators;
}

- (void)map:(id (^)(id value))proc {
    OOCMap *operator = [OOCMap new];
    operator.proc = proc;
    [self.operators addObject:operator];
}

- (void)filter:(BOOL (^)(id value))proc {
    OOCFilter *operator = [OOCFilter new];
    operator.proc = proc;
    [self.operators addObject:operator];
}

@end
