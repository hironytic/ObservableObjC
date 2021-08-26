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

@interface OOCPublishSubject ()
@property(nonatomic, strong) OOCObserverList *observerList;
@property(nonatomic, assign) BOOL finished;
@end

@implementation OOCPublishSubject

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        OOCPublishSubject * __weak weakSelf = self;
        
        _observerList = [OOCObserverList new];
        
        _send = ^(id value) {
            if (weakSelf == nil) { return; }
            if (weakSelf.finished) { return; }
            
            [weakSelf.observerList sendToAllObservers:value];
            if ([value isKindOfClass:[OOCCompleted class]] || [value isKindOfClass:[NSError class]]) {
                weakSelf.finished = YES;
                [weakSelf.observerList removeAllObservers];
            }
        };
        
        _observable = ^(OOCObserver observer) {
            if (weakSelf != nil && !weakSelf.finished) {
                NSUInteger tag = [weakSelf.observerList addObserver:observer];
                return ^{
                    if (weakSelf != nil && !weakSelf.finished) {
                        [weakSelf.observerList removeObserver:tag];
                    }
                };
            } else {
                return ^{};
            }
        };
    }
    return self;
}

@end
