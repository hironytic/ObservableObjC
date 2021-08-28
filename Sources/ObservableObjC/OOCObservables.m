//
// OOCObservables.m
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

#import "OOCObservables.h"
#import "OOCAnonymousCancellable.h"
#import "OOCCompleted.h"
#import "OOCObservableBase.h"
#import "OOCObserver.h"

// MARK: - OOCAnonymousObservable : OOCObservableBase <OOCObservable>

@interface OOCAnonymousObservable : OOCObservableBase <OOCObservable>
@property(nonatomic, copy) id <OOCCancellable> (^subscribe)(id <OOCObserver>);
@end

@implementation OOCAnonymousObservable

- (id <OOCCancellable>)subscribeByObserver:(id <OOCObserver>)observer {
    return self.subscribe(observer);
}

@end


// MARK: - OOCJust

@interface OOCJust : OOCObservableBase <OOCObservable>
@property(nonatomic, strong) id value;
@end

@implementation OOCJust

- (id <OOCCancellable>)subscribeByObserver:(id <OOCObserver>)observer {
    [observer onValue:self.value];
    [observer onValue:[OOCCompleted sharedCompleted]];
    return [OOCAnonymousCancellable new];
}

@end

// MARK: - OOCFrom

@interface OOCFrom : OOCObservableBase <OOCObservable>
@property(nonatomic, strong) NSArray *values;
@end

@implementation OOCFrom

- (id <OOCCancellable>)subscribeByObserver:(id <OOCObserver>)observer {
    for (id value in self.values) {
        [observer onValue:value];
    }
    [observer onValue:[OOCCompleted sharedCompleted]];
    return [OOCAnonymousCancellable new];
}

@end

// MARK: - OOCObservables

@implementation OOCObservables

+ (id <OOCObservable>)create:(id <OOCCancellable> (^)(id <OOCObserver>))subscribe {
    OOCAnonymousObservable *observable = [OOCAnonymousObservable new];
    observable.subscribe = subscribe;
    return observable;
}

+ (id <OOCObservable>)justWithValue:(id)value {
    OOCJust *just = [OOCJust new];
    just.value = value;
    return just;
}

+ (id <OOCObservable>)fromValues:(NSArray *)values {
    OOCFrom *from = [OOCFrom new];
    from.values = values;
    return from;
}

@end
