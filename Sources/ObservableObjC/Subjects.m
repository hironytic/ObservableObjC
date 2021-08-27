//
// Subjects.m
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

#import "Subjects.h"
#import "OOCObserverList.h"

// MARK: - OOCPublishSubject

@interface OOCPublishSubject ()
@property(nonatomic, strong) OOCObserverList *observerList;
@property(nonatomic, strong) id terminatedBy;

@end

@implementation OOCPublishSubject

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _observerList = [OOCObserverList new];
        _terminatedBy = nil;
    }
    return self;
}

- (void)onValue:(id)value {
    if (self.terminatedBy != nil) { return; }
    
    [self.observerList sendToAllObservers:value];
    if (OOCIsTerminator(value)) {
        self.terminatedBy = value;
        [self.observerList removeAllObservers];
    }
}

- (id<OOCCancellable>)subscribeByObserver:(id<OOCObserver>)observer {
    if (self.terminatedBy == nil) {
        [self.observerList addObserver:observer];
        OOCPublishSubject * __weak weakSelf = self;
        return [[OOCAnonymousCancellable alloc] initWithHandler:^{
            if (weakSelf != nil && weakSelf.terminatedBy == nil) {
                [weakSelf.observerList removeObserver:observer];
            }
        }];
    } else {
        [observer onValue:self.terminatedBy];
        return [OOCAnonymousCancellable new];
    }
}

@end

// MARK: - OOCBehaviourSubject

@interface OOCBehaviorSubject ()
@property(nonatomic, strong) OOCPublishSubject *publisher;
@property(nonatomic, strong) id currentValue;
@end

@implementation OOCBehaviorSubject

-(instancetype)init {
    return [self initWithInitialValue:[NSNull null]];
}

-(instancetype)initWithInitialValue:(id)value {
    self = [super init];
    if (self != nil) {
        _currentValue = value;
        _publisher = [OOCPublishSubject new];
    }
    return self;
}

- (void)onValue:(id)value {
    self.value = value;
}

- (id<OOCCancellable>)subscribeByObserver:(id<OOCObserver>)observer {
    [observer onValue:self.currentValue];
    if (OOCIsTerminator(self.currentValue)) {
        return [OOCAnonymousCancellable new];
    } else {
        return [self.publisher subscribeByObserver:observer];
    }
}

- (id)value {
    return self.currentValue;
}

- (void)setValue:(id)value {
    if (OOCIsTerminator(self.currentValue)) {
        return;
    }

    self.currentValue = value;
    [self.publisher onValue:value];
}

@end
