//
// OOCPublishSubject.m
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

#import "OOCPublishSubject.h"
#import "NSObject+ObservableObjC.h"
#import "OOCAnonymousCancellable.h"
#import "OOCObserverList.h"

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
    if ([value ooc_isTerminator]) {
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
