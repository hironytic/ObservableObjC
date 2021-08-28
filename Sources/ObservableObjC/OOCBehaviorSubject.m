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

#import "OOCBehaviorSubject.h"
#import "NSObject+ObservableObjC.h"
#import "OOCAnonymousCancellable.h"
#import "OOCObserverList.h"
#import "OOCPublishSubject.h"

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
    if ([self.currentValue ooc_isTerminator]) {
        return [OOCAnonymousCancellable new];
    } else {
        return [self.publisher subscribeByObserver:observer];
    }
}

- (id)value {
    return self.currentValue;
}

- (void)setValue:(id)value {
    if ([self.currentValue ooc_isTerminator]) {
        return;
    }

    self.currentValue = value;
    [self.publisher onValue:value];
}

@end
