//
//  BasicTypes.m
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

#import "BasicTypes.h"
#import "OOCPipeBuilder.h"

// MARK: - OOCAnonymousObserver

@interface OOCAnonymousObserver ()
@property(nonatomic, copy) OOCSubscriber subscriber;
@end

@implementation OOCAnonymousObserver

- (instancetype)init {
    return [self initWithSubscriber:^(id value) {}];
}

- (instancetype)initWithSubscriber:(OOCSubscriber)subscriber {
    self = [super init];
    if (self != nil) {
        _subscriber = subscriber;
    }
    return self;
}

- (void)onValue:(id)value {
    _subscriber(value);
}

@end

// MARK: - OOCAnonymousCancellable

@interface OOCAnonymousCancellable ()
@property(nonatomic, copy) void (^handler)(void);
@end

@implementation OOCAnonymousCancellable

- (instancetype)init {
    return [self initWithHandler:^{}];
}

- (instancetype)initWithHandler:(void (^)(void))handler {
    self = [super init];
    if (self != nil) {
        _handler = handler;
    }
    return self;
}

- (void)cancel {
    _handler();
}

@end

// MARK: - OOCObservableBase

@interface OOCObservableBase ()
@end

@implementation OOCObservableBase

- (id <OOCObservable>)pipe:(void (^)(OOCPipeBuilder *))buildBlock {
    OOCPipeBuilder *builder = [OOCPipeBuilder new];
    buildBlock(builder);
    
    NSArray<id <OOCOperator>> *operators = [builder build];
    
    id <OOCObservable> result = self;
    for (id <OOCOperator> operator in operators) {
        result = [operator transformFrom:result];
    }
    return result;
}

- (id <OOCCancellable>)subscribe:(OOCSubscriber)subscriber {
    return [self subscribeByObserver:[[OOCAnonymousObserver alloc] initWithSubscriber:subscriber]];
}

- (id <OOCCancellable>)subscribeByObserver:(id <OOCObserver>)observer {
    return [OOCAnonymousCancellable new];
}

@end

// MARK: - OOCCompleted

@implementation OOCCompleted

+ (instancetype)sharedCompleted {
    static OOCCompleted *_sharedCompleted = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedCompleted = [self new];
    });
    return _sharedCompleted;
}

- (BOOL)isEqual:(id)object {
    return ([object isKindOfClass:[OOCCompleted class]]);
}

- (NSUInteger)hash {
    return 0;
}

- (NSString *)description {
    return @"completed";
}

@end

BOOL OOCIsTerminator(id value) {
    return ([value isKindOfClass:[OOCCompleted class]] || [value isKindOfClass:[NSError class]]);
}
